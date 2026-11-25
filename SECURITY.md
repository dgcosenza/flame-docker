# Security Policy

Maintained by **Daniel G. Cosenza from FNX Labs**.

## Supported Versions

Only the latest daily build of `dgcosenza/flame` on Debian 13 (`trixie-slim`) + active Node.js LTS is actively maintained and receives automated security rebuilds.

## Automated Vulnerability Scanning

Every build in GitHub Actions enforces:
- `npm audit --audit-level=low` = **0 vulnerabilities** on both client and production server dependencies.
- **Trivy** (`--ignore-unfixed`, severity `CRITICAL,HIGH`) hard gate + full report artifact + SARIF upload to GitHub Code Scanning.
- **Grype** (`--only-fixed`, severity cutoff `high`) hard gate + report artifact.
- **Syft** SPDX SBOM artifact generation.

Daily scheduled builds run with `--no-cache` and upgrade all Debian 13 packages at build time.

## Reporting a Vulnerability

- **Container packaging, patches, or CI issues:** Open a private security advisory via GitHub Security Advisories on [`dgcosenza/flame-docker`](https://github.com/dgcosenza/flame-docker/security/advisories/new).
- **Upstream Flame-Revamped application issues:** Report directly to [`AlexStapleton/Flame-Revamped`](https://github.com/AlexStapleton/Flame-Revamped).
