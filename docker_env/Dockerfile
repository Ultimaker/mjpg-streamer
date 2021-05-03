FROM balenalib/aarch64-debian:buster

LABEL Maintainer="software-embedded@ultimaker.com" \
      Comment="Ultimaker buster build environment"

RUN apt-get update && \
    apt-get install -y \
    apt-utils \
    build-essential \
    cmake \
    libjpeg-dev \
    git \
    && \
    apt-get clean && \
    rm -rf /var/cache/apt/*
