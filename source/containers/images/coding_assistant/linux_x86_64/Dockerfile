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

ENV IMAGE_ASSISTANT_DIRECTORY=/opt/coding_assistant
ENV MODEL_DOWNLOADER_DIRECTORY=/opt/model_downloader

VOLUME "${IMAGE_ASSISTANT_DIRECTORY}/app/cache"
VOLUME "${IMAGE_ASSISTANT_DIRECTORY}/app/models"

# NOTE: API interface
EXPOSE 5000/tcp

# NOTE: Streaming interface
EXPOSE 5005/tcp

# NOTE: WEB UI interface
EXPOSE 7860/tcp

HEALTHCHECK --interval=10s --start-period=5s CMD ["curl", "--fail", "--silent", "http://localhost:7860"]

COPY source/containers/images/coding_assistant/${PLATFORM_AND_SYSTEM}/variants "${IMAGE_ASSISTANT_DIRECTORY}/variants"

ARG PYPI_REPOSITORY=pypi.org/simple

RUN --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=pip3_cache,target=/tmp/pip3/cache \
    <<EOF
    echo >&2 "Python virtual environments"

    mkdir --parents "${IMAGE_ASSISTANT_DIRECTORY}/venv"

    assert_is_pip3_cache_accessible.sh /tmp/pip3/cache

    find "${IMAGE_ASSISTANT_DIRECTORY}/variants" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r variant_directory; do

        runtime_variant="$(basename "${variant_directory}")"

        python3 -m venv "${IMAGE_ASSISTANT_DIRECTORY}/venv/${runtime_variant}"

        source "${IMAGE_ASSISTANT_DIRECTORY}/venv/${runtime_variant}/bin/activate"

        pip3 install --upgrade \
            pip \
            setuptools \
            wheel
    done
EOF

COPY --chmod=644 source/containers/images/coding_assistant/${PLATFORM_AND_SYSTEM}/requirements.txt "${MODEL_DOWNLOADER_DIRECTORY}/requirements.txt"

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

RUN --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=pip3_cache,target=/tmp/pip3/cache \
    <<EOF
    echo >&2 "Hardware runtime_variant dependencies"

    assert_is_pip3_cache_accessible.sh /tmp/pip3/cache

    find "${IMAGE_ASSISTANT_DIRECTORY}/variants" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r variant_directory; do

        runtime_variant="$(basename "${variant_directory}")"
        source "${IMAGE_ASSISTANT_DIRECTORY}/venv/${runtime_variant}/bin/activate"

        pip3 install \
            --cache-dir /tmp/pip3/cache \
            --extra-index-url "$(cat "${variant_directory}/pip3_index.txt")" \
            --index-url "https://$PYPI_REPOSITORY" \
            --requirement "${variant_directory}/requirements.txt"
    done
EOF

ARG TEXT_GENERATION_WEBUI_REPOSITORY=not_set
ARG TEXT_GENERATION_WEBUI_VERSION=not_set

RUN --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=pip3_cache,target=/tmp/pip3/cache \
    --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=tmp_git_cache_text_generation_webui,target=/tmp/git_cache/text-generation-webui \
    <<EOF
    echo >&2 "oobabooga/text-generation-webui"

    BRANCH=${TEXT_GENERATION_WEBUI_VERSION}
    REMOTE=${TEXT_GENERATION_WEBUI_REPOSITORY}
    GIT_COPY="/tmp/git_cache/text-generation-webui/text-generation-webui"

    assert_is_git_reachable.sh "$REMOTE"

    if ! is_git_working_copy.sh "$BRANCH" "$GIT_COPY"; then
        rm --recursive --force "$GIT_COPY"

        git clone -c advice.detachedHead=false --depth 1 --single-branch --branch "$BRANCH" "$REMOTE" "$GIT_COPY"
    fi

    cp --archive --recursive "${GIT_COPY}" "${IMAGE_ASSISTANT_DIRECTORY}/app"

    mkdir --parents ${IMAGE_ASSISTANT_DIRECTORY}/shared/models
    cp --archive --recursive "${GIT_COPY}/models/config.yaml" "${IMAGE_ASSISTANT_DIRECTORY}/shared/models/config.yaml"

    assert_is_pip3_cache_accessible.sh /tmp/pip3/cache

    find "${IMAGE_ASSISTANT_DIRECTORY}/variants" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r variant_directory; do

        runtime_variant="$(basename "${variant_directory}")"
        source "${IMAGE_ASSISTANT_DIRECTORY}/venv/${runtime_variant}/bin/activate"

        pip3 install \
            --cache-dir /tmp/pip3/cache \
            --extra-index-url "$(cat "${variant_directory}/pip3_index.txt")" \
            --index-url "https://$PYPI_REPOSITORY" \
            --requirement "${GIT_COPY}/$(cat "${variant_directory}/requirements_path.txt")"

        find "${GIT_COPY}/extensions" -name requirements.txt -type f | while IFS= read -r extension_requirement; do
            pip3 install \
                --cache-dir /tmp/pip3/cache \
                --extra-index-url "$(cat "${variant_directory}/pip3_index.txt")" \
                --requirement "${extension_requirement}"
        done
    done
EOF

COPY --chmod=755 source/containers/images/coding_assistant/${PLATFORM_AND_SYSTEM}/download_model.sh /download_model.sh
COPY --chmod=755 source/containers/images/coding_assistant/${PLATFORM_AND_SYSTEM}/entrypoint.sh /entrypoint.sh

USER ${USER_NAME}

WORKDIR "${IMAGE_ASSISTANT_DIRECTORY}/app"

ENTRYPOINT ["bash", "/entrypoint.sh"]
