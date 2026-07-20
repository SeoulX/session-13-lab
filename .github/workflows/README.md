# GitHub Actions workflows

One workflow per module. Copy into your repo's `.github/workflows/` to see the same CI behavior.

## Prereq

Add `ANTHROPIC_API_KEY` in repo Settings → Secrets → Actions.

## Files

| File | Trigger | Purpose |
|---|---|---|
| `01-non-interactive.yml` | Manual + PR to Module 01 files | Prove `claude -p` works in a GHA runner |
| `02-structured-output.yml` | Manual + PR | Emit JSON envelope + cost summary |
| `03-precommit-mirror.yml` | PR | Repeat local pre-commit gate as a hard CI check (leak) + soft compliance |
| `04-parallel-ci.yml` | PR | Test + Lint + Claude review — parallel, PR comment on findings |
| `05-monitoring.yml` | `cron '17 3 * * *'` + manual | Nightly audit, cost roll-up, Slack notify |

## Why GHA in the lab

Devs already know it. Zero infra to stand up. Jenkins is our internal deploy pipeline (Pulse) — covered separately in Module 06 as an applied case study, not the primitive taught in Modules 01–05.
