---
name: rocq-performance-review
description: Profile a Rocq/Coq build — per-file wall time and peak memory, per-command timing inside each file, and the dependency critical path — then present it as an interactive review website. Use when asked where a proof build's time or memory goes, why it is slow, which files or tactics are expensive, or for a build profile / performance review.
---

# Rocq performance review

Two deliverables: a **measurement** and a **review site** over it. Bundled
scripts do the measurement; the site is built fresh per project, to the spec
below.

Cost: the measurement is roughly (serial CPU time of one full build) — measure
the project's normal build first to predict it. Say so before starting if that
is more than a few minutes.

## 1. Measure

Rocq 9.x has **no `-profile` JSON output**. The only per-command timer is
`-time` / `-time-file`, and memory only comes from the OS. So each file is
compiled on its own with `/usr/bin/time` outside and `-time-file` inside.

```sh
S=~/.claude/skills/rocq-performance-review/scripts

# a) Build once with the project's own build system, and TIME it — this is the
#    "real build" number worth comparing against.
time dune build --root . <theory-dir>/          # or: make -j$(nproc)

# b) Recompile every file individually, serially, instrumented.
python3 $S/profile_build.py --src <built-tree> --theory <LogicalName> \
    --work /tmp/rocqprof --out /tmp/rocqprof/profile.json -j 1 \
    --exclude 'Extraction\.v$' --arg=-w --arg=-notation-incompatible-prefix

# c) Fold into the site's data files.
python3 $S/summarize.py --profile /tmp/rocqprof/profile.json --work /tmp/rocqprof \
    --theory <LogicalName> --repo . --parallel-wall <seconds from (a)> \
    --roles roles.json --out <site>/public/data
```

`--src` must be a tree containing **every** `.v`, generated ones included: for
dune that is `_build/default/<theory-dir>`; for `coq_makefile`, the source tree
after a build. `profile_build.py` copies it aside, so the project's own build is
never disturbed. Both scripts prefer `rocq`/`rocq dep` and fall back to
`coqc`/`coqdep`; `--help` lists the rest.

Decisions that matter:

- **Work in a throwaway worktree or clean checkout.** Stray in-source
  `.vo`/`.glob` make dune refuse to build ("Multiple rules generated"), and a
  shared checkout may be in use by someone else.
- **Serial (`-j 1`) is the point.** Wall time and peak RSS are only comparable
  without contention. `-j N` is much faster but then only CPU time means
  anything — if you ever report a parallel run, say so out loud.
- **Exclude files with build side effects** (e.g. an `Extraction.v` that writes
  `.ml`) — mirror whatever the project's batch build excludes.
- **Attribute each command to the line it starts on**, and say so: a multi-line
  tactic block bills to its first line. (`Chars a - b` in `-time-file` output
  are *byte* offsets — the script already maps them over bytes.)
- **Critical path** = longest chain in the `rocq dep` DAG weighted by the serial
  per-file times. This is the headline: it explains the gap between total CPU
  time and the real parallel build, and is the only floor more cores cannot beat.
- **Classify files by role, not just by directory** — pass `--roles` with
  `[["regex", "label"], ...]`, first match wins, e.g.

  ```json
  [["MemImage\\.v$", "memory image (generated)"],
   ["_(source|target|code)\\.v$", "binary decode lemmas"],
   ["/Proof\\.v$", "example proof"],
   ["^theories/(Riscv|Sem)/", "core semantics"]]
  ```

  Derive the labels from the project: generated vs. hand-written, per-instance
  boilerplate vs. core theory, proofs vs. definitions vs. checkers. This usually
  shows one *kind* of file dominating, which the directory view alone hides.
  Check what is actually generated (`git ls-files`) before calling anything
  generated.
- **Note the floor.** Loading a large theory's dependencies costs a few hundred
  ms and ~100 MB before a file does any work; state it so nobody over-reads
  sub-second differences.

Portability traps: minimal containers often lack `pgrep`, `ps`, `jq` and `free`
— poll `/proc/*/cmdline` to wait on a process. Piping a long run into `tail`
hides all progress until it exits. `/usr/bin/time -o` resolves relative to the
child's cwd.

## 2. The site

Follow the `review-website` skill for stack (bun + Vite + Vue 3
`<script setup lang="ts">`, rough.js, shiki, light mode) and the `dataviz`
skill for palette and chart rules. Read `public/data/*.json` at runtime, so a
re-measurement needs no code change; fetch the per-file JSON lazily.

Data contract from `summarize.py`:

- `summary.json` — `meta` (serial wall, parallel wall, critical path + chain,
  cpus, totals, tool version, commit), `files[]` (path, slug, group, role, wall,
  user, sys, maxrssMb, lines, bytes, voBytes, sentences, deps, depthS,
  onCriticalPath, top 12 commands), `hotCommands[]` (globally ranked).
- `files/<slug>.json` — `source`, `lineTime[]` (per line), `sentences[]`.

Four views:

1. **Overview** — stat tiles (serial CPU · real parallel build · critical path ·
   worst peak RSS · commands timed); top-20 files by time, dotting the ones on
   the critical path; a concentration curve (how few files are most of the
   build); cost by role; heaviest files by memory; and a **directory hierarchy**
   showing cumulative time per subtree, expandable down to files.
2. **Files** — every file, sortable on every column (time, peak RSS, lines,
   ms/line, commands, source and `.vo` size, deps), filterable by path, by
   directory, by role, and by critical-path membership.
3. **Hot commands** — the globally ranked `hotCommands`, with a text filter.
   Never assemble this from per-file top-N lists; that silently drops commands.
4. **Critical path** — the chain as rough.js bars (the one signature visual),
   plus a "how this was measured" note carrying the caveats above.

Everything clicks through to a **file detail view**: that file's most expensive
commands as bars (clicking one jumps to it), and the full source
syntax-highlighted with a per-line time gutter, each line shaded on a single-hue
ramp scaled to that file's slowest line (`sqrt` of the ratio, alpha ≤ 0.5 so code
stays readable), with a legend and a hover tooltip giving the line's share of the
file. **Virtualize** that list — proof files reach thousands of lines.

Small things that came out of review: truncate paths keeping the **tail** and
code keeping the **head**; hide the role view when `meta.roles` is false; and
verify with Playwright at 1400px — screenshot every tab plus a detail view,
exercise the interactive bits, and assert no console errors — before handing off.

## 3. Report

Lead with the shape of the build, not a file list: total serial CPU vs. real
parallel wall vs. critical path; which *kind* of file dominates; the single
worst file for time and for memory; and the hottest individual commands. Then
point at the site for the rest.
