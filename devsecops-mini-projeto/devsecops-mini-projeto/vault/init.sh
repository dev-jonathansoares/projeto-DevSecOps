#!/usr/bin/env bash
set -euo pipefail
export VAULT_ADDR=${VAULT_ADDR:-http://localhost:8200}
export VAULT_TOKEN=${VAULT_TOKEN:-root}
echo "[*] Enabling KV v2 at path 'secret' (if not already)"
vault secrets enable -path=secret -version=2 kv || true
echo "[*] Writing demo secret"
vault kv put secret/app/config api_key="super-secret-demo-key"
echo "[*] Done."
