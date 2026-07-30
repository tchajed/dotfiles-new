#!/usr/bin/env python3
"""Instrumented Rocq/Coq build: per-file wall, CPU, peak RSS + per-command timing.

Works on a *copy* of an already-built source tree, so it never disturbs the
project's own build.  Output is a single JSON file consumed by summarize.py.

  python3 profile_build.py --src <tree-with-all-.v> --theory <LogicalName> \
      --work /tmp/rocqprof --out /tmp/rocqprof/profile.json [-j 1]

--src must be the tree that contains EVERY .v file, generated ones included:
for dune that is _build/default/<theory-dir>, for coq_makefile the source tree
itself (after a normal build).
"""
import argparse, bisect, json, os, re, shutil, subprocess, sys, time
from concurrent.futures import FIRST_COMPLETED, ThreadPoolExecutor, wait


def which(*names):
    for n in names:
        if shutil.which(n):
            return n
    sys.exit(f"none of {names} found in PATH")


def prepare(src, work, name, excludes):
    dst = os.path.join(work, name)
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst, symlinks=False)
    for root, _, files in os.walk(dst):
        for f in files:
            if f.endswith((".vo", ".vos", ".vok", ".glob", ".aux", ".timing", ".rusage")):
                os.remove(os.path.join(root, f))
    vs = []
    for root, _, files in os.walk(dst):
        for f in sorted(files):
            if not f.endswith(".v"):
                continue
            rel = os.path.relpath(os.path.join(root, f), work)
            if not any(re.search(p, rel) for p in excludes):
                vs.append(rel)
    return sorted(vs)


def dep_graph(coqdep, work, vs, args):
    out = subprocess.run([*coqdep, *args] + vs, cwd=work, capture_output=True,
                         text=True).stdout.replace("\\\n", " ")
    graph = {}
    for line in out.splitlines():
        if ":" not in line:
            continue
        lhs, rhs = line.split(":", 1)
        targets = [t for t in lhs.split() if t.endswith(".vo")]
        deps = {d for d in rhs.split() if d.endswith(".vo")}
        for t in targets:
            graph.setdefault(t, set()).update(deps - {t})
    return graph


TIME_RE = re.compile(r"Chars (\d+) - (\d+) \[([^\]]*)\] ([\d.]+) secs \(([\d.]+)u,([\d.]+)s\)")


