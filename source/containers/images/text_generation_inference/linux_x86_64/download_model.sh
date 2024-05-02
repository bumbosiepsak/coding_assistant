#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

LLM_MODEL_NAME="${1}"
LLM_MODEL_VERSION="${2}"

function exit_handler {
    exit 0
}

trap exit_handler SIGTERM SIGINT SIGQUIT SIGHUP

source "${MODEL_DOWNLOADER_DIRECTORY}/venv/bin/activate"

# NOTE: Using the access token from the HF_TOKEN secret
huggingface-cli download \
    "${LLM_MODEL_NAME}" \
    --cache-dir "${IMAGE_ASSISTANT_DIRECTORY}/app/models/models_cache" \
    --local-dir "${IMAGE_ASSISTANT_DIRECTORY}/app/models/${LLM_MODEL_NAME////-}" \
    --repo-type model \
    --resume-download \
    --revision "${LLM_MODEL_VERSION}"
