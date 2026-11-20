# syntax=docker/dockerfile:1

ARG NODE_VERSION=26.13.1
ARG FLAME_REPO=https://github.com/AlexStapleton/Flame-Revamped.git
ARG FLAME_VERSION=2.1.0
ARG FLAME_COMMIT=0d6221d8ff4c800a93d6e42557ac16658ebaa6d5

# ---- Stage 1: fetch pinned upstream source & apply audited patches ----
FROM node:${NODE_VERSION}-trixie-slim AS source

ARG FLAME_REPO
ARG FLAME_COMMIT

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN git init \
    && git remote add origin "${FLAME_REPO}" \
    && git fetch --depth 1 origin "${FLAME_COMMIT}" \
    && git checkout --detach FETCH_HEAD \
    && test "$(git rev-parse HEAD)" = "${FLAME_COMMIT}"

COPY patches/ /tmp/patches/
COPY tests/fnxCompat.test.js /src/test/fnxCompat.test.js

RUN set -e; for p in /tmp/patches/*.patch; do \
      echo "Applying patch: $p"; \
      git apply --check "$p"; \
      git apply "$p"; \
    done \
    && rm -rf /tmp/patches /src/.git

# ---- Stage 2: update client dependencies, audit, typecheck & build frontend ----
FROM node:${NODE_VERSION}-trixie-slim AS client-builder

WORKDIR /app/client
COPY --from=source /src/client/ ./

RUN npm update \
    && npm audit --audit-level=low \
    && npm run typecheck \
    && npm run build

# ---- Stage 3: update server deps, compile sqlite3 from source, test & audit ----
FROM node:${NODE_VERSION}-trixie-slim AS server-builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends g++ make python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=source /src/ ./
RUN rm -rf /app/client

# Update server dependencies to latest compatible releases, rebuild native sqlite3
# against Debian 13 (trixie) glibc + current Node LTS ABI, run the full test
# suite, prune devDependencies, and fail the build on any npm audit finding.
RUN npm update \
    && npm rebuild sqlite3 --build-from-source \
    && npm test \
    && npm prune --omit=dev \
    && npm audit --omit=dev --audit-level=low

# ---- Stage 4: hardened Debian 13 (trixie) + Node LTS runtime ----
FROM node:${NODE_VERSION}-trixie-slim AS runtime

ARG NODE_VERSION
ARG FLAME_REPO
ARG FLAME_VERSION
ARG FLAME_COMMIT
ARG IMAGE_CREATED=""
ARG IMAGE_REVISION=""
ARG IMAGE_SOURCE="https://github.com/dgcosenza/flame-docker"

LABEL org.opencontainers.image.title="Flame (Debian 13 / Node LTS)" \
      org.opencontainers.image.description="Hardened, up-to-date Debian 13 (trixie) and Node LTS container image for Flame self-hosted startpage, maintained by FNX Labs." \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/flame" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.version="${FLAME_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.vendor="FNX Labs" \
      org.opencontainers.image.authors="Daniel Cosenza (dgcosenza)" \
      io.github.dgcosenza.flame.upstream_repo="${FLAME_REPO}" \
      io.github.dgcosenza.flame.upstream_version="${FLAME_VERSION}" \
      io.github.dgcosenza.flame.upstream_commit="${FLAME_COMMIT}" \
      io.github.dgcosenza.flame.node_version="${NODE_VERSION}"

# Fully upgrade Debian 13 (trixie) base packages at build time and remove
# build-only package managers (npm/npx/corepack/yarn) not used at runtime.
RUN apt-get update \
    && apt-get -y --no-install-recommends upgrade \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
       /usr/local/lib/node_modules/npm \
       /usr/local/lib/node_modules/corepack \
       /usr/local/bin/npm \
       /usr/local/bin/npx \
       /usr/local/bin/corepack \
       /usr/local/bin/yarn \
       /usr/local/bin/yarnpkg \
       /opt/yarn-*

WORKDIR /app

# Server code, lockfile (kept intact for transparent vulnerability scanning),
# and production node_modules (root-owned, read-only to the non-root user).
COPY --from=server-builder /app/node_modules ./node_modules
COPY --from=server-builder /app/package.json /app/package-lock.json ./
COPY --from=server-builder /app/CHANGELOG.md ./
COPY --from=server-builder /app/server.js /app/api.js /app/Socket.js /app/Sockets.js ./
COPY --from=server-builder /app/controllers ./controllers
COPY --from=server-builder /app/db ./db
COPY --from=server-builder /app/middleware ./middleware
COPY --from=server-builder /app/models ./models
COPY --from=server-builder /app/routes ./routes
COPY --from=server-builder /app/utils ./utils
COPY healthcheck.js ./healthcheck.js

# Rebuilt Vite frontend assets
COPY --from=client-builder /app/client/dist ./public

# Writable runtime directories for non-root uid 1000 (`node`).
# `/app/public/flame.css` is pre-created and owned by `node:node` so custom CSS
# edits work while the rest of `/app/public` remains read-only to the app user.
RUN mkdir -p /app/data /app/log \
    && touch /app/public/flame.css \
    && chown -R node:node /app/data /app/log /app/public/flame.css

ENV NODE_ENV=production \
    PORT=5005

USER node

EXPOSE 5005

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ["node", "/app/healthcheck.js"]

CMD ["node", "server.js"]
