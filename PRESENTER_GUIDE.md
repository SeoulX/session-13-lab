# Session 13 — Full presenter guide

One document. Everything you need to run the 75-min session end-to-end. Two arcs (primitives → applied Pulse), one live GHA demo, one capstone.

**Repo:** github.com/SeoulX/session-13-lab
**Deck:** `manifests-seven-gen-v2/manComm/07-20-26/training/cicd-pulse-tutorial-slides.html`
**Companion:** `ONELINERS.html` (browsable) + `ONELINERS.md` (source)

---

## 0. Day-of prep (30 min before session)

### 0.1 Verify environment

```bash
claude --version                              # CLI reachable
claude -p "hi" > /dev/null                    # warm cache
gh auth status                                # GitHub CLI logged in
cd ~/session-13-lab && git status             # repo clean
```

### 0.2 Verify GHA state

```bash
gh secret list                                # CLAUDE_CODE_OAUTH_TOKEN present
gh workflow list                              # 6 workflows: 01-05 + claude.yml
gh pr view 2 --json state,url                 # PR #2 open on demo-day
```

If PR #2 is missing:
```bash
cd ~/session-13-lab && git checkout demo-day
echo "# trigger" >> module-04-parallel-ci/demo-note.md
git commit -am "demo trigger" && git push
gh pr create --title "Demo — Session 13 live" --body "Live demo target" --base main --head demo-day
```

### 0.3 Screen setup

- **Terminal**: font 20pt+, tmux w/ 2 horizontal panes
  - Left pane: `cd ~/session-13-lab`
  - Right pane: `cd ~/session-13-lab && tail -f /dev/null` (holding)
- **Browser tabs (bookmark bar)**:
  1. Slide deck
  2. `https://github.com/SeoulX/session-13-lab` — repo home
  3. `https://github.com/SeoulX/session-13-lab/actions` — Actions dashboard
  4. `https://github.com/SeoulX/session-13-lab/pull/2` — demo PR
  5. `https://pulse.media-meter.in/deploy` — Pulse form
  6. `https://pulse.media-meter.in/deploy/repo/pulse_test_api` — sample tracker
- **Discord**: `#training` visible on second screen

### 0.4 Pre-seed fallback outputs

```bash
mkdir -p /tmp/s13
claude -p "reply READY"                              > /tmp/s13/01-ready.txt
claude -p "list 3 python files here" --output-format json > /tmp/s13/02-envelope.json
claude -p --output-format stream-json --verbose \
  "count files here"                                > /tmp/s13/05-stream.log
```

Use `cat /tmp/s13/*.txt` mid-session if live Claude hangs.

---

## 1. Session flow

| Time | Slide | Module | Action |
|------|-------|--------|--------|
| 0:00 | 01 | — | Title |
| 0:00 | 02 | — | Frame (outcomes) |
| 0:03 | 03 | — | Pipeline map |
| 0:05 | 04 | M01 | Live: `claude -p` |
| 0:09 | 05 | M02 | Live: `--output-format json` |
| 0:13 | 06 | M03 | Live: pre-commit hook |
| 0:17 | 07 | M04 | Live: parallel local + **GHA demo** |
| 0:35 | 08 | M05 | Live: stream-json + jq |
| 0:39 | — | — | Applied divider (30s) |
| 0:40 | 09-15 | Pulse | Screen-share Pulse UI |
| 1:00 | 16 | M08 | Failure paths |
| 1:04 | 17 | M09 | Capstone read-out |
| 1:08 | 18 | Wrap | Recap + Q&A |
| 1:15 | — | — | Hard stop |

---

## 2. Primitives arc — 25 min · local terminal

### Slide 04 · M01 (4 min)

```bash
claude -p "reply READY"
```

**Audience sees:** `READY`

**Say:** Every CI stage is a shell command. If Claude is a shell command, Claude is a CI stage.

### Slide 05 · M02 (4 min)

```bash
claude -p "list 3 python files here" --output-format json
```

Pause. Point at the JSON envelope.

```bash
claude -p "list 3 python files here" --output-format json | jq -r '.result'
```

**Audience sees:** JSON blob → clean text.

**Say:** CI doesn't read English. It reads exit codes and JSON.

### Slide 06 · M03 (4 min)

```bash
mkdir /tmp/hook && cd /tmp/hook && git init
cat > .git/hooks/pre-commit <<'EOF'
#!/bin/bash
git diff --cached | claude -p "reply BLOCK if you see any api token, else PASS" | grep -q PASS
EOF
chmod +x .git/hooks/pre-commit

echo "token=ghp_ABCDEFG..." > secret.txt
git add secret.txt
git commit -m "test"
```

