#!/usr/bin/env bash
set -euo pipefail

SOURCE_IMAGE="${1:-mcr.microsoft.com/devcontainers/base:ubuntu-24.04}"
TARGET_IMAGE="devpod-repro-shared-base:latest"

docker pull "$SOURCE_IMAGE" >/dev/null
docker image rm -f "$TARGET_IMAGE" >/dev/null 2>&1 || true
docker tag "$SOURCE_IMAGE" "$TARGET_IMAGE"

echo "Reset $TARGET_IMAGE from $SOURCE_IMAGE"
docker image inspect "$TARGET_IMAGE" --format 'id={{.Id}}'
