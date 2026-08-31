FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive
ENV GOTOOLCHAIN=local
ENV GOCACHE=/tmp/go-build
ENV GOMODCACHE=/tmp/go-mod
ENV GOFLAGS=-buildvcs=false
ENV UV_CACHE_DIR=/tmp/uv

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates

# nfpm
RUN echo 'deb [trusted=yes] https://repo.goreleaser.com/apt/ /' > /etc/apt/sources.list.d/goreleaser.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        aardvark-dns \
        git \
        golang-go \
        just \
        netavark \
        netcat-openbsd \
        nftables \
        nfpm \
        podman

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# shrink image by dropping the apt package index
RUN rm -rf /var/lib/apt/lists/*

# the mounted repo is owned by the host user, not root
RUN git config --system --add safe.directory '*'
