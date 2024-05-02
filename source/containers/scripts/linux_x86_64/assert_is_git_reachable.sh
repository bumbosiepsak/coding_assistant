#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

REPOSITORY="$1"

export GIT_SSH_COMMAND="ssh -o ConnectTimeout=5 -o BatchMode=yes"

if ! git ls-remote "$REPOSITORY" &> /dev/null; then
    MESSAGE="$(git ls-remote "$REPOSITORY" 2>&1 > /dev/null || true)"

    if [[ "$MESSAGE" == *"Connection timed out"*  ]]; then
        echo >&2 "ERROR: Connection with GIT repository $REPOSITORY failed. Make sure your network/VPN works"
    elif [[ "$MESSAGE" == *"Permission denied"*  ]]; then
        echo >&2 "ERROR: Permission denied by GIT repository $REPOSITORY. Make sure your SSH key is permitted and is added to an SSH agent"
    else
        echo -n >&2 "ERROR: Could not access the GIT repository $REPOSITORY: $MESSAGE"
    fi
	exit 1
fi
