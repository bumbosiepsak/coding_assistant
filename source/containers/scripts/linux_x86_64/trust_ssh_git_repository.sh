#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

REPOSITORY="$1"

SERVER="$(sed 's/.*@\(.*\):.*/\1/' <<< "$REPOSITORY")"

ssh-keyscan "$SERVER" >> "/etc/ssh/ssh_known_hosts"