def parse_timing(timing_path, src_path):
    """Rocq's -time-file output.  Chars are BYTE offsets, so map over bytes."""
    try:
        raw = open(timing_path, encoding="utf-8", errors="replace").read()
    except FileNotFoundError:
        return []
    data = open(src_path, "rb").read()
    nl = [0] + [i + 1 for i, ch in enumerate(data) if ch == 0x0A]
    out = []
    for m in TIME_RE.finditer(raw):
        a, b = int(m.group(1)), int(m.group(2))
        out.append({
            "line": bisect.bisect_right(nl, a),
            "endline": bisect.bisect_right(nl, max(a, b - 1)),
            "chars": [a, b],
            "cmd": m.group(3)[:400],
            "wall": float(m.group(4)),
            "user": float(m.group(5)),
            "sys": float(m.group(6)),
            "src": data[a:b][:600].decode("utf-8", errors="replace"),
        })
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True, help="built tree containing every .v")
    ap.add_argument("--theory", help="logical name for --src (adds -Q <copy> NAME)")
    ap.add_argument("--work", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("-j", type=int, default=1, help="1 (default) keeps wall/RSS trustworthy")
    ap.add_argument("--arg", action="append", default=[],
                    help="extra flag for the compiler, repeatable (e.g. --arg=-w --arg=-all)")
    ap.add_argument("--extra-path", action="append", default=[],
                    help="DIR:LogicalName for an out-of-tree -Q, repeatable")
    ap.add_argument("--exclude", action="append", default=[],
                    help="regex on the relative path; repeatable")
    ap.add_argument("--rocq", help="compiler (default: rocq compile, else coqc)")
    ap.add_argument("--coqdep", help="dependency scanner (default: rocq dep, else coqdep)")
    a = ap.parse_args()

    work = os.path.abspath(a.work)
    os.makedirs(work, exist_ok=True)
    name = os.path.basename(os.path.normpath(a.src))

    rocq = a.rocq.split() if a.rocq else (
        ["rocq", "compile"] if shutil.which("rocq") else [which("coqc")])
    coqdep = a.coqdep.split() if a.coqdep else (
        ["rocq", "dep"] if shutil.which("rocq") else [which("coqdep")])

    paths = []
    if a.theory:
        paths += ["-Q", name, a.theory]
    for p in a.extra_path:
        d, _, logical = p.rpartition(":")
        paths += ["-Q", d, logical]

    vs = prepare(a.src, work, name, a.exclude)
    print(f"{len(vs)} source files", flush=True)
    targets = {v + "o" for v in vs}  # X.v -> X.vo
    graph = dep_graph(coqdep, work, vs, paths)
    graph = {t: graph.get(t, set()) & targets for t in targets}

    t0 = time.time()
    results, done, dead = {}, set(), set()

    def compile_one(vo):
        v, stem = vo[:-1], vo[:-3]  # X.vo -> X.v, X
        cmd = ["/usr/bin/time", "-f", "%e %U %S %M", "-o", stem + ".rusage",
               *rocq, "-q", *paths, *a.arg, "-time-file", stem + ".timing", v]
        start = time.time()
        p = subprocess.run(cmd, cwd=work, capture_output=True, text=True)
        rec = {"file": v, "ok": p.returncode == 0, "start": start - t0,
               "end": time.time() - t0}
        try:
            f = open(os.path.join(work, stem + ".rusage")).read().split()[-4:]
            rec.update(wall_time=float(f[0]), user=float(f[1]), sys=float(f[2]),
                       maxrss_kb=int(f[3]))
        except Exception:
            pass
        if not rec["ok"]:
            rec["error"] = (p.stdout + p.stderr)[-4000:]
        rec["sentences"] = parse_timing(os.path.join(work, stem + ".timing"),
                                        os.path.join(work, v))
        rec["lines"] = sum(1 for _ in open(os.path.join(work, v), "rb"))
        rec["bytes"] = os.path.getsize(os.path.join(work, v))
        vop = os.path.join(work, vo)
        rec["vo_bytes"] = os.path.getsize(vop) if os.path.exists(vop) else 0
        return rec

    pending = dict(graph)
    with ThreadPoolExecutor(max_workers=a.j) as ex:
        futures = {}
        while pending or futures:
            for t in [t for t, d in pending.items() if d & dead]:
                del pending[t]
                dead.add(t)
                results[t] = {"file": t[:-1], "ok": False, "skipped": True,
                              "sentences": []}
            for t in [t for t, d in pending.items() if d <= done]:
                del pending[t]
                futures[ex.submit(compile_one, t)] = t
            if not futures:
                if pending:
                    print("stuck (unmet deps):", list(pending)[:5], file=sys.stderr)
                break
            for fut in wait(list(futures), return_when=FIRST_COMPLETED).done:
                rec = fut.result()
                vo = futures.pop(fut)
                results[vo] = rec
                (done if rec["ok"] else dead).add(vo)
                if not rec["ok"]:
                    print("FAILED", rec["file"], rec.get("error", "")[-600:], file=sys.stderr)
                print(f"[{len(results)}/{len(graph)}] {rec['file']} "
                      f"{rec.get('wall_time', 0):.1f}s {rec.get('maxrss_kb', 0) // 1024}MB",
                      flush=True)

    json.dump({"jobs": a.j, "total_wall": time.time() - t0, "root": name,
               "files": sorted(results.values(), key=lambda r: r["file"])},
              open(a.out, "w"))
    bad = [r["file"] for r in results.values() if not r["ok"]]
    print(f"wrote {a.out}" + (f" — {len(bad)} FAILED: {bad[:5]}" if bad else ""))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