**Audience sees:** Commit blocked.

**Say:** CI shifted LEFT. Same check, caught 5 min earlier. Free.

### Slide 07 · M04 (18 min — this is the star)

**Part A · local parallel (4 min)**

```bash
cd ~/session-13-lab
time { (sleep 3 && echo "test done") & (sleep 2 && echo "lint done") & (claude -p "one bug in: def div(a,b): return a/b" && echo "claude done") & wait; }
```

**Audience sees:** 3 "done" lines, wall clock ≈ 5 s (not 10).

**Say:** Wall clock = max, not sum. GHA `jobs:` without `needs:` do the same trick.

**Part B · GHA live demo (14 min)** — go to §3 below

### Slide 08 · M05 (4 min)

```bash
claude -p --output-format stream-json --verbose "count files here" > /tmp/log
jq -r '.message.content[]? | select(.type=="tool_use") | .name' /tmp/log
jq -r 'select(.type=="result") | .total_cost_usd' /tmp/log
```

**Audience sees:** tool names (Bash, Read...) then dollar amount.

**Say:** Every tool call logged. Every dollar tracked. Same shape as `/stats`.

---

## 3. GHA LIVE DEMO — 14 min · the star

This lands during Slide 07 (Module 04). Six beats.

### Beat 1 · Show workflow files on GitHub (90 s)

Switch to Actions tab.

Point at the sidebar. Six workflows:
- `01 · non-interactive claude`
- `02 · structured output`
- `03 · pre-commit mirror (leak + pulse-align)`
- `04 · parallel CI (test + lint + claude review)`
- `05 · nightly Claude audit + cost`
- `Claude Code` — the `@claude` mention handler

Click into `04-parallel-ci.yml`. Show the 3 jobs — no `needs:` between them.

**Say:** Three lanes. Concurrent by default. Claude joins the party.

### Beat 2 · Trigger the pipeline with one push (60 s)

Switch to terminal:

```bash
cd ~/session-13-lab
git checkout demo-day
echo "# trigger $(date +%s)" >> module-04-parallel-ci/demo-note.md
git add module-04-parallel-ci/demo-note.md
git commit -m "demo: fire GHA"
git push
```

Switch to Actions tab. Refresh. New runs appear at top for `03 · pre-commit mirror` and `04 · parallel CI`.

**Say:** Two workflows fired on that one push — the leak-check and the parallel review.

### Beat 3 · Watch 3 parallel jobs run concurrently (3 min)

Click into the `04 · parallel CI` run. Three job cards side-by-side: `test`, `lint`, `claude-review`.

Point at start times — all identical.

**Say:** Test simulates 15s. Lint 8s. Claude reviews the diff. Total wall clock ≈ 15s. Not 45.

Wait for jobs to finish. Refresh Actions tab periodically.

### Beat 4 · Claude's PR comment lands (60 s)

When `claude-review` job goes green, switch to PR #2 tab. Refresh.

Look for a comment titled `🤖 Claude review` w/ findings on `buggy.py`.

**Say:** Claude wrote JSON in the CI step. `actions/github-script` posted it here. Devs see it inline with the diff they're reviewing anyway.

### Beat 5 · The `@claude` mention (5 min · the "wow" moment)

Type in the PR comment box (bottom of the PR):

```
@claude explain what module-01-non-interactive/demo.sh does in one paragraph
```

Post the comment.

Switch to Actions tab. New run appears: `Claude Code`. Fires within ~10 s.

**Say:** This is the GitHub App plugin. No API key in the repo — auth lives on Anthropic's side, wired through a secret created by `/install-github-app`. Same as tagging a teammate.

Wait ~45 s for the job to finish. Switch to PR. Claude's reply appears as a new comment.

**Say:** Full agent — Read, Grep, Bash. Not just chat. Ask it to fix something and it opens a follow-up PR.

**Bolder demo (optional if time):**
```
@claude add a docstring to divide() in module-04-parallel-ci/buggy.py
```

Wait for the workflow. Claude commits directly to the demo branch. PR shows the new commit.

### Beat 6 · M05 nightly view (90 s)

Switch to Actions tab. Click `05 · nightly Claude audit + cost` on the left sidebar.

**Say:** Cron. Runs every night at 03:17 UTC. Silent. This tab is the accountability surface.

Click the most recent run OR trigger one via workflow_dispatch button (top-right).

Scroll to the run's "Summary" section. Show the auto-generated markdown:
- **Audit cost** $0.xxxx
- **Tool calls** list

**Say:** Same `stream-json` from our terminal, parsed by `jq`, dumped to `$GITHUB_STEP_SUMMARY`. GitHub is the dashboard. No new tool.

