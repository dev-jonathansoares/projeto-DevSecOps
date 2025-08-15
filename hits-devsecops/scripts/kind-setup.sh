#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="kind"
CONFIG="k8s/kind-config.yaml"

echo "[1/4] Creating kind cluster (if not exists) ..."
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  kind create cluster --name "${CLUSTER_NAME}" --config "${CONFIG}"
else
  echo "Kind cluster '${CLUSTER_NAME}' already exists."
fi

echo "[2/4] Connecting this container/host to 'kind' network if needed ..."
# If running inside a container you can connect it to the 'kind' network like this:
# docker network connect kind $(cat /etc/hostname) || true

echo "[3/4] Patching kubeconfig for use from *containers* (replace 127.0.0.1 with control-plane IP) ..."
CONTROL_PLANE_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CLUSTER_NAME}-control-plane)
KUBECONFIG_ORIG="${HOME}/.kube/config"
KUBECONFIG_DOCKER="k8s/kubeconfig-kind-in-docker"

if [ -f "${KUBECONFIG_ORIG}" ]; then
  sed "s#server: https://127.0.0.1:[0-9]*#server: https://${CONTROL_PLANE_IP}:6443#g" "${KUBECONFIG_ORIG}" > "${KUBECONFIG_DOCKER}"
  echo "Wrote container-friendly kubeconfig to ${KUBECONFIG_DOCKER} (server=https://${CONTROL_PLANE_IP}:6443)"
else
  echo "WARNING: kubeconfig not found at ${KUBECONFIG_ORIG}. Make sure 'kind' created it."
fi

echo "[4/4] Load local image example (optional):"
echo "  docker build -t hits-api:local . && kind load docker-image hits-api:local"
