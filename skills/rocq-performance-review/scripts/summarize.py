#!/usr/bin/env python3
"""profile.json -> the review site's data files.

  python3 summarize.py --profile p.json --work /tmp/rocqprof --out site/public/data \
      [--theory NAME] [--repo <checkout>] [--parallel-wall 80.3] [--roles roles.json]

Writes:
  <out>/summary.json          one row per file + run metadata + hottest commands
  <out>/files/<slug>.json     full source, per-command times, per-line time array

--roles is an optional [[regex, label], ...] list applied in order to each path;
the first match wins.  Without it every file is labelled "unclassified" and the
site's "by kind of file" view should be hidden.
"""
import argparse, datetime, json, os, re, subprocess


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", required=True)
    ap.add_argument("--work", required=True, help="the work dir profile_build.py used")
    ap.add_argument("--out", required=True)
    ap.add_argument("--theory", default="", help="logical name, for -Q when re-running rocq dep")
    ap.add_argument("--repo", help="checkout to read the commit from")
    ap.add_argument("--parallel-wall", type=float, help="measured wall time of the normal build")
    ap.add_argument("--roles", help="JSON [[regex, label], ...]")
    ap.add_argument("--hot-threshold", type=float, default=0.2)
    a = ap.parse_args()

    prof = json.load(open(a.profile))
    files = prof["files"]
    vs = [f["file"] for f in files]
    root = prof.get("root", "")
    os.makedirs(os.path.join(a.out, "files"), exist_ok=True)

    # --- dependency graph, for the critical path ----------------------------
    dep_args = ["-Q", root, a.theory] if a.theory else []
    coqdep = ["rocq", "dep"] if _has("rocq") else ["coqdep"]
    raw = subprocess.run(coqdep + dep_args + vs, cwd=a.work, capture_output=True,
                         text=True).stdout.replace("\\\n", " ")
    vset = set(vs)
    deps = {v: set() for v in vs}
    for line in raw.splitlines():
        if ":" not in line:
            continue
        lhs, rhs = line.split(":", 1)
        ds = {d[:-3] + ".v" for d in rhs.split() if d.endswith(".vo")}
        for t in [t[:-3] + ".v" for t in lhs.split() if t.endswith(".vo")]:
            if t in deps:
                deps[t] |= (ds & vset) - {t}

    cost = {f["file"]: f.get("wall_time", 0.0) for f in files}
    finish, pred = {}, {}

    def cp(v):  # earliest finish with unlimited parallelism
        if v in finish:
            return finish[v]
        finish[v] = 0.0  # cycle guard
        best, bestp = 0.0, None
        for d in deps[v]:
            t = cp(d)
            if t > best:
                best, bestp = t, d
        pred[v] = bestp
        finish[v] = best + cost[v]
        return finish[v]

    for v in vs:
        cp(v)
    end = max(vs, key=lambda v: finish[v])
    chain, cur = [], end
    while cur:
        chain.append(cur)
        cur = pred.get(cur)
    chain.reverse()

    rules = [(re.compile(p), lab) for p, lab in json.load(open(a.roles))] if a.roles else []

    def role(path):
        for rx, lab in rules:
            if rx.search(path):
                return lab
        return "unclassified"

    def strip(p):
        return p[len(root) + 1:] if root and p.startswith(root + "/") else p

    def group(path):
        parts = strip(path).split("/")
        return "/".join(parts[:-1]) if len(parts) > 1 else "(root)"

    summary, hot = [], []
    for f in files:
        v = f["file"]
        sents = f.get("sentences", [])
        src_path = os.path.join(a.work, v)
        src = open(src_path, "rb").read().decode("utf-8", errors="replace") \
            if os.path.exists(src_path) else ""
        nlines = f.get("lines", src.count("\n") + 1)
        line_time = [0.0] * (nlines + 2)
        for s in sents:
            if s["line"] <= nlines + 1:
                line_time[s["line"]] += s["wall"]
        slug = re.sub(r"[^A-Za-z0-9]+", "_", strip(v)[:-2])
        json.dump({"path": v, "source": src, "lineTime": line_time[1:nlines + 1],
                   "sentences": [{"line": s["line"], "endline": s["endline"],
                                  "wall": round(s["wall"], 3), "cmd": s["cmd"],
                                  "src": s["src"]} for s in sents]},
                  open(os.path.join(a.out, "files", slug + ".json"), "w"))
        hot += [{"path": v, "slug": slug, "line": s["line"], "wall": round(s["wall"], 3),
                 "src": s["src"][:200]} for s in sents if s["wall"] >= a.hot_threshold]
        sent_wall = sum(s["wall"] for s in sents)
        summary.append({
            "path": v, "slug": slug, "name": v.split("/")[-1],
            "group": group(v), "role": role(v),
            "wall": round(f.get("wall_time", 0.0), 3),
            "user": round(f.get("user", 0.0), 3),
            "sys": round(f.get("sys", 0.0), 3),
            "maxrssMb": round(f.get("maxrss_kb", 0) / 1024.0, 1),
            "lines": nlines, "bytes": f.get("bytes", 0), "voBytes": f.get("vo_bytes", 0),
            "sentences": len(sents), "sentenceWall": round(sent_wall, 3),
            "overhead": round(max(0.0, f.get("wall_time", 0.0) - sent_wall), 3),
            "deps": len(deps.get(v, ())), "depthS": round(finish.get(v, 0.0), 3),
            "onCriticalPath": v in set(chain), "ok": f.get("ok", False),
            "top": [{"line": s["line"], "wall": round(s["wall"], 3), "cmd": s["cmd"],
                     "src": s["src"][:200]}
                    for s in sorted(sents, key=lambda s: -s["wall"])[:12]],
        })

    summary.sort(key=lambda r: -r["wall"])
    hot.sort(key=lambda c: -c["wall"])
    meta = {
        "generated": datetime.datetime.now().replace(microsecond=0).isoformat(),
        "rocq": _version(),
        "commit": subprocess.run(["git", "-C", a.repo or ".", "rev-parse", "--short", "HEAD"],
                                 capture_output=True, text=True).stdout.strip(),
        "serialWall": round(prof["total_wall"], 1),
        "jobs": prof.get("jobs", 1),
        "cpus": os.cpu_count(),
        "duneParallelWall": a.parallel_wall,
        "criticalPathS": round(finish[end], 1),
        "criticalPath": chain,
        "totalCpu": round(sum(r["user"] + r["sys"] for r in summary), 1),
        "totalSentences": sum(r["sentences"] for r in summary),
        "totalLines": sum(r["lines"] for r in summary),
        "peakRssMb": max((r["maxrssMb"] for r in summary), default=0),
        "roles": bool(rules),
    }
    json.dump({"meta": meta, "files": summary, "hotCommands": hot[:200]},
              open(os.path.join(a.out, "summary.json"), "w"))
    print(f"{len(summary)} files · serial {meta['serialWall']}s · "
          f"critical path {meta['criticalPathS']}s ({len(chain)} files)")
    print("top:", [(r["name"], r["wall"]) for r in summary[:6]])


def _has(x):
    import shutil
    return shutil.which(x)


def _version():
    for cmd in (["rocq", "--version"], ["coqc", "--version"]):
        try:
            out = subprocess.run(cmd, capture_output=True, text=True).stdout.strip()
            if out:
                return out.splitlines()[0]
        except FileNotFoundError:
            pass
    return "unknown"


if __name__ == "__main__":
    main()
