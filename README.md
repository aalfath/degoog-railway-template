[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/degoog-1?utm_medium=integration&utm_source=button&utm_campaign=degoog)

# degoog on Railway

A one-click Railway template for [degoog](https://github.com/degoog-org/degoog), the open-source, self-hosted search engine aggregator: one search page that queries several engines, with plugins, themes, custom engines, bangs and an optional local indexer.

## What it deploys

| Service | Source | Data |
|---|---|---|
| **degoog** | this repo's `Dockerfile`: the official image `ghcr.io/degoog-org/degoog:1.2.0`, pinned by digest | volume at `/app/data` (settings, installed extensions, themes, engines, indexer, blocklist) |

The service gets a public `*.up.railway.app` domain on port 4444 and a health check on `/readyz`. No database is needed: degoog keeps everything in `/app/data` (SQLite for the indexer).

## Variables

| Variable | Default | Notes |
|---|---|---|
| `DEGOOG_SETTINGS_PASSWORDS` | `${{secret(32)}}` (generated) | Password for the **Settings** area. Installing an extension runs code on the server, so this is always set. Copy it from the service's **Variables** tab. Several passwords can be given, separated by commas. |
| `PORT` | `4444` | Port degoog listens on; the domain and the health check target it. |

Nothing to fill in at deploy time. The start script (`railway-start.sh`) also sets `DEGOOG_PORT=$PORT` and `DEGOOG_DISTRUST_PROXY=0`, so degoog trusts Railway's edge proxy headers: rate limits and the settings-login lockout (10 wrong passwords per minute) apply per visitor, and the session cookie is marked `Secure`.

Optional settings, added as variables later if you want them (see the [degoog docs](https://degoog-org.github.io/docs/)):

- `DEGOOG_PUBLIC_INSTANCE=true` for a public instance: settings move to `/admin` and stay behind the password.
- `DEGOOG_BASE_URL=https://YOUR-DOMAIN` when you put degoog under a sub-path.
- `DEGOOG_VALKEY_URL` (shared cache) and `DEGOOG_POSTGRES` (indexer on Postgres) for busy multi-replica instances. Add a Railway Redis or Postgres and reference it, for example `${{Postgres.DATABASE_URL}}`.

## After deploy

Open the public URL and search. To change engines, install plugins or themes, open **Settings** (`/settings`) and sign in with `DEGOOG_SETTINGS_PASSWORDS`. To use it as your browser's default search engine, add it through the browser's search-engine settings (degoog serves `/opensearch.xml`).

## Updates

Each degoog release is a new commit to `main` here that bumps the pinned tag and digest, with a [`CHANGELOG.md`](CHANGELOG.md) entry (breaking changes first). Railway then shows an "update available" notice in projects deployed from this template, and you choose when to apply it. Your `/app/data` volume is kept across updates.

## Local test

```sh
docker build -t degoog-railway .
docker run --rm -p 4444:4444 -e PORT=4444 -e DEGOOG_SETTINGS_PASSWORDS=change-me -v degoog-data:/app/data degoog-railway
curl -fsS http://localhost:4444/readyz
```

## Licence

degoog is AGPL-3.0, by fccview and contributors. This wrapper only adds a start script; its own files are under the same licence.
