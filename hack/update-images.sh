#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$(dirname "${BASH_SOURCE[0]}")"
ROOT_DIR="$(realpath "${DIR}/..")"

# Find all images referenced in YAML files and format for registry
grep -Eh "kind-registry:5000/|localhost:5001/" \
  $(find "${ROOT_DIR}" -iname "*.yaml") |
  sed -E 's#.*(kind-registry:5000/|localhost:5001/)##g; s/"//g' |
  sort |
  uniq >"${DIR}/images.txt"
