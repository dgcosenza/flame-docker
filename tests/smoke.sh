#!/usr/bin/env bash
# Smoke test for dgcosenza/flame: verifies non-root UID 1000 execution,
# healthcheck.js pass/fail behavior, HTTP / and /health responses, and strict
# 0600 permissions on generated data/.secret.
set -euo pipefail

IMAGE="${1:-dgcosenza/flame:ci-candidate}"
NAME="flame-ci-smoke-$$"
TMPDATA="$(mktemp -d)"
chmod 777 "$TMPDATA"

cleanup() {
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  rm -rf "$TMPDATA" 2>/dev/null || true
}
trap cleanup EXIT

docker run -d --name "$NAME" \
  --security-opt no-new-privileges:true \
  -p 127.0.0.1:15005:5005 \
  -e PASSWORD="ci-smoke-test-password-only" \
  -v "${TMPDATA}:/app/data" \
  "$IMAGE"

# Verify non-root UID 1000
UID_ACTUAL="$(docker exec "$NAME" id -u)"
test "$UID_ACTUAL" = "1000"

# Wait for Docker's built-in HEALTHCHECK to report status=healthy
HEALTH_STATUS=""
for _ in $(seq 1 45); do
  if ! docker ps -q --filter "name=^/${NAME}$" | grep -q .; then
    echo "ERROR: flame container exited prematurely:" >&2
    docker logs "$NAME" >&2 || true
    exit 1
  fi
  HEALTH_STATUS="$(docker inspect --format '{{.State.Health.Status}}' "$NAME" 2>/dev/null || echo starting)"
  if [ "$HEALTH_STATUS" = "healthy" ]; then
    break
  fi
  if [ "$HEALTH_STATUS" = "unhealthy" ]; then
    echo "ERROR: flame container became unhealthy" >&2
    docker inspect --format '{{json .State.Health}}' "$NAME" >&2 || true
    docker logs "$NAME" >&2 || true
    exit 1
  fi
  sleep 2
done
if [ "$HEALTH_STATUS" != "healthy" ]; then
  echo "ERROR: flame container did not reach Docker healthy status (last=${HEALTH_STATUS})" >&2
  docker inspect --format '{{json .State.Health}}' "$NAME" >&2 || true
  exit 1
fi
docker exec "$NAME" node /app/healthcheck.js

# Prove healthcheck fails on a dead port (negative test)
if docker exec -e PORT=5999 "$NAME" node /app/healthcheck.js; then
  echo "ERROR: healthcheck unexpectedly passed on dead port 5999" >&2
  exit 1
fi

# Verify HTTP 200 on / and /health
curl -fsS http://127.0.0.1:15005/ | grep -q "<title>Flame</title>"
curl -fsS http://127.0.0.1:15005/health | grep -q '"status":"healthy"'

# Verify data/.secret created with strict mode 0600
SECRET_MODE="$(stat -c '%a' "${TMPDATA}/.secret")"
test "$SECRET_MODE" = "600"

echo "Smoke test passed (uid=${UID_ACTUAL}, secret_mode=${SECRET_MODE})."