**Wrap the GHA segment:**

Push triggers M03 leak check + M04 parallel review + Claude comment on PR. `@claude` mentions get an agent. Nightly cron rolls up cost. Every primitive from Modules 01-05 wired end-to-end.

---

## 4. Applied arc — Pulse tour · 20 min · screen-share

### Divider slide (30 s)

**Say:** Now the same tricks at Seven-Gen scale. Nothing new. Just how the primitives are arranged.

### Slide 09 · M06 Pulse walkthrough (3 min)

Screen-share Pulse `/deploy`. Walk the 5-step flow (fill / submit / approve / watch / secrets). Don't submit.

### Slide 10 · M06b Form details (3 min)

Walk the table. Highlight the gotcha: form BLOCKS submit if repo lacks `components.yml`. That's `/pulse-align` — Module 03 all over again.

### Slide 11 · M07 Tag lifecycle (3 min)

Walk the tag table. `v0.0.N` on every submit. Old failed record marked `superseded`. No destructive re-cuts.

### Slide 12 · M07b Spec lookup (3 min)

Three tiers: exact / env / slug. Every tag maps to exactly one spec.

### Slide 13 · M07c Tracker UI (3 min)

Screen-share a live tracker. Sidebar stages / right-panel command rows / Rerun button.

### Slide 14 · M07d Infisical (3 min)

Manifests carry zero values. Bootstrap on approve. Runtime = operator resync 60 s. `/dashboard/infisical` for audit.

### Slide 15 · M07e Cluster topology (2 min)

kl-1 (server), kl-2 (operator), net4 (self-contained). VPN required.

---

## 5. Wrap · 12 min

### Slide 16 · M08 Failure paths (3 min)

Four common failures. Screen-share a failed tracker. Rerun dialog demo.

### Slide 17 · M09 Capstone (4 min)

Walk the 5 steps. Bonus: add M04 parallel Claude review to your own Jenkinsfile.

### Slide 18 · Wrap (3 min)

Recap. Bookmarks. Open Q&A.

### Buffer (7 min)

Absorb slippage. Answer questions.

---

## 6. Recovery cheat sheet

| Failure | Action |
|---------|--------|
| `claude` hangs mid-demo | Ctrl-C. `cat /tmp/s13/*.txt`. Keep tempo. |
| GHA job queued >60s | Talk through YAML on screen. Skip live wait. |
| Claude action errors mid-demo | Open a previous successful run. Show that. |
| `@claude` reply hangs | "Sometimes queue is slow." Move to Beat 6. |
| Everything dies | Revert to terminal-only demo. All local one-liners still run. |
| Pulse UI unreachable | Screen-share screenshots in the deck. |
| Network dies entirely | Q&A first. Read capstone. Dismiss early. |

---

## 7. Post-demo cleanup

```bash
cd ~/session-13-lab
gh pr close 2 --delete-branch 2>/dev/null || true
git checkout main
git branch -D demo-day 2>/dev/null || true
git push origin --delete demo-day 2>/dev/null || true
```

Or keep demo-day around for next session — just reset the trigger file.

---

## 8. Micro-scripts (memorised, delivered fast)

- "Interactive is one deployment mode. Shell is another."
- "CI doesn't read English. It reads exit codes and JSON."
- "Shift Claude LEFT. Every arrow left is cheaper."
- "Wall clock = max, not sum."
- "Five human clicks. Everything else automated."
- "Every submit cuts a NEW tag. Never a re-cut."
- "Manifests carry ZERO secret values."
- "Every green demo has a red twin."
- "GitHub is the dashboard."

---

## 9. What the audience should walk away able to do

- Fire `claude -p` inside any shell script
- Parse `--output-format json` w/ `jq`
- Install a pre-commit hook that gates on Claude
- Add a parallel Claude review job to a GHA workflow
- Read `stream-json` output + roll up cost
- Submit a repo via Pulse form → watch tracker → intervene on failure
- Debug a wrong-cluster manual Jenkins rerun via the spec endpoint
- Populate secrets in Infisical UI without touching manifests

---

## 10. Reference

- Deck: `manComm/07-20-26/training/cicd-pulse-tutorial-slides.html`
- Presenter script (this file's older sibling): `manComm/07-20-26/training/presenter-script.md`
- One-liners: `ONELINERS.md` + `ONELINERS.html`
- GHA-specific choreography: `GHA_DEMO_FLOW.md`
- Skills: `~/.claude/plugins/marketplaces/seven-gen/`
- Pulse repos: `~/pulse` · `~/manifests-seven-gen-v2`
- Anthropic docs: docs.anthropic.com/en/docs/claude-code
