#!/usr/bin/env bash
# Fertilise a vanilla (Ubuntu) machine with project dependencies.
#
# Run this script as root or provide equivalent dependencies with your favourite method.

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

echo >&2 'Installing: Docker'

apt-get update && apt-get install --yes --no-install-recommends \
    docker-buildx \
    docker-compose-v2 \
    docker.io

systemctl restart dockerd

echo >&2 'Install done: Docker. Remember to log in to the Docker registry now!'

echo >&2 'Configuring: Docker-Buildx as the default builder'

docker buildx install

echo >&2 'Configuring done: Docker-Buildx as the default builder'

echo >&2 'Provisioning done'
