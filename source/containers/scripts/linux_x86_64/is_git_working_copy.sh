#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

BRANCH="${1}"
GIT_COPY="${2}"

git -C "${GIT_COPY}" fsck --connectivity-only --no-progress &> /dev/null
git -C "${GIT_COPY}" describe --tags --exact-match | grep "${BRANCH}" > /dev/null
