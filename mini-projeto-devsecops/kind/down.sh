#!/usr/bin/env bash
set -euo pipefail
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock kindest/kind:v0.23.0 delete cluster --name dev || true
rm -f kubeconfig || true
