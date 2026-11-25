# Changelog

All notable changes to the `dgcosenza/flame` Debian 13 / Node LTS container packaging and patches are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Application version numbers track the pinned upstream `AlexStapleton/Flame-Revamped` release. Maintained by **Daniel G. Cosenza from FNX Labs**.

---
<!-- changelog:auto -->

## [2.1.0-0d6221d8] — 2026-11-25

### Automated Daily Build
- Verified components: Flame-Revamped `2.1.0 (0d6221d8)`, Node.js LTS `26.13.1`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream status: no new upstream release since previous build; refreshed base OS and dependencies.
- Vulnerability gate: **0 fixable Critical/High** in Trivy and Grype (SBOM scan) (13 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/flame@sha256:d5768b23d55d25438c4837098a1ef8c8df61e7e3965e5962f87d876ab7ff184c` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

## [2.1.0-0d6221d8] — 2026-11-24

### Added
- Full seven-step automated daily pipeline in `.github/workflows/daily.yml` (upstream check with `versions.json`, `--no-cache` rebuild, Trivy + Grype blocking gates with CVE diffing and 90-day report artifacts, Syft SPDX SBOM + provenance, smoke testing, automated `README.md`/`CHANGELOG.md` bot sync + Docker Hub description sync, and `ci-failure` GitHub issue alerting with auto-close on recovery).
- Standalone `tests/smoke.sh`, `SECURITY.md`, `THIRD-PARTY-NOTICES.md`, `.github/dependabot.yml`, and automated public-content verification (`.github/workflows/public-check.yml`).
- Additional immutable tags `<version>-<YYYYMMDD>` and `sha-<short>` published on release.

### Changed
- Updated base OS references to current Debian 13 point release (13.8 as of 2026-11-24) and standardized maintainer attribution (`Daniel G. Cosenza from FNX Labs`) and OCI label namespace (`io.github.dgcosenza.flame.*`).

---

## [2.1.0-0d6221d8] — 2026-11-20

### Added
- **Hardened Debian 13 (trixie) + Node.js LTS base image**: multi-stage build using official `node:26.13.1-trixie-slim` (Debian 13.7, Node.js v26.13.1 LTS *Lithium*) with `apt-get update && apt-get -y upgrade` applied at build time.
- **Native `sqlite3` compilation**: rebuilt from source against Debian 13 glibc and the Node.js 26 ABI during the build stage.
- **Full dependency refresh & zero-CVE build gate**: both server and Vite/React client dependencies are updated (`npm update`) and audited (`npm audit --audit-level=low` = 0 vulnerabilities), client is type-checked (`tsc --noEmit`) and freshly bundled (`vite build`), and the full test suite (`npm test`) runs during image build.
- **Built-in dependency-free healthcheck (`/app/healthcheck.js`)**: Node.js `http.get` probe against `http://127.0.0.1:${PORT}/health` (verifies HTTP 200, JSON `{"status":"healthy"}`, `data/config.json` readability, and SQLite `SELECT 1`), removing any need for `curl` or `wget` in the runtime image.
- **Audited packaging patches (`patches/`)**:
  - `01-secrets-and-startup.patch`: loads `/run/secrets/*` and `PASSWORD_FILE` / `SECRET_FILE` environment variables *before* `SECRET` initialization and `PASSWORD` validation so secret-only deployments start cleanly without plaintext `PASSWORD` env vars.
  - `02-dot-secret-compat.patch`: preserves seamless compatibility with upstream `pawelmalak/flame` (`data/.secret`) while keeping fallback support for `Flame-Revamped` (`data/secret.key`), and creates new secret files with strict `0600` permissions.
  - `03-mass-assignment-allowlists.patch`: enforces explicit field allowlists in app, bookmark, and category create/update controllers (mitigating CWE-915 mass assignment).
- **Compatibility test suite (`tests/compat.test.js`)**: automated `node:test` coverage for `PASSWORD_FILE`, `data/.secret` precedence, `data/secret.key` fallback, and `0600` secret permissions.
- **Runtime hardening**: runs as non-root `node` (UID/GID 1000); application code and `/app/public` assets are root-owned and read-only (only `/app/data`, `/app/log`, and `/app/public/flame.css` are writable by UID 1000); build-only package managers (`npm`, `npx`, `corepack`, `yarn`) are stripped from the runtime layer while `/app/package-lock.json` remains intact for transparent vulnerability scanning.
- **OCI metadata labels**: complete `org.opencontainers.image.*` labels plus `io.github.dgcosenza.flame.*` build provenance labels (upstream repo, version, commit, Node version).
- **Daily CI maintenance workflow (`.github/workflows/build-and-publish.yml`)**: scheduled daily rebuilds against the latest Debian 13 security packages, Node LTS point releases, and npm updates; hard-gated on `npm audit` = 0, full unit tests, container smoke tests, and Trivy scanning (0 fixable Critical/High); automatically syncs Docker Hub short and full descriptions on publish.

### Upstream Base
- Pinned to [`AlexStapleton/Flame-Revamped`](https://github.com/AlexStapleton/Flame-Revamped) **v2.1.0** (`0d6221d8ff4c800a93d6e42557ac16658ebaa6d5`, 2026-11-08), a maintained fork of [`pawelmalak/flame`](https://github.com/pawelmalak/flame) featuring Express 5, Sequelize 6, React 19, Vite 8, TypeScript 7, Content-Security-Policy, DOMPurify SVG sanitization, login rate limiting, timing-safe password comparison, password-bound HS256 JWTs with TTL allowlist, drag-and-drop reordering, backup/restore, app status checks, and optional Pi-hole/Calendar widgets.
