# Capstone

## Goal
Ship a real tag through Pulse using everything from Modules 01–05.

## Task list

1. **Clone the demo app** (separate repo):
   ```bash
   git clone git@bitbucket.org:metawhale/pulse_demo_app.git
   cd pulse_demo_app
   ```
2. **Install the Module 03 hook** into `pulse_demo_app`:
   ```bash
   ~/session-13-lab/module-03-hooks/install.sh
   ```
3. **Add the Module 04 Jenkins stage** to your `Jenkinsfile.default` (or the org default if you don't own the Jenkinsfile).
4. **Submit via Pulse form** at `https://pulse.media-meter.in/deploy`:
   - Cluster: `kl-1`
   - Envs: `staging`
   - Provision Infisical: **ON**
5. **Have DevOps approve** in `#devops`.
6. **Open the tracker URL** → watch stages advance. Screenshot the tracker's right panel showing the Claude review row.
7. **Drop screenshot in `#training`.**

## Verify

```bash
./verify.sh
```

Prints ✓ per completed step. Fail = which step to redo.
