#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

USER_NAME=${1}
USER_UID=${2}
USER_GID=${3}

if ! id ${USER_UID} &> /dev/null; then
    groupadd --gid ${USER_GID} ${USER_NAME}

    useradd \
        --create-home --home-dir /home/${USER_NAME} \
        --uid ${USER_UID} \
        --gid ${USER_GID} \
        --shell /bin/bash \
        ${USER_NAME}

    passwd --delete ${USER_NAME}

    mkdir --parents /usr/local/share/create_user

    find /usr/local/share/create_user/ -name "*.sh" -exec {} "${@}" \;
fi
