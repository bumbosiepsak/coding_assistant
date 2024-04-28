#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

export PROJECT_ROOT="$(readlink -e $(dirname "${0}"))"

source "${PROJECT_ROOT}/source/glue/runners.sh"

validate_provisioning

# NOTE: Substantial logic hardcoded here for the sake of demo simplicity
if [[ "${1:-not_full}" == "full" ]]; then
    echo >&2 "INFO: You're downloading a full demo with the 'bigcode/starcoderplus' model (59GB)"

    if [[ "${HF_TOKEN:-not_set}" == "not_set" ]]; then
        echo >&2 "ERROR: No HuggingFace access token present in the HF_TOKEN environment variable"
        echo >&2 "INFO: 'bigcode/starcoderplus' is a gated model and requires gaining access rights prior to download"
        echo >&2 "INFO: 1. Please obtain your personal access key from: https://huggingface.co/settings/tokens"
        echo >&2 "INFO: 2. Then pass it via the HF_TOKEN environment variable, e.g. by setting: 'export HF_TOKEN=<token here>'"
        echo >&2 "INFO: 3. Then ask for access in: https://huggingface.co/bigcode/starcoderplus"
        echo >&2 "INFO: 4. Once access is granted, then run 'download_model.sh' again (within the shell from point 2)"

        exit 1
    fi

    LLM_MODEL_NAME=bigcode/starcoderplus
    LLM_MODEL_VERSION=6bd835911561b927265e9e2c70ecf32521518c0f

elif [[ "${1:-not_small}" == "small" ]]; then
    echo >&2 "INFO: You're downloading a smaller demo with the 'google-t5/t5-small' model (2GB)"

    if [[ "${HF_TOKEN:-not_set}" == "not_set" ]]; then
        export HF_TOKEN= # NOTE: No special access rights needed in the 't5-small' case
    fi

    LLM_MODEL_NAME=google-t5/t5-small
    LLM_MODEL_VERSION=df1b051c49625cf57a3d0d8d3863ed4d13564fe4
else
    echo >&2 "ERROR: Expecting a model to be chosen for download"
    echo >&2 "INFO: Please type: 'download_model.sh full' for a full, 59GB download (bigcode/starcoderplus)"
    echo >&2 "INFO: Please type: 'download_model.sh small' for a smaller, 2GB download (google-t5/t5-small)"

    exit 1
fi

run_command \
    --entrypoint /download_model.sh \
    --env HF_HUB_ENABLE_HF_TRANSFER=1 \
    --env HF_TOKEN \
    --interactive \
    coding_assistant \
        "${LLM_MODEL_NAME}" \
        "${LLM_MODEL_VERSION}"
