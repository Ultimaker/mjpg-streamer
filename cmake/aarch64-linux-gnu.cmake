# CMake toolchain file for aarch64 cross-compilation on a Debian/Ubuntu host.
# Used by the Docker build to produce arm64 binaries from an amd64 builder.
#
# Usage:
#   cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/aarch64-linux-gnu.cmake

set(CMAKE_SYSTEM_NAME      Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_C_COMPILER   aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# Debian multiarch installs arm64 libs under /usr/lib/aarch64-linux-gnu.
# Tell CMake's find_* commands to prefer those paths.
list(APPEND CMAKE_FIND_ROOT_PATH
    /usr/lib/aarch64-linux-gnu
    /usr/include
)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Point pkg-config at the arm64 .pc files so find_package(PkgConfig) +
# pkg_check_modules(WEBP libwebp) resolves arm64 paths correctly.
set(ENV{PKG_CONFIG_PATH}        "/usr/lib/aarch64-linux-gnu/pkgconfig")
set(ENV{PKG_CONFIG_LIBDIR}      "/usr/lib/aarch64-linux-gnu/pkgconfig")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "/")
