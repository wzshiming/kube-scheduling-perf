#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$(dirname "${BASH_SOURCE[0]}")"

ROOT_DIR="$(realpath "${DIR}/..")"

function format() {
  echo "Update shell format"
  mapfile -t findfiles < <(find . \( \
    -iname "*.sh" \
    \))
  go run mvdan.cc/sh/v3/cmd/shfmt@v3.7.0 -w -i=2 "${findfiles[@]}"
}

cd "${ROOT_DIR}" && format
