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
    echo >&2 "INFO: You're downloading a full demo with the 'HuggingFaceH4/starchat-beta' model (59GB)"

    LLM_MODEL_NAME="HuggingFaceH4/starchat-beta"
    LLM_MODEL_VERSION="b1bcda690655777373f57ea6614eb095ec2c886f"
    LLM_MODEL_URI="https://huggingface.co/HuggingFaceH4/starchat-beta"
    IS_GATED_MODEL=0

elif [[ "${1:-not_small}" == "small" ]]; then
    echo >&2 "INFO: You're downloading a smaller demo with the 'google-t5/t5-small' model (2GB)"

    LLM_MODEL_NAME="google-t5/t5-small"
    LLM_MODEL_VERSION="df1b051c49625cf57a3d0d8d3863ed4d13564fe4"
    LLM_MODEL_URI="https://huggingface.co/google-t5/t5-small"
    IS_GATED_MODEL=0

else
    echo >&2 "ERROR: Expecting a model to be chosen for download"
    echo >&2 "INFO: Please type: 'download_model.sh full' for a full, 59GB download (HuggingFaceH4/starchat-beta)"
    echo >&2 "INFO: Please type: 'download_model.sh small' for a smaller, 2GB download (google-t5/t5-small)"

    exit 1
fi

if ((${IS_GATED_MODEL})); then
    validate_gated_model_access "${LLM_MODEL_NAME}" "${LLM_MODEL_URI}"

    export HUGGING_FACE_HUB_TOKEN="${HF_TOKEN}" # NOTE: Feed "text-generation-inference" too
else
    # NOTE: No special access rights needed
    export HF_TOKEN=
    export HUGGING_FACE_HUB_TOKEN=
fi

run_command \
    --entrypoint /download_model.sh \
    --env HF_HUB_ENABLE_HF_TRANSFER=1 \
    --env HF_TOKEN \
    --env HUGGING_FACE_HUB_TOKEN \
    --interactive \
    image_downloader \
        "${LLM_MODEL_NAME}" \
        "${LLM_MODEL_VERSION}"
