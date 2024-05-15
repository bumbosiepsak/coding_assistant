#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

WORKING_COPY_DIRECTORY="$1"

HEAD_REVISION="$(git -C "$WORKING_COPY_DIRECTORY" rev-parse HEAD)"
if ! git -C "$WORKING_COPY_DIRECTORY" name-rev --tags --name-only $HEAD_REVISION | grep -v undefined > /dev/null; then
	echo >&2 "ERROR: Expecting current GIT revision to be a GIT tag"
	exit 1
fi
