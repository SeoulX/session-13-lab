# Module 04 — Parallel CI (Claude alongside test + lint)

## Goal
Add a Claude review job that runs in parallel with your existing test + lint pipeline. Zero wall-clock cost when Claude finishes before the slowest existing job.

## Two paths, same primitive

| Where | Syntax | How it parallelizes |
|---|---|---|
| **Local shell (demo today)** | bash `&` background jobs + `wait` | Kernel schedules 3 processes concurrently |
| **GitHub Actions (canonical CI)** | separate `jobs:` without `needs:` | GHA scheduler dispatches 3 runners concurrently |

Same primitive, different scheduler.

## Files
- `parallel-local.sh` — **runs live** in the session. Fires test + lint + claude-review in parallel via bash `&`. Total wall-clock = max(job).
- `demo-buggy-diff.sh` — seeds a `buggy.py` w/ real defects so Claude has something to actually flag.
- `.github/workflows/04-parallel-ci.yml` (at repo root) — reference workflow. Same behavior in GHA; needs `ANTHROPIC_API_KEY`.
- `claude-review.sh` — the review-only step, callable standalone.

## Live demo (60 seconds)

```bash
cd module-04-parallel-ci
./demo-buggy-diff.sh    # writes buggy.py + stages it
./parallel-local.sh     # runs 3 checks concurrently

# Expected: total wall-clock ~= claude call time (~5s), NOT sum (10s+).
# Claude reports findings on buggy.py.
```

Point at the wall-clock number vs sum-of-individual — that's the parallelism win.

## Design notes
- `sleep 3` + `sleep 2` are stand-ins for real test / lint. Wire your actual commands in `parallel-local.sh` job blocks 1 + 2.
- Claude call uses `--append-system-prompt` to enforce JSON-only reply. Prose-mixed responses would break `jq`.
- GHA workflow is functionally identical + auto-comments findings on the PR via `actions/github-script`. Activate when your org sets `ANTHROPIC_API_KEY`.
