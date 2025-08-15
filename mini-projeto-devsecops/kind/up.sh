#!/usr/bin/env bash
set -euo pipefail
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)/config.yaml":/config.yaml -v "$(pwd)":/root kindest/kind:v0.23.0 create cluster --config /config.yaml
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)":/root kindest/kind:v0.23.0 get kubeconfig --name dev > kubeconfig
echo "kind cluster 'dev' is up."
