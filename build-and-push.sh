#!/bin/bash
# build-and-push.sh
# Builds the couchdb-livesync image and pushes it to Docker Hub.
# Usage: ./build-and-push.sh [version]
#
# Examples:
#   ./build-and-push.sh           -- builds and tags as 3.3.3 and latest
#   ./build-and-push.sh 3.3.3     -- same, explicit version

set -e

# -- Config -- edit these before first run
DOCKERHUB_USER="heyitsbrian"
IMAGE_NAME="couchdb-livesync"
VERSION="${1:-3.3.3}"
FULL_TAG="${DOCKERHUB_USER}/${IMAGE_NAME}:${VERSION}"
LATEST_TAG="${DOCKERHUB_USER}/${IMAGE_NAME}:latest"

echo "=> Building ${FULL_TAG}..."
docker build \
  --platform linux/amd64 \
  -t "${FULL_TAG}" \
  -t "${LATEST_TAG}" \
  .

echo ""
echo "=> Logging in to Docker Hub..."
docker login

echo ""
echo "=> Pushing ${FULL_TAG}..."
docker push "${FULL_TAG}"

echo ""
echo "=> Pushing ${LATEST_TAG}..."
docker push "${LATEST_TAG}"

echo ""
echo "Done. Your image is live at:"
echo "  https://hub.docker.com/r/${DOCKERHUB_USER}/${IMAGE_NAME}"
echo ""
echo "Next steps:"
echo "  1. Update couchdb-livesync.xml -- replace heyitsbrian and hey-its-brian"
echo "  2. Push the xml file to your GitHub templates repo"
echo "  3. Share the raw GitHub URL or submit a PR to the CA AppFeed"
