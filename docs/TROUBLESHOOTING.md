# Troubleshooting

Maintained by **Daniel G. Cosenza from FNX Labs**. Back to the [README](https://github.com/dgcosenza/flame-docker#readme).


- **Exits with `FATAL: PASSWORD environment variable is not set`:** Supply `PASSWORD`, `PASSWORD_FILE=/run/secrets/password`, or mount `/run/secrets/password` readable by UID `1000`.
- **`EACCES: permission denied` in `/app/data`:** Fix ownership on the host: `chown -R 1000:1000 ./data && chmod 600 ./data/.secret`.
- **Container `unhealthy` after upgrading from `pawelmalak/flame`:** Replace `wget ...` in Compose `healthcheck.test` with `["CMD", "node", "/app/healthcheck.js"]`.
- **Logged out after upgrade or password change:** Expected — JWTs are bound to `PASSWORD` and require HS256. Sign in once under Settings → App.
- **External assets blocked by CSP:** Set `CSP=off` only if custom CSS or icons require it.
- **Rate limiter triggers across all users behind a proxy:** Set `TRUST_PROXY=1` (matching your proxy hop count).
- **Incomplete SQLite backup:** SQLite runs in WAL mode; stop Flame briefly before copying `data/` or include `-wal` and `-shm`.
