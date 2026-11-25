# Backup and restore

Maintained by **Daniel G. Cosenza from FNX Labs**. Back to the [README](https://github.com/dgcosenza/flame-docker#readme).


Because SQLite uses WAL mode (`db.sqlite-wal`, `db.sqlite-shm`), stop the container briefly before archiving `/app/data`:

```bash
STAMP=$(date +%Y%m%d-%H%M%S)
docker compose stop flame
tar --numeric-owner -czf "flame-data-backup-${STAMP}.tar.gz" -C /path/to/flame data
chmod 600 "flame-data-backup-${STAMP}.tar.gz"
docker compose start flame
```

> **Note:** Flame's built-in GUI Backup/Restore excludes secrets (`WEATHER_API_KEY`, `PIHOLE_SECRETS`, `CALENDAR_SECRETS`, `data/.secret`, `PASSWORD`). Use filesystem backups of `/app/data` for complete recovery.

**Restore:**

```bash
docker compose stop flame
mv ./data "./data.broken-$(date +%Y%m%d-%H%M%S)"
tar --numeric-owner -xzf "flame-data-backup-<STAMP>.tar.gz" -C /path/to/flame
chmod 600 ./data/.secret
docker compose up -d flame
```
