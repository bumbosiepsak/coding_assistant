#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

RUNTIME_VARIANT="${1}"

function exit_handler {
    exit 0
}

trap exit_handler SIGTERM SIGINT SIGQUIT SIGHUP

if [ ! -f "${IMAGE_ASSISTANT_DIRECTORY}/app/models/config.yaml" ]; then
    cp --archive --recursive "${IMAGE_ASSISTANT_DIRECTORY}/shared/models/config.yaml" "${IMAGE_ASSISTANT_DIRECTORY}/app/models/config.yaml"
fi

source "${IMAGE_ASSISTANT_DIRECTORY}/venv/${RUNTIME_VARIANT}/bin/activate"

source "${IMAGE_ASSISTANT_DIRECTORY}/variants/${RUNTIME_VARIANT}/entrypoint_options.sh"

python3 "${IMAGE_ASSISTANT_DIRECTORY}/app/server.py" "${CODING_ASSISTANT_RUNTIME_PARAMS[@]}"
