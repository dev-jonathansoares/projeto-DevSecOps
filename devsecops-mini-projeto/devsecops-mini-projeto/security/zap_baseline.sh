#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:-http://app:5001}"
echo "[*] Running OWASP ZAP Baseline scan against $TARGET"
docker run --rm --network devsecops_net owasp/zap2docker-stable zap-baseline.py -t "$TARGET" -r zap_report.html || true
echo "[*] ZAP baseline done. If running in CI, collect zap_report.html as an artifact."
