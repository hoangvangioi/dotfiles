#!/bin/bash

set -euo pipefail

DEFAULT_BASE_URL="__DOTFILES_BASE_URL__"
BASE_URL=${DOTFILES_BASE_URL:-$DEFAULT_BASE_URL}
BASE_URL=${BASE_URL%/}

if [[ -n "${DOTFILES_TARBALL_URL:-}" ]]; then
    TARBALL_URL="${DOTFILES_TARBALL_URL}"
else
    if [[ ! "$BASE_URL" =~ ^https?:// ]]; then
        echo "Error: DOTFILES_BASE_URL is not set. Please set DOTFILES_BASE_URL or DOTFILES_TARBALL_URL." >&2
        exit 1
    fi

    TARBALL_URL="${BASE_URL}/dotfiles.tar.gz"
fi

TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "${TEMP_DIR}"
}

trap cleanup EXIT INT TERM

ARCHIVE_PATH="${TEMP_DIR}/dotfiles.tar.gz"

curl -fsSL "${TARBALL_URL}" -o "${ARCHIVE_PATH}"
tar -xzf "${ARCHIVE_PATH}" -C "${TEMP_DIR}"

if [[ -f "${TEMP_DIR}/install.sh" ]]; then
    WORK_DIR="${TEMP_DIR}"
elif [[ -d "${TEMP_DIR}/dotfiles" && -f "${TEMP_DIR}/dotfiles/install.sh" ]]; then
    WORK_DIR="${TEMP_DIR}/dotfiles"
else
    echo "Error: install.sh not found in downloaded archive." >&2
    exit 1
fi

cd "${WORK_DIR}"

chmod +x install.sh
exec bash install.sh "$@"
