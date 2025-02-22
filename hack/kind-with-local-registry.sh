#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$(dirname "${BASH_SOURCE[0]}")"
ROOT_DIR="$(realpath "${DIR}/..")"

# https://kind.sigs.k8s.io/docs/user/local-registry/

# Registry configuration
reg_name='kind-registry'
reg_port='5001'

in_cluster_registry="${reg_name}:5000"
registry_dir="/etc/containerd/certs.d/${in_cluster_registry}"

# Create kind cluster with containerd registry configuration
kind create cluster --config "${ROOT_DIR}/kind.yaml"

# Configure containerd registry hosts on all nodes
for node in $(kind get nodes); do
  docker exec "${node}" mkdir -p "${registry_dir}"
  docker exec -i "${node}" tee "${registry_dir}/hosts.toml" >/dev/null <<EOF
[host."http://${in_cluster_registry}"]
EOF
done

# Connect registry to kind network if not already connected
if [[ "$(docker inspect -f '{{json .NetworkSettings.Networks.kind}}' "${reg_name}")" == 'null' ]]; then
  docker network connect "kind" "${reg_name}"
fi

# Document the local registry
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "${in_cluster_registry}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF
