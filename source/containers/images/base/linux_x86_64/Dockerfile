# syntax=docker/dockerfile:1.7.0

ARG DOCKER_IMAGE_BASE
ARG DOCKER_REGISTRY
FROM ${DOCKER_REGISTRY}/${DOCKER_IMAGE_BASE}

LABEL com.opera.schema-version="1.0"
LABEL com.opera.platform="linux"
LABEL com.opera.system="x86_64"

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.description="A base Docker image for the 'Clone Coding Task'"
LABEL org.label-schema.vendor="Clone Robotics"

# ---------------------------------------------------------------------------

ENV IS_INSIDE_CONTAINER=1
ENV PLATFORM_AND_SYSTEM="linux_x86_64"

ARG DEBIAN_FRONTEND=noninteractive

# NOTE: Needed to fix requests/certifi behaviour on Debian, so that it uses system certstore again
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

USER root
SHELL ["/bin/bash", "-o", "errexit", "-o", "errtrace", "-o", "nounset", "-o", "pipefail", "-c"]

COPY --chmod=755 source/containers/scripts/${PLATFORM_AND_SYSTEM}/assert_is_git_reachable.sh /usr/local/bin/assert_is_git_reachable.sh
COPY --chmod=755 source/containers/scripts/${PLATFORM_AND_SYSTEM}/assert_is_pip3_cache_accessible.sh /usr/local/bin/assert_is_pip3_cache_accessible.sh
COPY --chmod=755 source/containers/scripts/${PLATFORM_AND_SYSTEM}/create_user.sh /usr/local/bin/create_user.sh
COPY --chmod=755 source/containers/scripts/${PLATFORM_AND_SYSTEM}/is_git_working_copy.sh /usr/local/bin/is_git_working_copy.sh
COPY --chmod=755 source/containers/scripts/${PLATFORM_AND_SYSTEM}/trust_ssh_git_repository.sh /usr/local/bin/trust_ssh_git_repository.sh

# IMPORTANT: This requires mounting of external apt cache for any apt operations.
# Otherwise the image will become bloated with package downloads.
RUN rm --force /etc/apt/apt.conf.d/docker-clean
COPY source/containers/files/${PLATFORM_AND_SYSTEM}/80-retries /etc/apt/apt.conf.d/80-retries
COPY source/containers/files/${PLATFORM_AND_SYSTEM}/99-local /etc/apt/apt.conf.d/99-local
COPY source/containers/files/${PLATFORM_AND_SYSTEM}/keep-cache /etc/apt/apt.conf.d/keep-cache

ENV USER_NAME=pavarotti_at_work
ARG USER_UID
ARG USER_GID
RUN create_user.sh ${USER_NAME} ${USER_UID} ${USER_GID}

RUN --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=var_cache_apt,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=var_lib_apt,target=/var/lib/apt \
    <<EOF
    echo >&2 "APT packages"

    apt-get --allow-releaseinfo-change update && apt-get install --yes --no-install-recommends \
        locales \
        sed

    sed --in-place 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
    locale-gen
    update-locale LANG=en_US.utf8
EOF

# NOTE: Needs to happen in Docker despite 'update-locale'
ENV LANG=en_US.UTF-8
ENV PYTHONUNBUFFERED=1

ARG APT_FAST_VERSION=v1.9.12
COPY --chmod=755 source/containers/third-party/apt-fast/${APT_FAST_VERSION}/apt-fast /usr/local/sbin/apt-fast
COPY --chmod=644 source/containers/third-party/apt-fast/${APT_FAST_VERSION}/apt-fast.conf /etc/apt-fast.conf

RUN --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=var_cache_apt,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=var_lib_apt,target=/var/lib/apt \
    <<EOF
    echo >&2 "apt-fast"

    apt-get --allow-releaseinfo-change update && apt-get install --yes --no-install-recommends \
        aria2
EOF

RUN --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=var_cache_apt,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,mode=0755,uid=0,gid=0,id=var_lib_apt,target=/var/lib/apt \
    <<EOF
    echo >&2 "APT packages"

    apt-fast --allow-releaseinfo-change update && apt-fast install --yes --no-install-recommends \
        ca-certificates \
        curl \
        git \
        git-lfs \
        openssh-client \
        python3 \
        python3-pip \
        python3-venv \
        python3-wheel
EOF


