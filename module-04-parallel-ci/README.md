# Module 04 — Parallel CI (GitHub Actions)

## Goal
Add a Claude review job that runs parallel to test + lint on every PR.

## Files
- `.github/workflows/04-parallel-ci.yml` (at repo root) — three jobs, no `needs:` = they run concurrently
- `claude-review.sh` — same shell the workflow invokes (works locally too)

## Wire it (one-time)

1. In your repo settings → Secrets → Actions, add `ANTHROPIC_API_KEY`.
2. Push the workflow file. Open a PR.
3. GitHub Actions tab → see three jobs run in parallel.
4. Claude auto-comments findings on the PR.

## Design notes
- Total wall-clock = **max(job duration)**, not sum. Adding Claude to a suite where lint takes 30 s costs nothing when Claude takes 45 s (both under 1 min).
- `continue-on-error: true` = soft-fail during rollout week. Flip off once false-positive rate is understood.
- Findings uploaded as artifact (`actions/upload-artifact`) so you can grep across historical runs.
- PR comment via `actions/github-script` — devs see review inline w/ their code.

## Why GHA over Jenkins for this module

GHA is the ambient CI most devs know. Jenkins is our internal deploy platform (Pulse pipeline) — covered in Module 06 as an applied case study, not the primitive.
