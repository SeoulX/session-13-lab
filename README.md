# Session 13 — CI/CD Automation + Pulse Tutorial (Lab Repo)

Companion repo for the 75-min Session 13 training. One directory per module. Each holds:

- `README.md` — module goal + steps
- runnable scripts you paste into a shell / hook / Jenkinsfile
- a `check.sh` self-test where applicable

## Prerequisites

- Claude Code CLI installed + logged in (`claude --version` works)
- `jq` on `PATH`
- Bash shell (macOS default is 3.2 — install `bash` 5+ via brew if you hit array/regex issues)
- Optional: kubectl configured for kl-1 (only needed in Module 06 walkthrough)

## Modules

| # | Directory | Time |
|---|---|---|
| 01 | `module-01-non-interactive/` | 10 min |
| 02 | `module-02-structured/` | 10 min |
| 03 | `module-03-hooks/` | 12 min |
| 04 | `module-04-parallel-ci/` | 10 min |
| 05 | `module-05-monitoring/` | 8 min |
| — | `capstone/` | 8 min |

Run `./capstone/verify.sh` at the end to check all five modules produced expected artifacts.

## Not included on purpose

- The **Pulse demo app** lives in a separate repo (`pulse_demo_app`). Submit it via Pulse form to complete the capstone.
- No CI pipeline in this repo — it's a lab, not a service.
