#!/usr/bin/env bash

set -eu

container=rsyslog_tftp_dev

podman kill ${container} > /dev/null 2>&1 || true
podman rm ${container} > /dev/null 2>&1 || true

echo "building container..."
podman build --quiet --isolation=chroot --file dev/Dockerfile --tag ${container} . > /dev/null

podman run \
    --replace \
    --tty \
    --env FORCE_COLOR=1 \
    --name ${container} \
    -v "$(pwd):$(pwd):Z" \
    ${container} \
    /bin/bash -c "cd \"$(pwd)\" && $1"