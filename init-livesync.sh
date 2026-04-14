#!/bin/bash
# LiveSync CouchDB Init Script
# Runs once on first boot via /docker-entrypoint-initdb.d/
# All config values sourced from environment variables

DB_NAME="${COUCHDB_DB_NAME:-obsidiandb}"
USER="${COUCHDB_USER:-obsidian_user}"
PASS="${COUCHDB_PASSWORD:-changeme}"
BASE="http://${USER}:${PASS}@localhost:5984"

echo "[livesync-init] Waiting for CouchDB to be ready..."
until curl -sf "${BASE}/" > /dev/null 2>&1; do
  sleep 1
done
echo "[livesync-init] CouchDB is up."

# -- Create database --
echo "[livesync-init] Creating database: ${DB_NAME}"
curl -sf -X PUT "${BASE}/${DB_NAME}" && echo "[livesync-init] Database created." || echo "[livesync-init] Database may already exist, skipping."

# -- chttpd --
echo "[livesync-init] Applying chttpd config..."
curl -sf -X PUT "${BASE}/_node/_local/_config/chttpd/require_valid_user"   -d '"true"'
curl -sf -X PUT "${BASE}/_node/_local/_config/chttpd/enable_cors"           -d '"true"'
curl -sf -X PUT "${BASE}/_node/_local/_config/chttpd/max_http_request_size" -d '"4294967296"'

# -- chttpd_auth --
echo "[livesync-init] Applying chttpd_auth config..."
curl -sf -X PUT "${BASE}/_node/_local/_config/chttpd_auth/require_valid_user" -d '"true"'

# -- httpd --
echo "[livesync-init] Applying httpd config..."
curl -sf -X PUT "${BASE}/_node/_local/_config/httpd/WWW-Authenticate" -d '"Basic realm=\"couchdb\""'
curl -sf -X PUT "${BASE}/_node/_local/_config/httpd/enable_cors"       -d '"true"'

# -- couchdb --
echo "[livesync-init] Applying couchdb config..."
curl -sf -X PUT "${BASE}/_node/_local/_config/couchdb/max_document_size" -d '"50000000"'

# -- cors --
echo "[livesync-init] Applying CORS config..."
curl -sf -X PUT "${BASE}/_node/_local/_config/cors/credentials" -d '"true"'
curl -sf -X PUT "${BASE}/_node/_local/_config/cors/origins"     -d '"app://obsidian.md,capacitor://localhost,http://localhost"'
curl -sf -X PUT "${BASE}/_node/_local/_config/cors/methods"     -d '"GET, PUT, POST, HEAD, DELETE"'
curl -sf -X PUT "${BASE}/_node/_local/_config/cors/headers"     -d '"accept, authorization, content-type, origin, referer"'

echo "[livesync-init] All configuration applied successfully."
