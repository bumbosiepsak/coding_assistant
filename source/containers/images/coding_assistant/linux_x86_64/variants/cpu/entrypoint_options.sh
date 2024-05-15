#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo >&2 "ERROR: This file is supposed to be sourced!"
    exit 1
fi

CODING_ASSISTANT_RUNTIME_PARAMS=(
    --auto-devices
    --disk
    --disk-cache-dir "${CODING_ASSISTANT_DIRECTORY}/app/cache"
    --listen
    --trust-remote-code
)
