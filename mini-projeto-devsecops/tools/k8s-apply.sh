#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$( cd "${SCRIPT_DIR}/.." && pwd )"
docker run --rm -v "${REPO_DIR}/kind":/root/.kube -v "${REPO_DIR}/k8s":/k8s bitnami/kubectl:1.30 \
  --context kind-dev --kubeconfig /root/.kube/kubeconfig apply -f /k8s
