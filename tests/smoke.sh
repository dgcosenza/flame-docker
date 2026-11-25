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

# Wait for /health 200 and built-in healthcheck.js
for _ in $(seq 1 30); do
  if docker exec "$NAME" node /app/healthcheck.js; then
    break
  fi
  sleep 1
done
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
