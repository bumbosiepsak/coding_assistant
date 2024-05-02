# syntax=docker/dockerfile:1.7.0

ARG DOCKER_REGISTRY
ARG VERSION_TAG
FROM ${DOCKER_REGISTRY}/base-linux_x86_64:${VERSION_TAG}

LABEL com.opera.schema-version="1.0"
LABEL com.opera.platform="linux"
LABEL com.opera.system="x86_64"

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.description="An AI-powered coding assistant"
LABEL org.label-schema.vendor="Opera Software"

# ---------------------------------------------------------------------------

ENV CODING_ASSISTANT_DIRECTORY=/opt/coding_assistant

EXPOSE 7860/tcp

HEALTHCHECK --interval=10s --start-period=5s CMD ["curl", "--fail", "--silent", "http://localhost:7860/queue/status"]

ARG PYPI_REPOSITORY=pypi.org/simple

RUN --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=pip3_cache,target=/tmp/pip3/cache \
    <<EOF
    echo >&2 "Python virtual environments"

    mkdir --parents "${CODING_ASSISTANT_DIRECTORY}/venv"

    assert_is_pip3_cache_accessible.sh /tmp/pip3/cache

    python3 -m venv "${CODING_ASSISTANT_DIRECTORY}/venv"

    source "${CODING_ASSISTANT_DIRECTORY}/venv/bin/activate"

    pip3 install --upgrade \
        pip \
        setuptools \
        wheel
EOF

COPY --chmod=644 source/containers/images/coding_assistant/${PLATFORM_AND_SYSTEM}/requirements.txt "${CODING_ASSISTANT_DIRECTORY}/requirements.txt"

RUN --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=pip3_cache,target=/tmp/pip3/cache \
    <<EOF
    echo >&2 "Runtime dependencies"

    assert_is_pip3_cache_accessible.sh /tmp/pip3/cache

    source "${CODING_ASSISTANT_DIRECTORY}/venv/bin/activate"

    pip3 install \
        --cache-dir /tmp/pip3/cache \
        --index-url "https://$PYPI_REPOSITORY" \
        --requirement "${CODING_ASSISTANT_DIRECTORY}/requirements.txt"
EOF

COPY source/services/coding_assistant "${CODING_ASSISTANT_DIRECTORY}/source/"

USER ${USER_NAME}

WORKDIR "${CODING_ASSISTANT_DIRECTORY}/source"

ENV GRADIO_SERVER_NAME="0.0.0.0"

ENTRYPOINT source "${CODING_ASSISTANT_DIRECTORY}/venv/bin/activate" && python3 "${CODING_ASSISTANT_DIRECTORY}/source/app.py"
