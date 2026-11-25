# Upgrading and migrating from `pawelmalak/flame`

Maintained by **Daniel G. Cosenza from FNX Labs**. Back to the [README](https://github.com/dgcosenza/flame-docker#readme).


This image is a data-compatible upgrade from `pawelmalak/flame` (`v2.3.x` / `v2.4.0`).

### Compatibility Summary

- **SQLite schema:** `pawelmalak/flame` v2.4.0 ends at migration `05_app-description.js`. On first boot, `dgcosenza/flame` saves an automatic backup in `data/db_backups/` and runs four **additive, reversible** migrations (`06_indexes.js` through `09_weather-details.js`) adding one bookmark index and nullable columns for app status, sync source, and weather details. All four migrations implement `down()` and preserve existing apps, categories, and bookmarks verbatim. Even so, keep a full pre-upgrade copy of `data/` for instant rollback.
- **`data/.secret`:** Existing `data/.secret` files from `pawelmalak/flame` are reused in place (no `secret.key` is created).
- **One-time re-login:** Legacy JWTs lack the password-fingerprint (`pwf`) claim and must be re-issued once via Settings → App.
- **`config.json`:** Existing settings are preserved; new optional defaults are appended while new widgets stay dormant until configured.
- **Healthcheck:** Update Compose `healthcheck.test` from `wget ...` to `["CMD", "node", "/app/healthcheck.js"]`.

### Step-by-Step Cutover

1. **Back up Compose, data, and tag the outgoing image:**
   ```bash
   STAMP=$(date +%Y%m%d-%H%M%S)
   cp -a docker-compose.yml "docker-compose.yml.bak-${STAMP}"
   cp -a ./data "/path/to/backups/flame-data-pre-upgrade-${STAMP}"
   docker tag "$(docker inspect -f '{{.Image}}' flame)" "local/flame-rollback:${STAMP}"
   ```
2. **Confirm UID `1000` ownership on `./data`:** `ls -lan ./data` (run `chown -R 1000:1000 ./data` if root-owned).
3. **Pull and retrieve the digest:**
   ```bash
   docker pull dgcosenza/flame:latest
   docker image inspect dgcosenza/flame:latest -f '{{index .RepoDigests 0}}'
   ```
4. **Edit `docker-compose.yml`:** set `image: dgcosenza/flame:latest@sha256:<digest>` and `healthcheck.test: ["CMD", "node", "/app/healthcheck.js"]`, keeping `no-new-privileges:true`, LAN-only `ports`, `volumes`, `secrets`, `networks`, and limits intact.
5. **Validate and recreate only `flame`:**
   ```bash
   docker compose config -q && docker compose up -d flame
   ```
6. **Verify:**
   ```bash
   docker inspect flame --format 'Status={{.State.Status}} Health={{.State.Health.Status}} User={{.Config.User}}'
   curl -fsS http://192.0.2.10:5005/health
   for ep in apps categories bookmarks; do
     printf '%s: ' "$ep"
     curl -fsS "http://192.0.2.10:5005/api/$ep" | jq '.data | length'
   done
   ```
   Confirm counts match pre-upgrade totals, test admin login with your existing password, and inspect `docker logs flame`.
