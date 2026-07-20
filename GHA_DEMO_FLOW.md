# Session 13 — Live GHA demo flow

Repo now wired to GitHub + Anthropic GitHub App. Every module can fire against real CI. This doc = presenter choreography for the live GHA sub-segment inside the Modules 04–05 slides.

Substrate:
- Repo: `github.com/SeoulX/session-13-lab`
- Anthropic app: installed
- Workflows: `.github/workflows/*.yml`
- New: `claude-mention.yml` handles `@claude` comments

---

## Module → workflow → trigger

| Module | Workflow file | Fires on |
|--------|---------------|----------|
| M01 non-interactive | `01-non-interactive.yml` | manual dispatch or PR touching `module-01-*` |
| M02 structured output | `02-structured-output.yml` | manual dispatch or PR touching `module-02-*` |
| M03 pre-commit mirror | `03-precommit-mirror.yml` | every PR |
| M04 parallel CI | `04-parallel-ci.yml` | every PR (3 jobs in parallel) |
| M05 nightly audit | `05-monitoring.yml` | cron 03:17 UTC or manual dispatch |
| Bonus · `@claude` mention | `claude-mention.yml` | PR/issue comment containing `@claude` |

---

## Pre-session prep (10 min before start)

Run once, keep tabs open:

```bash
cd ~/session-13-lab
# Fresh branch w/ trivial buggy diff so M04 Claude review has something to find
git checkout -b demo-day
cat > module-04-parallel-ci/buggy.py <<'EOF'
def divide(a, b):
    # Missing zero-check — Claude should flag
    return a / b

def parse_age(s):
    # Silent int() crash on empty string
    return int(s)
EOF
git add module-04-parallel-ci/buggy.py
git commit -m "demo: seed buggy code for Claude review"
git push -u origin demo-day
gh pr create --title "Demo — Session 13 live" --body "Live demo target. @claude will review here." --base main --head demo-day
```

Bookmark these tabs:
1. `https://github.com/SeoulX/session-13-lab/actions` — Actions dashboard
2. The demo PR page
3. `https://github.com/SeoulX/session-13-lab/actions/workflows/04-parallel-ci.yml` — direct link to parallel workflow runs

Warm the CLI locally too:

```bash
claude -p "hi" > /dev/null
```

---

## Live segment — 12 min slotted into Slide 07 (Module 04)

### Beat 1 · Show the workflow files on GitHub (60 s)

Open Actions tab. Point at the 5 named workflows in the sidebar.

> "Five files, one per module. Same shape as what we just ran locally — now living in CI."

Click into `04-parallel-ci.yml` on the left. Show YAML:

> "Three jobs, no `needs:` between them. Concurrent."

### Beat 2 · Fire the whole pipeline w/ one push (90 s)

Switch to terminal:

```bash
cd ~/session-13-lab
echo "# trivial change to trigger CI" >> module-04-parallel-ci/README.md
git add module-04-parallel-ci/README.md
git commit -m "demo: trigger parallel run"
git push
```

Switch to browser Actions tab. New workflow run appears at top.

> "Three jobs just started at the same second. Wall clock will be the max, not the sum."

### Beat 3 · Watch the jobs run in parallel (2 min)

Click into the run. Show the 3 job cards side-by-side. Point at start times — all identical.

> "Test simulates 15 seconds, lint 8 seconds, Claude reviews the diff. In real life these are your actual jobs — swap `sleep` for `npm test`, `eslint`, whatever. Claude is one lane. Never blocks."

Wait for jobs to finish. When Claude review job goes green, click into it.

Point at the "Comment findings on PR" step.

> "Claude wrote JSON. `actions/github-script` posted it to the PR."

### Beat 4 · Show the PR comment (60 s)

Switch to the demo PR tab. Refresh. Claude comment should be there w/ findings on `buggy.py`.

> "This is where devs see it. Inline with the code they're reviewing anyway. No new dashboard to check."

### Beat 5 · Live `@claude` mention (3 min · the wow moment)

Type in the PR comment box:

```
@claude explain what module-01-non-interactive does in one paragraph
```

Post. Switch to Actions tab — `claude (@mention)` workflow fires within 10 s.

> "This is the GitHub App plugin. No API key in the repo — auth lives on Anthropic's side. Same as tagging a teammate."

Wait ~30 s. Switch back to PR. Claude reply appears as a comment.

> "Full agent — Read, Grep, Bash. Not just chat. Ask it to fix something and it opens a follow-up PR."

Optional bolder demo — post:

```
@claude add a docstring to divide() in module-04-parallel-ci/buggy.py
```

Wait. Claude commits directly to the demo branch.

### Beat 6 · M05 — the nightly view (90 s)

Switch back to Actions tab. Click `05 · nightly Claude audit + cost` on the left.

> "Runs on cron. Every night at 03:17 UTC — silent. This tab is the accountability surface. Every run, every dollar, every tool call."

Click a previous run (or manually dispatch one now). Show the "Summary" section — cost + tool-call list rendered as markdown.

> "Same `stream-json` we saw in the terminal, parsed by `jq`, dumped to `$GITHUB_STEP_SUMMARY`. No dashboard to build — GitHub is the dashboard."

Wrap:

> "That's the arc, wired end-to-end. Push triggers M03 leak check + M04 parallel review, comments show up on the PR, nightly audit rolls up cost. Every primitive from the first half of the session — same commands, different runner."

---

## Timing budget

- Beat 1 60s
- Beat 2 90s
- Beat 3 120s
- Beat 4 60s
- Beat 5 180s
- Beat 6 90s
- Total 10 min live · fits Module 04 slot w/ 2 min buffer

## Recovery script

| Failure | Fallback |
|---------|----------|
| GHA queued > 60s | Talk through the YAML on screen, skip live wait |
| Claude action errors | Show a previous successful run's logs, keep tempo |
| @claude reply hangs | "Sometimes the workflow queue is slow" — move to Beat 6 |
| All GHA dies | Revert to terminal — every module's script runs locally |

## Post-demo cleanup

```bash
cd ~/session-13-lab
gh pr close --delete-branch $(gh pr view demo-day --json number -q '.number' 2>/dev/null) 2>/dev/null || true
git checkout main
git branch -D demo-day 2>/dev/null || true
git push origin --delete demo-day 2>/dev/null || true
```

---

## Why this beats the terminal-only version

Terminal-only demo proves Claude runs non-interactively. GHA demo proves the CI substrate you already pay for hosts Claude as a first-class citizen — no ops work, no new tool to learn, no dashboard to build. Same 5 primitives from Modules 01–05, now visible to every dev on every PR.
