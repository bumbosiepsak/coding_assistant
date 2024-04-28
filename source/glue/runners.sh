#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo >&2 "ERROR: This file is supposed to be sourced!"
    exit 1
fi

PROJECT_COMPOSE_FILE="source/containers/docker-compose.yaml"
PROJECT_NAME="coding_assistant"

function validate_provisioning() {
    if ! command -v docker > /dev/null 2>&1; then
        echo >&2 "ERROR: 'docker' not installed. Please install e.g. with the 'provision_linux_x86_64.sh' script"
        exit 1
    fi

    if ! command -v docker compose > /dev/null 2>&1; then
        echo >&2 "ERROR: 'docker compose' not installed. Please install e.g. with the 'provision_linux_x86_64.sh' script"
        exit 1
    fi

    if ! docker buildx > /dev/null 2>&1; then
        echo >&2 "ERROR: 'docker buildx' not installed. Please install e.g. with the 'provision_linux_x86_64.sh' script"
        exit 1
    fi
}

function validate_gated_model_access() {
    local MODEL_NAME="${1}"
    local MODEL_URI="${2}"

    if [[ "${HF_TOKEN:-not_set}" == "not_set" ]]; then
        echo >&2 "ERROR: No HuggingFace access token present in the HF_TOKEN environment variable"
        echo >&2 "INFO: ${MODEL_NAME} is a gated model and requires gaining access rights prior to download"
        echo >&2 "INFO: 1. Please obtain your personal access key from: https://huggingface.co/settings/tokens"
        echo >&2 "INFO: 2. Then pass it via the HF_TOKEN environment variable, e.g. by setting: 'export HF_TOKEN=<token here>'"
        echo >&2 "INFO: 3. Then ask for access in: ${MODEL_URI}"
        echo >&2 "INFO: 4. Once access is granted, then run 'download_model.sh' again (within the shell from point 2)"

        exit 1
    fi
}

function run_server() {
    local PROFILE="${1}"

    export USER_UID="${USER_UID:-"$(id --user)"}"
    export USER_GID="${USER_GID:-"$(id --group)"}"

    mkdir --parents "${PROJECT_ROOT}/volumes/config"
    mkdir --parents "${PROJECT_ROOT}/volumes/models"

    docker compose \
        --env-file "${PROJECT_ROOT}/source/containers/docker-compose-service.env" \
        --file "${PROJECT_ROOT}/${PROJECT_COMPOSE_FILE}" \
        --profile "${PROFILE}" \
        --project-directory "${PROJECT_ROOT}" \
        --project-name "${PROJECT_NAME}" \
        up \
            --build \
            --detach \
            --force-recreate \
            --remove-orphans
}

function stop_server() {
    local PROFILE="${1}"

    docker compose \
        --env-file "${PROJECT_ROOT}/source/containers/docker-compose-service.env" \
        --file "${PROJECT_ROOT}/${PROJECT_COMPOSE_FILE}" \
        --profile "${PROFILE}" \
        --project-directory "${PROJECT_ROOT}" \
        --project-name "${PROJECT_NAME}" \
        down \
            --remove-orphans
}

function run_command() {
    local ARGUMENTS="${@}"

    docker compose \
        --env-file "${PROJECT_ROOT}/source/containers/docker-compose-service.env" \
        --file "${PROJECT_ROOT}/${PROJECT_COMPOSE_FILE}" \
        --project-directory "${PROJECT_ROOT}" \
        --project-name "${PROJECT_NAME}" \
        run \
            --rm \
            "${@}"
}
