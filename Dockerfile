# ─────────────────────────────────────────────────────────────────────────────
# Stage 1: cross-compile all mjpg-streamer targets for arm64 on a Debian
# bookworm host and package them into a .deb via CPack.
# ─────────────────────────────────────────────────────────────────────────────
FROM debian:bookworm AS builder

# Add arm64 multiarch so we can install arm64 dev packages alongside amd64 host
# tools in the same container.
RUN dpkg --add-architecture arm64 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        pkg-config \
        # arm64 cross-compiler (C + C++) + C runtime headers
        gcc-aarch64-linux-gnu \
        g++-aarch64-linux-gnu \
        libc6-dev-arm64-cross \
        # arm64 runtime + dev libs
        libwebp-dev:arm64 \
        libjpeg62-turbo-dev:arm64 \
        libv4l-dev:arm64 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

# RELEASE_VERSION is injected by CI (build_for_ultimaker.sh -a build) and
# becomes the CPack package version.  Defaults to 9999.99.99 for local builds.
ARG RELEASE_VERSION=9999.99.99

RUN cmake -B /build \
        -DCMAKE_TOOLCHAIN_FILE=/src/cmake/aarch64-linux-gnu.cmake \
        -DCMAKE_BUILD_TYPE=Release \
        "-DCPACK_PACKAGE_VERSION=${RELEASE_VERSION}" \
 && cmake --build /build -- -j"$(nproc)" \
 && cd /build && cpack -G DEB \
 && mkdir /dist && cp /build/mjpg-streamer_*.deb /dist/

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2: export – scratch image that holds only the .deb package.
# Extract with:
#   docker build --output type=local,dest=./dist .
# or see docker-build.sh for a one-liner.
# ─────────────────────────────────────────────────────────────────────────────
FROM scratch AS export
COPY --from=builder /dist/ /
