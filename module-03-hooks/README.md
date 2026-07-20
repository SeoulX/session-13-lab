# Module 03 — Pre-commit hooks

## Goal
Block bad commits before they leave the laptop. Extend Claude into pulse-align's compliance checklist.

## Files
- `pre-commit.sh` — installable hook. Copy to `.git/hooks/pre-commit`, `chmod +x`, done.
- `install.sh` — one-liner installer for your current repo.
- `demo-diff.sh` — creates a fake diff w/ a `ghp_*` token so the hook fires.

## Install into your current repo

```bash
./install.sh
```

## Trigger it

```bash
./demo-diff.sh   # writes leak.txt containing a fake token
git add leak.txt
git commit -m "test"   # hook fires, blocks, exit 1
```

Override w/:

```bash
git commit --no-verify -m "..."
```

## Design notes
- Two gates: **secret leak** (hard-fail — irreversible after push), **pulse-align compliance** (warn-only — Trivy re-runs it in CI).
- `--no-verify` is intentional; document it so devs know how to bypass in emergencies.
