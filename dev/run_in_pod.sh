#!/usr/bin/env bash

set -eu

container=rsyslog_tftp_dev

# nested podman needs its own non-overlay storage, kept between runs for image caching
storage="${HOME}/.cache/${container}"
mkdir -p "${storage}"

podman kill ${container} > /dev/null 2>&1 || true
podman rm ${container} > /dev/null 2>&1 || true

echo "building container..."
podman build --quiet --isolation=chroot --file dev/Dockerfile --tag ${container} . > /dev/null

# podman in podman, see https://www.redhat.com/en/blog/podman-inside-container
podman run \
    --replace \
    --tty \
    --env FORCE_COLOR=1 \
    --name ${container} \
    --privileged \
    -v "${storage}:/var/lib/containers:Z" \
    -v "$(pwd):$(pwd):Z" \
    ${container} \
    /bin/bash -c "cd \"$(pwd)\" && $1"