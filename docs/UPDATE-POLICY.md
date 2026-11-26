# Update policy

Maintained by **Daniel G. Cosenza from FNX Labs**. Back to the [README](https://github.com/dgcosenza/flame-docker#readme).

[`.github/workflows/daily.yml`](https://github.com/dgcosenza/flame-docker/blob/main/.github/workflows/daily.yml) runs automatically every day at **04:17 UTC**, on pushes to `main`, on pull requests (verification only, without pushing), and via `workflow_dispatch`. Every scheduled run executes a seven-step automated pipeline (gated by `.github/workflows/public-check.yml`):

1. **Upstream check:** Resolves the latest active Node.js LTS release published on Docker Hub for `trixie-slim`, checks `AlexStapleton/Flame-Revamped` via the authenticated GitHub API, compares against `versions.json`, and emits an `upstream-changes.md` artifact.
2. **No-cache rebuild:** Rebuilds `linux/amd64` with `--no-cache` on schedule, runs `apt-get update && apt-get -y upgrade`, updates client and server npm dependencies, rebuilds the Vite frontend, compiles native `sqlite3` from source, executes the full test suite, and generates an **SPDX SBOM** (`sbom.spdx.json`) and build provenance artifact.
3. **Vulnerability fix and gate:** Enforces `npm audit --audit-level=low` = **0**, runs **Trivy** (table, JSON, SARIF upload to Code Scanning, and blocking `--ignore-unfixed` gate) and **Grype** (blocking `--only-fixed` gate, severity cutoff `high`), diffs findings against the previous scan to record resolved CVEs, and retains scan reports for 90 days.
4. **Smoke test:** Executes [`tests/smoke.sh`](https://github.com/dgcosenza/flame-docker/blob/main/tests/smoke.sh) to verify non-root UID `1000` startup, HTTP 200 on `/` and `/health`, `healthcheck.js` pass/fail behavior (including a negative dead-port test), and `0600` permissions on `data/.secret`.
5. **Publish:** On non-PR builds when registry credentials are configured, pushes `latest`, `<version>`, `<version>-<YYYYMMDD>`, `<version>-<commit>`, `<version>-<commit>-<YYYYMMDD>`, and `sha-<short>` tags to Docker Hub and records the immutable digest.
6. **Automated documentation sync:** Commits updated `versions.json`, the README `Current Versions` block, and a dated `CHANGELOG.md` entry (upstream changes, resolved CVEs, and digest) via `github-actions[bot]` with `[skip ci]` when content changes, then syncs the Docker Hub repository overview and short description via `peter-evans/dockerhub-description`.
7. **Failure alerting:** If any step fails on `main` or a scheduled run, CI opens or updates a single GitHub issue labeled `ci-failure` with the failing job and run link, and automatically closes it on the next green run.

**Deployment pickup:** Pin deployments by digest and promote new digests only after verifying the container healthcheck, keeping the previous digest available for rollback. Avoid unpinned `:latest` pulls and automatic updaters such as Watchtower.
