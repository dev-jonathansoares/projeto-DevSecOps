#!/usr/bin/env bash
set -euo pipefail
NS="${1:-devsecops-demo}"
echo "[*] Creating Jenkins (ephemeral) in namespace: $NS"
oc project "$NS" >/dev/null 2>&1 || oc new-project "$NS"
oc new-app jenkins-ephemeral -n "$NS"
echo "[*] Granting 'edit' role to Jenkins SA on namespace $NS"
oc policy add-role-to-user edit "system:serviceaccount:${NS}:jenkins" -n "$NS"
echo "[*] Exposing Jenkins route"
oc expose svc/jenkins -n "$NS" || true
echo "[*] Jenkins URL:"
oc get route jenkins -n "$NS" -o jsonpath='{.spec.host}{"\n"}'