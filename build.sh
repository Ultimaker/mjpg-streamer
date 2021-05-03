#!/bin/bash
# shellcheck disable=SC1117

set -eux

# common directory variablesS
SRC_DIR="$(pwd)"
BUILD_DIR_TEMPLATE="_build"
BUILD_DIR="${BUILD_DIR:-${SRC_DIR}/${BUILD_DIR_TEMPLATE}}"

DEBIAN_DIR="${BUILD_DIR}/debian"


build()
{
    # Start with a clean build
    if [ -d "${BUILD_DIR}" ] && [ -z "${BUILD_DIR##*_build*}" ]; then
        rm -rf "${BUILD_DIR}"
    fi
    
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"
    
    cmake ../
    
    make clean all
    
    echo "Finished building."
}


create_debian_package()
{
    echo "Building Debian package."

    cd "${BUILD_DIR}"
    
    cmake ../
    
    make package

    echo "Finished building Debian package."
    echo "To check the contents of the Debian package run 'dpkg-deb -c *.deb'"
}

usage()
{
    echo ""
    echo "This is the build script for Connman connection manager."
    echo ""
    echo "  -c Clean the build output directory '_build'."
    echo "  -h Print this help text and exit"
    echo ""
    echo "  The package release version can be passed by passing 'RELEASE_VERSION' through the run environment."
}

pwd

while getopts ":ch" options; do
    case "${options}" in
    c)
        if [ -d "${BUILD_DIR}" ] && [ -z "${BUILD_DIR##*_build*}" ]; then
            rm -rf "${BUILD_DIR}"
        fi
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


if [ "${#}" -gt 1 ]; then
    echo "Too many arguments."
    usage
    exit 1
fi

if [ "${#}" -eq 0 ]; then
    build
    create_debian_package
    exit 0
fi

case "${1-}" in
    deb)
        build
        create_debian_package
        ;;
    *)
        echo "Error, unknown build option given"
        usage
        exit 1
        ;;
esac

exit 0
