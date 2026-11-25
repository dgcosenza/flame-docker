# Building from source

Maintained by **Daniel G. Cosenza from FNX Labs**. Back to the [README](https://github.com/dgcosenza/flame-docker#readme).


```bash
git clone https://github.com/dgcosenza/flame-docker.git
cd flame-docker

docker buildx build \
  --platform linux/amd64 \
  --load \
  --build-arg IMAGE_CREATED="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --build-arg IMAGE_REVISION="$(git rev-parse HEAD)" \
  -t dgcosenza/flame:local \
  .
```

| Build Arg | Default | Purpose |
| --- | --- | --- |
| `NODE_VERSION` | `26.13.1` | Official `node:<ver>-trixie-slim` base tag. |
| `FLAME_REPO` | `https://github.com/AlexStapleton/Flame-Revamped.git` | Upstream repository URL. |
| `FLAME_VERSION` | `2.1.0` | Upstream release version (OCI label). |
| `FLAME_COMMIT` | `0d6221d8ff4c800a93d6e42557ac16658ebaa6d5` | Pinned upstream commit SHA (verified at build). |
| `IMAGE_CREATED` | `""` | RFC 3339 UTC build timestamp. |
| `IMAGE_REVISION` | `""` | Packaging repo Git SHA. |
| `IMAGE_SOURCE` | `https://github.com/dgcosenza/flame-docker` | Source URL for OCI labels. |

**Multi-stage build:** (1) `source` clones and verifies `FLAME_COMMIT`, applies `patches/*.patch`, and adds `tests/compat.test.js`; (2) `client-builder` runs `npm update`, `npm audit --audit-level=low`, `tsc --noEmit`, and `vite build` (with `.br`/`.gz` assets); (3) `server-builder` updates deps, compiles native `sqlite3` from source, runs `npm test` (250+ tests), prunes devDeps, and enforces `npm audit --omit=dev --audit-level=low`; (4) `runtime` upgrades Debian 13 (`apt-get upgrade`), strips `npm`/`npx`/`corepack`/`yarn`, copies production artifacts, sets UID 1000 ownership on writable paths only, and runs as `USER node`.
