#!/bin/bash

echo "started listening for messages on stdin..."
while IFS= read -r line; do
    echo "$line" | ./usr/bin/tftp-client tftp://imtftp:69/irrelevant &
done
