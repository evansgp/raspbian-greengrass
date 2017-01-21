#!/usr/bin/env bash

# Put SDR application software onto a naked raspbian-jessie-lite

set -e
set -u

# enable only ssh key auth for pi@rpi
echo "Default password from ISO is 'raspberry'"
ssh-copy-id pi@rpi
scp bootstrap.sh pi@rpi:/tmp/bootstrap.sh
ssh pi@rpi sudo /bin/bash /tmp/bootstrap.sh
