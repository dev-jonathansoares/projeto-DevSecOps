#!/usr/bin/env bash
set -euo pipefail
IMAGE="${1:-secure-pyapp:local}"
echo "[*] Scanning image with Trivy: $IMAGE"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.54.1 image --severity HIGH,CRITICAL --no-progress "$IMAGE"
