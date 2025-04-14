#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$(dirname "${BASH_SOURCE[0]}")"

ROOT_DIR="$(realpath "${DIR}/../../..")"

log_files=("${ROOT_DIR}"/logs/kube-apiserver-audit.*.log)

cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    component: kube-apiserver-audit-exporter
  name: kube-apiserver-audit-exporter
  namespace: kube-system
spec:
  template:
    spec:
      containers:
      - name: exporter
        args:
        - --delay
        - 2s
        - --replay
EOF

for file in "${log_files[@]}"; do
  filename="$(basename "${file}")"
  if [[ "${filename}" == "kube-apiserver-audit.log" ]]; then
    continue
  fi
  name="${filename%.log}"
  name="${name#kube-apiserver-audit.}"
  cat <<EOF
        - --audit-log-path
        - /var/log/kubernetes/${filename}:${name}
EOF
done
