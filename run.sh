#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

echo >&2 "INFO: Building and running the dockerized 'coding_assistant' service"
echo >&2 "INFO: Once running, please open: 'http://localhost:7860' in your WEB browser and follow README.md advice"

export PROJECT_ROOT="$(readlink -e $(dirname "${0}"))"

source "${PROJECT_ROOT}/source/glue/runners.sh"

validate_provisioning

# NOTE: Performing a full build+cleanup+run cycle for the sake of demo simplicity
run_server regular_service
