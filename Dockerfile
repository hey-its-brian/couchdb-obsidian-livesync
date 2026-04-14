FROM couchdb:3.3.3

LABEL maintainer="Brian"
LABEL description="CouchDB pre-configured for Obsidian Self-Hosted LiveSync"

COPY init-livesync.sh /docker-entrypoint-initdb.d/init-livesync.sh
RUN chmod +x /docker-entrypoint-initdb.d/init-livesync.sh
