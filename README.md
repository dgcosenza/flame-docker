# Flame — Hardened Debian 13 (trixie) / Node.js LTS Image

[![Daily Build, Scan, and Publish](https://github.com/dgcosenza/flame-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/flame-docker/actions/workflows/daily.yml)
[![Packaging License: MIT](https://img.shields.io/badge/packaging-MIT-blue.svg)](https://github.com/dgcosenza/flame-docker/blob/main/LICENSE)
[![Upstream License: MIT](https://img.shields.io/badge/upstream-MIT-green.svg)](https://github.com/AlexStapleton/Flame-Revamped/blob/main/LICENSE)
[![Signed with Cosign](https://img.shields.io/badge/signed-cosign%20OIDC-blueviolet.svg)](#supply-chain-verification)
[![SLSA Level 3](https://img.shields.io/badge/SLSA-Level%203-brightgreen.svg)](#supply-chain-verification)
[![Architectures](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-informational.svg)](#supported-architectures)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/dgcosenza/flame-docker/badge)](https://scorecard.dev/viewer/?uri=github.com/dgcosenza/flame-docker)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/17158/badge)](https://www.bestpractices.dev/projects/17158)
[![Docker Pulls](https://img.shields.io/docker/pulls/dgcosenza/flame)](https://hub.docker.com/r/dgcosenza/flame)
[![Docker Image Size](https://img.shields.io/docker/image-size/dgcosenza/flame/latest)](https://hub.docker.com/r/dgcosenza/flame)
[![Latest Release](https://img.shields.io/github/v/release/dgcosenza/flame-docker?label=version)](https://github.com/dgcosenza/flame-docker/releases)

A hardened, actively maintained container image for **Flame** (self-hosted startpage and dashboard), built on **Debian 13 (trixie)** and the **latest active Node.js LTS** runtime, maintained by **Daniel G. Cosenza from FNX Labs**.

- **Docker Hub:** [`dgcosenza/flame`](https://hub.docker.com/r/dgcosenza/flame)
- **GitHub Container Registry (GHCR):** [`ghcr.io/dgcosenza/flame`](https://github.com/dgcosenza/flame-docker/pkgs/container/flame) (identical signed multi-arch digest)
- **Source Repository:** [`dgcosenza/flame-docker`](https://github.com/dgcosenza/flame-docker)
- **Upstream Application:** [`AlexStapleton/Flame-Revamped`](https://github.com/AlexStapleton/Flame-Revamped) `v2.1.0` (fork of [`pawelmalak/flame`](https://github.com/pawelmalak/flame))
- **License:** MIT

---

## Overview

The official [`pawelmalak/flame`](https://github.com/pawelmalak/flame) `v2.4.0` image ships end-of-life Node.js 20 on Alpine alongside outdated dependencies (deprecated `react-scripts` 5, legacy `multer` 1.x, `axios` 0.24, `jsonwebtoken` 8.x, `express` 4.17) and unpatched application security issues.

`dgcosenza/flame`, maintained by **Daniel G. Cosenza from FNX Labs**, provides a drop-in, production-hardened Flame image on **Debian 13 (trixie)** + **Node.js 26 LTS (*Lithium*)**:

- **Maintained application base:** Built from a commit-pinned checkout of [`AlexStapleton/Flame-Revamped`](https://github.com/AlexStapleton/Flame-Revamped) (`v2.1.0`, commit `0d6221d8`), modernizing Flame to **Express 5**, **Sequelize 6**, **sqlite3 6** (bundled SQLite 3.52), **React 19**, **Vite 8**, and **TypeScript 7** with 250+ automated tests and XSS/CSP/auth hardening while preserving the classic Flame layout and SQLite data model.
- **Current OS and runtime:** Based on official `node:<LTS>-trixie-slim` (latest Debian 13 point release, 13.8 as of 2026-11-24), upgraded via `apt-get update && apt-get -y upgrade` at build time, with native `sqlite3` compiled from source against Debian 13 glibc and Node 26.
- **Zero-vulnerability build gates (all severities with a fix):** Both server and frontend dependencies are updated at build time, the Vite frontend is rebuilt from source, all unit tests run during build, `npm audit --audit-level=low` must report **0 vulnerabilities** on client and server, and Trivy must report **0 fixable vulnerabilities of any severity** before publication.
- **Audited packaging patches (`patches/`):**
  1. `01-secrets-and-startup.patch` — Loads `/run/secrets/*` and `PASSWORD_FILE` / `SECRET_FILE` before secret initialization and password validation, supporting secret-only deployments without plaintext `PASSWORD` env vars.
  2. `02-dot-secret-compat.patch` — Preserves `pawelmalak/flame`'s `data/.secret` (with fallback to `Flame-Revamped`'s `data/secret.key`) and writes newly generated secret files with mode `0600`.
  3. `03-mass-assignment-allowlists.patch` — Enforces explicit field allowlists in app, bookmark, and category create/update controllers (mitigating CWE-915).

---

## Current Versions

<!-- versions:start -->
| Component | Resolved Version |
| --- | --- |
| Flame-Revamped | `2.1.0 (0d6221d8)` |
| Node.js LTS | `26.13.1` |
| Base OS | `Debian 13.8 (trixie-slim)` |
| Architectures | `linux/amd64, linux/arm64` |
| Uncompressed size (per arch) | `amd64: 114.2 MB, arm64: 411.6 MB` |
| Last verified build (UTC) | `2026-11-26` |
| Published multi-arch digest | `dgcosenza/flame@sha256:ffe8e0ebf7dc0d1c0ae56100b7101fce21a46e32887bf70580257e04d21e993f` |
| GHCR mirror | `ghcr.io/dgcosenza/flame@sha256:ffe8e0ebf7dc0d1c0ae56100b7101fce21a46e32887bf70580257e04d21e993f` |
| Supply chain | Cosign OIDC signed + SPDX & CycloneDX SBOM attestations + SLSA Build L3 provenance |
| Security gate (Trivy + Grype on SBOM) | **0 fixable findings of any severity** (13 upstream-unfixed) |
<!-- versions:end -->

---

## Tags and Versioning Policy

| Tag | Policy | Description |
| --- | --- | --- |
| `<version>-<commit>-<YYYYMMDD>` (e.g. `2.1.0-0d6221d8-20261124`) | **Immutable** | Point-in-time build pinning the upstream release, commit, and build date. |
| `<version>-<YYYYMMDD>` (e.g. `2.1.0-20261124`) | **Immutable** | Date-stamped daily security rebuild. |
| `sha-<short>` | **Immutable** | Packaging repository commit tag. |
| `<version>-<commit>` (e.g. `2.1.0-0d6221d8`) | Moving (same commit) | Latest verified Debian 13 / Node LTS security rebuild of that commit. |
| `<version>` (e.g. `2.1.0`) | Moving (patch line) | Latest verified build in the `2.1.0` line. |
| `latest` | Moving | Latest verified Debian 13 / Node LTS build passing all audit, test, Trivy, and Grype gates. |

**Production pinning:** Pin by **registry digest** rather than pulling unpinned `:latest`:

```yaml
image: dgcosenza/flame:latest@sha256:<digest>
```

Images publish `org.opencontainers.image.version` (e.g. `2.1.0`) so digest-checking and major-version-guarded promotion scripts can adopt Debian/Node security rebuilds cleanly while holding major upgrades for manual review.

---

## Supported Architectures

| Architecture | Status | Verification |
| --- | --- | --- |
| `linux/amd64` | **Published & natively tested** | Built, smoke-tested, Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native x86_64 CI runners. |
| `linux/arm64` | **Published & natively tested** | Built, smoke-tested, Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native ARM64 CI runners. |

Identical multi-arch OCI manifest digests are published to **Docker Hub** and **GHCR** (`ghcr.io/dgcosenza/*`), accompanied by automated signed [GitHub Releases](https://github.com/dgcosenza/flame-docker/releases).
---

## Quick Start

The container runs as non-root `node` (**UID/GID `1000:1000`**). Prepare host directories and a secret password file first:

```bash
mkdir -p ./data ./secrets
chown -R 1000:1000 ./data
printf '%s\n' 'replace-with-a-strong-unique-password' > ./secrets/password
chmod 600 ./secrets/password
```

### `docker run` (LAN-only bind)

```bash
docker run -d \
  --name flame \
  --restart unless-stopped \
  --security-opt no-new-privileges:true \
  -p 192.0.2.10:5005:5005 \
  -e PASSWORD_FILE=/run/secrets/password \
  -v "$(pwd)/data:/app/data" \
  -v "$(pwd)/secrets/password:/run/secrets/password:ro" \
  --cpus 1.00 \
  --memory 256m \
  dgcosenza/flame:latest
```

Open `http://192.0.2.10:5005/`, click the gear icon (bottom-left), go to **App**, and log in using the password in `./secrets/password`.

### Docker Compose (recommended)

See also [`docker-compose.example.yml`](https://github.com/dgcosenza/flame-docker/blob/main/docker-compose.example.yml):

```yaml
services:
  flame:
    # Pin by @sha256 digest in production:
    image: dgcosenza/flame:latest
    container_name: flame
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    ports:
      # LAN-only bind: replace with your host's private LAN IP
      - "192.0.2.10:5005:5005"
    environment:
      - NODE_ENV=production
      - PASSWORD_FILE=/run/secrets/password
      # - TRUST_PROXY=1         # Set hop count only behind a reverse proxy
      # - CSP=on                # Set "off" only if custom CSS/assets break under CSP
      # - NODE_USE_ENV_PROXY=1  # Honour HTTP_PROXY / HTTPS_PROXY for outbound widget calls
    secrets:
      - password
    volumes:
      - ./data:/app/data
      # - ./log:/app/log        # Optional persistent access.log (e.g. fail2ban)
    healthcheck:
      test: ["CMD", "node", "/app/healthcheck.js"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    deploy:
      resources:
        limits:
          cpus: "1.00"
          memory: 256M

secrets:
  password:
    file: ./secrets/password
```

---

## Environment Variables

At startup, `/run/secrets/*` files are loaded into uppercase environment variables first, followed by explicit `*_FILE` variables (`PASSWORD_FILE`, `SECRET_FILE`).

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `PASSWORD` | Yes* | *(none)* | Admin password. Flame refuses to start if unset via env, `PASSWORD_FILE`, or `/run/secrets/password`. Changing it invalidates all active sessions. |
| `PASSWORD_FILE` | Yes* | *(unset)* | Path to a file containing the admin password (trimmed). Preferred over plaintext `PASSWORD` (e.g. `/run/secrets/password`). |
| `SECRET` | No | Auto-generated | HS256 JWT signing key. When unset (or `CHANGE_ME`), Flame loads `data/.secret` (or `data/secret.key`), or generates a 64-byte random hex key in `data/.secret` (`0600`). |
| `SECRET_FILE` | No | *(unset)* | Path to a file containing the JWT signing key. |
| `PORT` | No | `5005` | Internal HTTP/WebSocket listening port (also read by `/app/healthcheck.js`). |
| `NODE_ENV` | No | `production` | Node runtime mode (`production` in image; `development` for local debugging only). |
| `TRUST_PROXY` | No | `false` | Trusted reverse-proxy hop count (e.g. `1` behind nginx/Traefik) so rate limiting and `access.log` see real client IPs. |
| `CSP` | No | `on` | Set to `off` to disable the `Content-Security-Policy` header (logs a startup warning). |
| `NODE_USE_ENV_PROXY` | No | *(unset)* | Set to `1` to route outbound Weather/Pi-hole/Calendar requests via `HTTP_PROXY` / `HTTPS_PROXY`. |
| `/run/secrets/<name>` | No | *(none)* | Each mounted secret sets uppercase `<NAME>` (e.g. `/run/secrets/password` overrides `PASSWORD`). |

*\*At least one of `PASSWORD`, `PASSWORD_FILE`, or `/run/secrets/password` is required.*

---

## Ports and Network Exposure

> Examples use `192.0.2.10` (an RFC 5737 documentation address) as the host LAN IP; replace it with your own.

Flame listens on container port **`5005/tcp`** (HTTP UI, REST API `/api/*`, `/health`, and WebSocket `/socket`).

- **LAN-only bind (recommended):** `"192.0.2.10:5005:5005"` — accepts traffic solely on the host's LAN interface (rejects `127.0.0.1`, VPN, and WAN).
- **Localhost-only (behind a same-host reverse proxy):** `"127.0.0.1:5005:5005"`.
- **All interfaces:** `"5005:5005"` — use only with an explicit host firewall.

---

## Volumes and Data Layout

### `/app/data` (required persistent volume)

| Path | Back up? | Mode / Owner | Purpose |
| --- | --- | --- | --- |
| `db.sqlite` (+ `-wal`, `-shm`) | **Yes** | `1000:1000` | SQLite database (WAL mode): apps, categories, bookmarks, weather cache, `SequelizeMeta`. |
| `config.json` | **Yes** | `1000:1000` | UI and integration settings (title, theme, ordering, layout columns, Weather/Pi-hole/Calendar settings and API keys). |
| `themes.json` | **Yes** | `1000:1000` | Built-in and custom color themes. |
| `customQueries.json` | **Yes** | `1000:1000` | Custom search bar providers and prefixes. |
| `.secret` *(or `secret.key`)* | **Yes (sensitive)** | `0600` `1000:1000` | Persistent HS256 JWT signing key. Never commit or print. |
| `flame.css` | **Yes** | `1000:1000` | Custom CSS (copied to `/app/public/flame.css` at startup and on save). |
| `uploads/` | **Yes** | `1000:1000` | Uploaded custom icons (PNG, JPEG, ICO, SVG — served with `nosniff` + sandbox CSP). |
| `db_backups/` | Optional | `1000:1000` | Automatic pre-migration copies of `db.sqlite`. |

### `/app/log` (optional)

Stores Apache-combined HTTP access logs (`/app/log/access.log`, excluding `/health`). Mount a host folder if you need persistent logs or `fail2ban`.

Because the container runs as non-root **`node` (UID/GID `1000`)** without root `chown` at startup, ensure host ownership matches:

```bash
chown -R 1000:1000 /path/to/flame/data
chmod 600 /path/to/flame/data/.secret
```

---

## Configuration

All settings are managed in the web UI (**Settings**, bottom-left gear icon):

- **Database (`data/db.sqlite`):** Applications, categories, bookmarks, pin flags, ordering, guest visibility (`isPublic`), optional per-app HTTP status checks, and cached weather.
- **Files (`data/`):** `config.json` (title, theme, search providers, layout width/columns defaulting to 75% / 4×4 matching classic Flame, Docker/Kubernetes sync, optional Weather/Pi-hole/Calendar widgets), `themes.json`, `customQueries.json`, and `flame.css`.
- **Guest vs. Admin access:** Public apps/categories/bookmarks are visible without login. Private items, all write endpoints, Weather, Pi-hole, and (by default) Calendar require admin login. Unauthenticated `GET /api/config` masks `WEATHER_API_KEY`, coordinates, `PIHOLE_SECRETS`, and `CALENDAR_SECRETS`.

---

## Upgrading and Migrating from `pawelmalak/flame`

This image is a data-compatible upgrade from `pawelmalak/flame` (`v2.3.x` / `v2.4.0`). It reuses `data/.secret`, preserves `config.json`, and applies four additive, reversible SQLite migrations (`06_indexes.js` to `09_weather-details.js`) after saving an automatic backup in `data/db_backups/`.

Key points (full step-by-step cutover, verification and rollback in [`docs/MIGRATION.md`](https://github.com/dgcosenza/flame-docker/blob/main/docs/MIGRATION.md)):

- Keep a full copy of `data/` and tag the outgoing image before switching.
- Ensure `./data` is owned by UID `1000`.
- Replace the Compose `healthcheck.test` with `["CMD", "node", "/app/healthcheck.js"]`.
- Pin by digest and recreate only the `flame` service.
- Expect a one-time re-login (legacy JWTs lack the `pwf` claim).

---

## Backup and Restore

SQLite runs in WAL mode, so stop the container briefly before archiving `/app/data` (`docker compose stop flame`, archive `data/` with `tar --numeric-owner`, then start it again). The built-in GUI backup excludes secrets (`data/.secret`, `PASSWORD`, API keys); use filesystem backups for complete recovery. Exact commands for backup and restore: [`docs/BACKUP-RESTORE.md`](https://github.com/dgcosenza/flame-docker/blob/main/docs/BACKUP-RESTORE.md).

---

## Supply-Chain Verification

Every published digest (multi-arch index and per-architecture manifests) on both Docker Hub and GHCR is keyless-signed with **Sigstore Cosign** (GitHub OIDC), attested with **SPDX** and **CycloneDX** SBOMs, and backed by **SLSA Build L3** provenance (`actions/attest-build-provenance`).

### Verify image signature with Cosign

```bash
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/flame-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/flame:latest

# Or against Docker Hub (identical digest):
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/flame-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  dgcosenza/flame:latest
```

### Verify SPDX / CycloneDX SBOM attestations and SLSA Build Provenance

```bash
cosign verify-attestation \
  --type spdxjson \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/flame-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/flame@sha256:<arch-digest>

gh attestation verify oci://ghcr.io/dgcosenza/flame:latest --owner dgcosenza
```

---

## Security Notes

- **Non-root & read-only code:** Runs as `node` (UID/GID `1000`) with `no-new-privileges:true`. `/app` code, `node_modules`, and static `/app/public` assets are `root:root` read-only; only `/app/data`, `/app/log`, and `/app/public/flame.css` are writable by UID `1000`.
- **Minimal runtime:** Compilers, `git`, `npm`, `npx`, `corepack`, `yarn`, `curl`, and `wget` are excluded from the runtime layer. `/app/package-lock.json` stays intact for transparent vulnerability scanning.
- **Secrets handling:** Prefer Docker secrets (`/run/secrets/password`) + `PASSWORD_FILE` over plaintext `PASSWORD` env vars.
- **JWT signing & rotation:** `data/.secret` is created mode `0600`. Tokens require **HS256**, clamp TTLs to `1h|1d|14d|30d|1y` (default `14d`), and embed an HMAC password fingerprint (`pwf`). Rotating `PASSWORD` or `data/.secret` invalidates all active tokens immediately.
- **Web hardening:** Strict `Content-Security-Policy`, `nosniff`, `SAMEORIGIN`, sandboxed `/uploads`, DOMPurify SVG sanitization, blocked `javascript:`/`data:` URLs, login rate limiting (10 failed attempts / 15 min), constant-time password verification, 100 KB JSON body cap (10 MB backup import), and explicit write field allowlists.
- **LAN-only posture:** Because public dashboard items are unauthenticated by design, keep Flame bound to a private LAN interface rather than exposed on the public internet.
- **Audit & CVE gate (all severities with a fix):** Builds fail on any `npm audit --audit-level=low` finding (>0), any **Trivy** fixable finding of any severity (`--ignore-unfixed`), or any **Grype** fixable finding of any severity (`--only-fixed`). Current status: **0 fixable vulnerabilities of any severity**. Trivy SARIF results are uploaded to GitHub Code Scanning, full Trivy/Grype reports and an **SPDX SBOM** are persisted as CI artifacts, and any upstream-unfixed Debian 13 advisories are cleared automatically by daily rebuilds once Debian Security publishes fixes. See [`SECURITY.md`](https://github.com/dgcosenza/flame-docker/blob/main/SECURITY.md).

---

## Healthcheck

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ["node", "/app/healthcheck.js"]
```

`/app/healthcheck.js` sends an HTTP `GET` to `http://127.0.0.1:${PORT}/health` (5 s timeout) and exits `0` only on HTTP `200` with `{"status":"healthy"}`. `/health` validates both `data/config.json` accessibility and a live SQLite `SELECT 1` query (2 s timeout). Three consecutive failures mark the container `unhealthy`, signalling a process crash, port binding fault, missing config, or unreachable/corrupt SQLite database.

---

## Building from Source

```bash
git clone https://github.com/dgcosenza/flame-docker.git
cd flame-docker
docker buildx build --platform linux/amd64 --load -t dgcosenza/flame:local .
```

Build arguments (`NODE_VERSION`, `FLAME_REPO`, `FLAME_VERSION`, `FLAME_COMMIT`, `IMAGE_*`) and the four-stage build are documented in [`docs/BUILD.md`](https://github.com/dgcosenza/flame-docker/blob/main/docs/BUILD.md).

---

## Update Policy

[`.github/workflows/daily.yml`](https://github.com/dgcosenza/flame-docker/blob/main/.github/workflows/daily.yml) runs every day at **04:17 UTC**, on pushes to `main`, on pull requests (verification only, no publishing) and via `workflow_dispatch`. Each scheduled run is a fully automated seven-step pipeline, gated by `.github/workflows/public-check.yml`:

1. **Upstream check** of the latest Node.js LTS (`trixie-slim`) and `AlexStapleton/Flame-Revamped`, compared against `versions.json`.
2. **No-cache rebuild** with `apt-get upgrade`, fresh npm dependencies, a rebuilt frontend and the full test suite.
3. **Vulnerability gate:** `npm audit` = 0, Trivy and Grype block on any fixable vulnerability of any severity; reports are retained for 90 days.
4. **Smoke test** ([`tests/smoke.sh`](https://github.com/dgcosenza/flame-docker/blob/main/tests/smoke.sh)): non-root startup, `/` and `/health`, healthcheck pass and fail paths, `0600` on `data/.secret`.
5. **Publish** of the tags listed in [Tags and Versioning Policy](#tags-and-versioning-policy) to Docker Hub and GHCR, signed and attested.
6. **Automated documentation sync** of `versions.json`, the *Current Versions* block, the dated `CHANGELOG.md` entry and the Docker Hub overview.
7. **Failure alerting** through a single `ci-failure` GitHub issue, closed automatically on the next green run.

Details of every step and the deployment-pickup guidance: [`docs/UPDATE-POLICY.md`](https://github.com/dgcosenza/flame-docker/blob/main/docs/UPDATE-POLICY.md). Pin deployments by digest and promote new digests only after verifying the healthcheck; avoid unpinned `:latest` pulls and automatic updaters.

---

## Design Decisions

- **Debian 13 (`trixie-slim`) + Node.js LTS:** Uses official `node:<LTS>-trixie-slim` with `apt-get upgrade` at build time rather than Alpine/musl so native `sqlite3` compiles cleanly against Debian 13 glibc and tracks Debian Security advisories.
- **Node.js dependency-free healthcheck:** `/app/healthcheck.js` uses Node's built-in `http` module, eliminating `curl`/`wget` from the runtime layer.
- **Minimal, read-only runtime:** Compilers, `git`, `npm`, `npx`, `corepack`, and `yarn` are removed from the runtime image while `package-lock.json` is retained for accurate scanner visibility.

---

## Troubleshooting

- **`FATAL: PASSWORD environment variable is not set`:** supply `PASSWORD`, `PASSWORD_FILE=/run/secrets/password`, or a readable `/run/secrets/password`.
- **`EACCES` in `/app/data`:** `chown -R 1000:1000 ./data && chmod 600 ./data/.secret`.
- **Container `unhealthy` after migrating:** use `["CMD", "node", "/app/healthcheck.js"]` as `healthcheck.test`.

More cases (logout after upgrade, CSP, rate limiter behind a proxy, WAL backups): [`docs/TROUBLESHOOTING.md`](https://github.com/dgcosenza/flame-docker/blob/main/docs/TROUBLESHOOTING.md).

---

## Changelog

See [`CHANGELOG.md`](https://github.com/dgcosenza/flame-docker/blob/main/CHANGELOG.md).

---

## License

This repository follows a clear packaging-vs-upstream license split:

- **Container packaging, scripts, CI workflows, and documentation (`packaging: MIT`):** Licensed under the [MIT License](https://github.com/dgcosenza/flame-docker/blob/main/LICENSE) — copyright **Daniel G. Cosenza from FNX Labs**.
- **Bundled upstream software — Flame / Flame-Revamped (`AlexStapleton/Flame-Revamped`, fork of `pawelmalak/flame`) (`upstream: MIT`):** Created by [Paweł Malak](https://github.com/pawelmalak/flame) and maintained by [Alex Stapleton](https://github.com/AlexStapleton/Flame-Revamped) — licensed under the [MIT License](https://github.com/AlexStapleton/Flame-Revamped/blob/main/LICENSE).

Full third-party notices are maintained in [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/flame-docker/blob/main/THIRD-PARTY-NOTICES.md). Release history is maintained in [`CHANGELOG.md`](https://github.com/dgcosenza/flame-docker/blob/main/CHANGELOG.md).
