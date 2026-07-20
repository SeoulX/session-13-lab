# Module 04 — Parallel CI stages

## Goal
Add a Claude review stage to Jenkins that runs parallel to Test + Vuln Scan. Zero wall-clock cost when Test is faster.

## Files
- `Jenkinsfile.snippet` — paste this `stage('Analysis')` block into your `Jenkinsfile.default`.
- `claude-review.sh` — the shell that Jenkins invokes. Runs `claude -p` w/ JSON output.

## Wire it

1. Copy the snippet into `Jenkinsfile.default` between `Test` and `Build & Push Staging`.
2. Push a new tag to your repo.
3. Watch Pulse tracker → the Claude row shows up parallel to Test.
4. Screenshot the tracker's right panel + drop in `#training`.

## Design notes
- Soft-fail during rollout (`|| true`) until false-positive rate is understood. Flip to hard-fail later.
- Result JSON archived by Jenkins (`archiveArtifacts`) so you can grep across builds.
