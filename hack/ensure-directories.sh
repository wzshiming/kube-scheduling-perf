#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$(dirname "${BASH_SOURCE[0]}")"
ROOT_DIR="$(realpath "${DIR}/..")"

# Ensure all necessary directories exist with correct permissions
echo "Creating directories with correct permissions..."

# Function to ensure directory has correct ownership
ensure_directory() {
    local dir="$1"
    local current_user=$(id -un)
    local current_group=$(id -gn)
    
    # Create directory if it doesn't exist
    mkdir -p "$dir"
    
    # Check ownership
    local owner=$(stat -c '%U' "$dir" 2>/dev/null || echo "none")
    
    if [[ "$owner" == "root" ]]; then
        echo "Fixing ownership of root-owned directory: $dir"
        sudo chown -R "${current_user}:${current_group}" "$dir"
    fi
    
    chmod 755 "$dir"
    echo "Ensured directory: $dir (owner: $(stat -c '%U:%G' "$dir"))"
}

# Create logs directory
ensure_directory "${ROOT_DIR}/logs"

# Create bin directory
ensure_directory "${ROOT_DIR}/bin"

# Create gopath directory
ensure_directory "${ROOT_DIR}/gopath"

# Create registry-data directory
ensure_directory "${ROOT_DIR}/registry-data"

# Create output directory
ensure_directory "${ROOT_DIR}/output"

# Create results directory
ensure_directory "${ROOT_DIR}/results"

# Create tmp directory
ensure_directory "${ROOT_DIR}/tmp"

echo "Directories created successfully!" 