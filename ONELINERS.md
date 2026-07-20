# Session 13 — one-liner presenter kit

Per module: syllabus goal → commands to type → what audience sees → how to connect it to CI/CD. Pastes verbatim in front of the room. Runs against local Claude Code CLI (Pro sub), no API key.

---

## The 30-second framing (whiteboard this first)

```
    laptop  →  commit  →  push  →  CI build  →  deploy
       ↑         ↑          ↑         ↑           ↑
      M01       M03        M02      M04         M05
     M02
```

**Say:** "CI/CD pipelines are just shells firing tools in sequence. Today we make Claude one of those tools. Five modules = five places to plant it. Local dev, commit gate, push, build stage, post-hoc observability. Same primitive everywhere: `claude -p`."

---

## Module 1 of 5 · `claude -p` for non-interactive queries

**Syllabus:** *`claude -p "prompt"` for non-interactive one-off queries inside shell scripts and pipeline stages.*

### Type
```bash
claude -p "reply READY"
```

### Audience sees
`READY`

### Pitch
> "Every CI stage is a shell command. If Claude can be a shell command, Claude can be a CI stage. That's the whole hook — the rest of today is what you *do* with that."

---

## Module 2 of 5 · Structured output

**Syllabus:** *`--output-format json` and `stream-json` for programmatic parsing — pipe Claude's structured output into downstream scripts.*

### Type
```bash
claude -p "list 3 python files here" --output-format json
```

### Then prove it's parseable
```bash
claude -p "list 3 python files here" --output-format json | jq -r '.result'
```

### Audience sees
JSON blob → clean text-only answer.

### Pitch
> "CI doesn't read English — it reads exit codes and JSON. This flag turns Claude into a service other tools can consume: PR comments, Slack notifications, dashboards, anything."

---

## Module 3 of 5 · Pre-commit hooks

**Syllabus:** *Using Claude in pre-commit hooks: automated security scan, lint fix suggestion, and test stub generation on every commit.*

### Type (fresh sandbox)
```bash
mkdir /tmp/hook && cd /tmp/hook && git init
```

### Install a Claude-powered hook
```bash
cat > .git/hooks/pre-commit <<'EOF'
#!/bin/bash
git diff --cached | claude -p "reply BLOCK if you see any api token, else PASS" | grep -q PASS
EOF
chmod +x .git/hooks/pre-commit
```

### Trigger it
```bash
echo "token=ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZ012345" > secret.txt
git add secret.txt
git commit -m "test"
```

### Audience sees
Commit blocked. Token never reaches remote.

### Pitch
> "This is CI shifted **left** — check runs on your laptop before the code leaves your machine. Same check we could run in GitHub Actions later, but caught 5 minutes earlier. Free."

---

## Module 4 of 5 · Parallel CI stages

**Syllabus:** *Running parallel Claude sessions as separate CI stages — frontend build and backend test simultaneously in GitHub Actions.*

### Type (one line, three concurrent processes)
```bash
time { (sleep 3 && echo "test done") & (sleep 2 && echo "lint done") & (claude -p "one bug in: def div(a,b): return a/b" && echo "claude done") & wait; }
```

### Audience sees
- Three "done" lines land at different times
- `real 5.something` at the end (not 10)

### Pitch
> "Test slept 3, lint slept 2, Claude took 5. Wall-clock = **max**, not sum. Same trick in GitHub Actions — jobs without `needs:` run in parallel. Same trick in Jenkins — `parallel { }` block. Adding Claude to your CI costs zero minutes if your slowest existing job is already slower than Claude."

### Optional — show the GHA equivalent
```bash
cat ~/session-13-lab/.github/workflows/04-parallel-ci.yml
```
> "Same three-way parallelism, in GitHub Actions syntax."

---

## Module 5 of 5 · Monitoring background agents

**Syllabus:** *Monitoring background agent activity via `/stats` and log streaming — know what Claude is doing in unattended runs.*

### Type (writes an audit log)
```bash
claude -p --output-format stream-json --verbose "count files in current dir" > /tmp/log
```

### See what Claude did
```bash
jq -r '.message.content[]? | select(.type=="tool_use") | .name' /tmp/log
```

### See what it cost
```bash
jq -r 'select(.type=="result") | .total_cost_usd' /tmp/log
```

### Audience sees
- List of tool names Claude used (`Bash`, `Read`, `Grep`, etc.)
- A dollar amount (e.g. `0.0281`)

### Pitch
> "When you fire Claude in CI, you're not watching. This is how you know what it did after the fact — every tool call logged, every dollar accounted for. Same shape as `/stats` inside interactive Claude, just readable by scripts."

---

## Recovery cheat sheet

| Failure | What to say |
|---|---|
| Claude call hangs | "API's slow today, moving on" — Ctrl-C, skip |
| jq errors on output | Show raw output with `cat`, narrate what should have parsed |
| Hook doesn't block commit | Check `chmod +x .git/hooks/pre-commit` was run |
| Everything breaks | Open this file (`ONELINERS.md`) and walk audience through it as documentation |

## Pre-flight (30 sec before session)

Warm the CLI so first live call is fast:
```bash
claude -p "hi" > /dev/null
```
