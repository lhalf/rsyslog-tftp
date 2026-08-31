FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive
ENV GOTOOLCHAIN=local
ENV GOCACHE=/tmp/go-build
ENV GOMODCACHE=/tmp/go-mod
ENV GOFLAGS=-buildvcs=false

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        golang-go \
        just \
        netcat-openbsd \
        tar \
    && rm -rf /var/lib/apt/lists/*
