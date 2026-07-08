#!/bin/sh
# Copyright (C) 2019 Ultimaker B.V.
#

set -eu

SRC_DIR="$(cd "$(dirname "${0}")" && pwd)"
DIST_DIR="${SRC_DIR}/dist"

RELEASE_VERSION="${RELEASE_VERSION:-9999.99.99}"
DOCKER_IMAGE_NAME="ghcr.io/ultimaker/mjpg-streamer"

deliver_pkg()
{
    cp "${DIST_DIR}/"*".deb" "${SRC_DIR}/"
}

# Warm the builder-stage layer cache in the GitHub Container Registry so that
# subsequent CI builds skip the apt-get install step.
build_docker_cache()
{
    docker buildx create --name ultimaker --driver=docker-container 2>/dev/null || true
    docker buildx build \
        --builder ultimaker \
        --target builder \
        --cache-to  "type=registry,ref=${DOCKER_IMAGE_NAME}" \
        --cache-from "type=registry,ref=${DOCKER_IMAGE_NAME}" \
        "${SRC_DIR}"
}

# Cross-compile and package the .deb.  Pulls the builder-stage cache when
# available so the apt install layer is reused.
build()
{
    docker buildx create --name ultimaker --driver=docker-container 2>/dev/null || true
    mkdir -p "${DIST_DIR}"
    docker buildx build \
        --builder ultimaker \
        --target export \
        --output "type=local,dest=${DIST_DIR}" \
        --cache-from "type=registry,ref=${DOCKER_IMAGE_NAME}" \
        --build-arg "RELEASE_VERSION=${RELEASE_VERSION}" \
        "${SRC_DIR}"
    deliver_pkg
}

# Run shellcheck over every .sh file in the repo.
shellcheck_scripts()
{
    find "${SRC_DIR}" -name "*.sh" -not -path "*/.git/*" -exec shellcheck {} +
}

usage()
{
    echo "Usage: ${0} [OPTIONS]"
    echo "  -a build               Cross-compile and produce the arm64 .deb"
    echo "  -a build_docker_cache  Build and push Docker layer cache to GHCR"
    echo "  -a shellcheck          Run shellcheck on all .sh files"
    echo "  -c                     Clean the build output directory"
    echo "  -h                     Print usage"
}

ACTION=""

while getopts ":a:ch" options; do
    case "${options}" in
    a)
        ACTION="${OPTARG}"
        ;;
    c)
        rm -rf "${DIST_DIR}" "${SRC_DIR}/"*.deb
        exit 0
        ;;
    h)
        usage
        exit 0
        ;;
    :)
        echo "Option -${OPTARG} requires an argument."
        exit 1
        ;;
    ?)
        echo "Invalid option: -${OPTARG}"
        exit 1
        ;;
    esac
done
shift "$((OPTIND - 1))"

case "${ACTION}" in
    build|build_docker_cache|"")
        if ! command -v docker > /dev/null 2>&1; then
            echo "Docker not found, docker-less builds are not supported."
            exit 1
        fi
        ;;
esac

case "${ACTION}" in
    build)
        build
        ;;
    build_docker_cache)
        build_docker_cache
        ;;
    shellcheck)
        shellcheck_scripts
        ;;
    "")
        # No -a flag: default to build (backward-compatible with old callers)
        build
        ;;
    *)
        echo "Unknown action: ${ACTION}"
        usage
        exit 1
        ;;
esac

exit 0
