# syntax=docker/dockerfile:1.7.0

ARG DOCKER_REGISTRY
ARG VERSION_TAG
FROM ${DOCKER_REGISTRY}/base-linux_x86_64:${VERSION_TAG}

LABEL com.opera.schema-version="1.0"
LABEL com.opera.platform="linux"
LABEL com.opera.system="x86_64"

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.description="An AI-powered coding assistant - model download"
LABEL org.label-schema.vendor="Opera Software"

# ---------------------------------------------------------------------------

ENV MODEL_DOWNLOADER_DIRECTORY=/opt/model_downloader

VOLUME "${CODING_ASSISTANT_DIRECTORY}/app/cache"
VOLUME "${CODING_ASSISTANT_DIRECTORY}/app/models"

ARG PYPI_REPOSITORY=pypi.org/simple

COPY --chmod=644 source/containers/images/image_downloader/${PLATFORM_AND_SYSTEM}/requirements.txt "${MODEL_DOWNLOADER_DIRECTORY}/requirements.txt"

RUN --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=pip3_cache,target=/tmp/pip3/cache \
    <<EOF
    echo >&2 "Model downloader"

    assert_is_pip3_cache_accessible.sh /tmp/pip3/cache

    python3 -m venv "${MODEL_DOWNLOADER_DIRECTORY}/venv"

    source "${MODEL_DOWNLOADER_DIRECTORY}/venv/bin/activate"

    pip3 install \
        --cache-dir /tmp/pip3/cache \
        --index-url "https://$PYPI_REPOSITORY" \
        --requirement "${MODEL_DOWNLOADER_DIRECTORY}/requirements.txt"
EOF

COPY --chmod=755 source/containers/images/image_downloader/${PLATFORM_AND_SYSTEM}/download_model.sh /download_model.sh

USER ${USER_NAME}
