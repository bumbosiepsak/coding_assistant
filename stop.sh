#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

echo >&2 "INFO: Stopping the dockerized 'coding_assistant' service"

export PROJECT_ROOT="$(readlink -e $(dirname "${0}"))"

source "${PROJECT_ROOT}/source/glue/runners.sh"

validate_provisioning

stop_server
