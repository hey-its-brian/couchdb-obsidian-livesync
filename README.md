# couchdb-livesync

A custom CouchDB Docker image pre-configured for use with [Obsidian Self-Hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync).

On first boot, all required configuration is applied automatically via an init script -- no manual steps in the CouchDB UI needed. Based on the official `couchdb:3.3.3` image.

---

## What gets configured automatically

On first boot the init script applies all settings required by LiveSync:

| Section | Key | Value |
|---|---|---|
| `chttpd` | `require_valid_user` | `true` |
| `chttpd` | `enable_cors` | `true` |
| `chttpd` | `max_http_request_size` | `4294967296` |
| `chttpd_auth` | `require_valid_user` | `true` |
| `httpd` | `WWW-Authenticate` | `Basic realm="couchdb"` |
| `httpd` | `enable_cors` | `true` |
| `couchdb` | `max_document_size` | `50000000` |
| `cors` | `credentials` | `true` |
| `cors` | `origins` | `app://obsidian.md,capacitor://localhost,http://localhost` |
| `cors` | `methods` | `GET, PUT, POST, HEAD, DELETE` |
| `cors` | `headers` | `accept, authorization, content-type, origin, referer` |

It also creates your Obsidian database automatically using the name defined in `COUCHDB_DB_NAME`.

---

## Usage

### Docker Compose (recommended)

```yaml
services:
  couchdb-obsidian-livesync:
    container_name: obsidian-livesync
    image: YOURDOCKERHUBUSER/couchdb-livesync:3.3.3
    environment:
      - TZ=America/New_York
      - COUCHDB_USER=obsidian_user       # change me
      - COUCHDB_PASSWORD=changeme        # definitely change me
      - COUCHDB_DB_NAME=obsidiandb       # change me if desired
    volumes:
      - /path/to/appdata/data:/opt/couchdb/data
      - /path/to/appdata/etc/local.d:/opt/couchdb/etc/local.d
    ports:
      - "5984:5984"
    restart: unless-stopped
```

### Docker CLI

```bash
docker run -d \
  --name obsidian-livesync \
  -e COUCHDB_USER=obsidian_user \
  -e COUCHDB_PASSWORD=changeme \
  -e COUCHDB_DB_NAME=obsidiandb \
  -v /path/to/appdata/data:/opt/couchdb/data \
  -v /path/to/appdata/etc/local.d:/opt/couchdb/etc/local.d \
  -p 5984:5984 \
  --restart unless-stopped \
  YOURDOCKERHUBUSER/couchdb-livesync:3.3.3
```

---

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `COUCHDB_USER` | `obsidian_user` | CouchDB admin username |
| `COUCHDB_PASSWORD` | *(required)* | CouchDB admin password |
| `COUCHDB_DB_NAME` | `obsidiandb` | Name of the Obsidian database to create |
| `TZ` | `America/New_York` | Container timezone |
| `PUID` | `99` | User ID for file permissions |
| `PGID` | `100` | Group ID for file permissions |

> For multiple users, give each their own database by setting `COUCHDB_DB_NAME` to something like `obsidiandb_john`. Each user connects LiveSync to their own database name.

---

## Connecting LiveSync

Once the container is running, open Obsidian on each device:

1. Install the **Self-Hosted LiveSync** community plugin
2. Open its settings and navigate to the remote database config (satellite icon)
3. Set **Remote Type** to `CouchDB`
4. Set **URI** to `http://YOUR_SERVER_IP:5984`
5. Enter your `COUCHDB_USER` and `COUCHDB_PASSWORD`
6. Set **Database name** to your `COUCHDB_DB_NAME`
7. Click **Test** -- you should see a success message
8. Click **Check** -- all items should show a purple checkmark
9. Set **Sync mode** to `LiveSync`

> Mobile devices require HTTPS. Put this container behind a reverse proxy (e.g. Nginx Proxy Manager + Cloudflare Tunnel) before connecting iOS or Android.

---

## Building locally

```bash
git clone https://github.com/YOURGITHUBUSER/couchdb-livesync
cd couchdb-livesync
docker build -t couchdb-livesync:3.3.3 .
```

To build and push to Docker Hub:

```bash
./build-and-push.sh
```

---

## Notes

- The init script runs **once** on first boot when the data volume is empty. It will not re-run or overwrite data on subsequent container restarts.
- If you ever need to re-run the init script manually against an existing container (e.g. after a data volume wipe):
  ```bash
  docker exec obsidian-livesync bash /docker-entrypoint-initdb.d/init-livesync.sh
  ```
- You can verify all settings were applied in the CouchDB admin UI at `http://YOUR_SERVER_IP:5984/_utils` under **Configuration**.

---

## Unraid

This image is available in the Unraid Community Applications store. Search for `couchdb-livesync`.

Template repo: [github.com/YOURGITHUBUSER/unraid-templates](https://github.com/YOURGITHUBUSER/unraid-templates)

---

## Credits

- [obsidian-livesync](https://github.com/vrtmrz/obsidian-livesync) by vrtmrz
- [CouchDB](https://couchdb.apache.org/)
- LiveSync setup guide by the Unraid/Obsidian community
