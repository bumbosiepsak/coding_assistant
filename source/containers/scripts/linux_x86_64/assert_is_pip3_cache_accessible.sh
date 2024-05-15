#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

PIP3_CACHE_PATH="$1"

USER=$(id --user)
OWNER=$(stat --format=%u "$PIP3_CACHE_PATH")

if test "${USER}" != "${OWNER}"; then
    echo >&2 "ERROR: Expecting current user owning pip3 cache location: ${PIP3_CACHE_PATH}"
    exit 1
fi
