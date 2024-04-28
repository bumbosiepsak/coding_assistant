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

# NOTE: Substantial logic hardcoded here for the sake of demo simplicity
if [[ "${1:-not_full}" == "full" ]]; then
    echo >&2 "INFO: You're running a full demo with the 'HuggingFaceH4/starchat-beta' model (59GB)"

    export LLM_MODEL_NAME="HuggingFaceH4/starchat-beta"

elif [[ "${1:-not_small}" == "small" ]]; then
    echo >&2 "INFO: You're running a smaller demo with the 'google-t5/t5-small' model (2GB)"

    export LLM_MODEL_NAME="google-t5/t5-small"

else
    echo >&2 "ERROR: Expecting a model to be chosen"
    echo >&2 "INFO: Please type: 'run.sh full' for a HuggingFaceH4/starchat-beta demo"
    echo >&2 "INFO: Please type: 'run.sh small' for a google-t5/t5-small demo"

    exit 1
fi

# NOTE: Performing a full build+cleanup+run cycle for the sake of demo simplicity
run_server regular_service
