#!/bin/sh
# Copyright (C) 2019 Ultimaker B.V.
#

set -eu

SRC_DIR="$(cd "$(dirname "${0}")" && pwd)"
DIST_DIR="${SRC_DIR}/dist"

deliver_pkg()
{
    cp "${DIST_DIR}/"*".deb" "${SRC_DIR}/"
}

run_tests()
{
    echo "There are no tests available for this repository."
}

usage()
{
    echo "Usage: ${0} [OPTIONS]"
    echo "  -c   Clean the build output directory"
    echo "  -h   Print usage"
}

while getopts ":ch" options; do
    case "${options}" in
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

if ! command -v docker > /dev/null 2>&1; then
    echo "Docker not found, docker-less builds are not supported."
    exit 1
fi

echo "Building mjpg-streamer .deb for arm64 via Docker..."
docker build \
    --target export \
    --output "type=local,dest=${DIST_DIR}" \
    "${SRC_DIR}"

deliver_pkg

exit 0
