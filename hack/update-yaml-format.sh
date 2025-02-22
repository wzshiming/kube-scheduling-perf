#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$(dirname "${BASH_SOURCE[0]}")"

ROOT_DIR="$(realpath "${DIR}/..")"

function format() {
  echo "Update yaml format"
  mapfile -t findfiles < <(find . \( \
    -iname "*.yaml" \
    -o -iname "*.yml" \
    \))
  go run github.com/google/yamlfmt/cmd/yamlfmt@v0.16.0 -conf .yamlfmt.yaml "${findfiles[@]}"
}

cd "${ROOT_DIR}" && format
