# Session 13 — Presenter runbook (terminal-only)

Zero-cost demo. Runs entirely from your laptop against local Claude Code CLI (Pro subscription). No API key, no GHA runs. Total time ≈ 40 min for Modules 01–05.

## Pre-flight (5 min before session)

```bash
# 1. Verify Claude works
claude --version                          # should print

# 2. Warm the cache — first call has extra latency
claude -p "say hello" > /dev/null

# 3. Split terminal: big font (18-24pt), 2 panes ready
tmux new -s s13
# Ctrl-b " to split horizontally, Ctrl-b o to swap

# 4. Clone lab if not local
git clone https://github.com/SeoulX/session-13-lab.git ~/session-13-lab
cd ~/session-13-lab

# 5. Open the deck to slide 03 as backdrop
open manComm/07-20-26/training/cicd-pulse-tutorial-slides.html
```

## Live sequence

### Module 01 (5 min)
```bash
cd module-01-non-interactive
cat demo.sh                       # show
./demo.sh                          # run — audience sees Claude's reply

cat guard.sh
./guard.sh
echo "exit was $?"                 # prove exit code
```
**Talking point:** "Exit code is your API. Any shell can consume this."

### Module 02 (7 min)
```bash
cd ../module-02-structured
./envelope.sh                      # runs + writes /tmp/claude-envelope.json
cat /tmp/claude-envelope.json | jq '.' | head -20
```
Point at `result`, `sessionId`, `totalCost` fields.

```bash
./stream.sh                        # audience sees live tool_use lines
./cost.sh /tmp/claude-stream.log   # cost accounting
```
**Talking point:** "This is what Pulse's tracker parses row-by-row."

### Module 03 (8 min)
```bash
cd /tmp && rm -rf hook-demo && mkdir hook-demo && cd hook-demo && git init -q
~/session-13-lab/module-03-hooks/install.sh
ls -la .git/hooks/pre-commit       # show installed

~/session-13-lab/module-03-hooks/demo-diff.sh
git add leak.txt
git commit -m "test"               # ← blocks. Show ❌.

git commit --no-verify -m "override"   # escape hatch
```
**Talking point:** "Hard-fail for irreversible; warn-only for stuff CI catches too."

Pivot: open the `.github/workflows/03-precommit-mirror.yml` file on-screen.
> "Same rules replayed in CI so `--no-verify` doesn't skip the gate at merge time. Not running it live today — no API key — but here's the shape."

### Module 04 (7 min · read-only)

Open `.github/workflows/04-parallel-ci.yml` in editor. Walk through:
- 3 `jobs:` w/o `needs:` → concurrent
- `uses: anthropics/claude-code-action@v1` → the official action
- `secrets.ANTHROPIC_API_KEY` → what your org would set
- `actions/github-script@v7` → auto-comment findings on PR

Open Pulse tracker page in browser (`https://pulse.media-meter.in/deploy/repo/pulse_test_api`) and point at the log rows.
> "This is the equivalent for our Jenkins pipeline — same parallel pattern, different syntax."

### Module 05 (6 min)
```bash
cd ~/session-13-lab/module-05-monitoring
./run-background.sh                # backgrounds Claude
```
Switch to second pane:
```bash
./tail-live.sh                     # live filter — Ctrl-C after 30s
```
Back to first pane:
```bash
./cost.sh /tmp/claude-audit.log
```
Show `~/.claude/projects/` in editor for 5 seconds so people see session logs exist.

Then open `.github/workflows/05-monitoring.yml` — narrate the scheduled cron version.

## Capstone (8 min)

Live-walk the Pulse form → tracker → Jenkins flow. Don't submit a real deploy — too slow. Instead:
- Screen-share existing tracker page for a completed build
- Walk sidebar → right panel → retry button
- Reference `manComm/07-14-26/infisical/onboarding.html` for deeper reading

## Recovery script (if Claude dies mid-demo)

Pre-seed all the log files before session so `cat /tmp/*.log` still shows expected output:
```bash
# Run this Pre-flight, saves outputs to /tmp — replay if live fails
./module-01-non-interactive/demo.sh    > /tmp/demo-01.txt   2>&1 || true
./module-02-structured/envelope.sh     > /tmp/demo-02a.txt  2>&1 || true
./module-02-structured/stream.sh       > /tmp/demo-02b.txt  2>&1 || true
```

If live Claude call hangs: Ctrl-C, `cat /tmp/demo-*.txt`, keep moving. Never debug live.

## Why no GHA today

Anthropic API key needed for `secrets.ANTHROPIC_API_KEY`. Pro sub only covers the local CLI, not programmatic API. Workflows in `.github/workflows/` are the **canonical shape** — devs can activate them the day their org sets up an API key.

For the live session: local Claude runs are the substance; GHA files are the shape you'd hand to devops after training.
