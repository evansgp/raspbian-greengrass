#!/usr/bin/env bash

# Put software onto a raspbian imaged rpi

set -e
set -u

host=

for i in "$@"
do
case $i in
    -h=*|--host=*)
    host="${i#*=}"
    shift
esac
done

[ -z "$host" ] && echo "rpi host:" && read host

# enable only ssh key auth for pi@rpi
echo "Default password from ISO is 'raspberry'"
ssh-copy-id "pi@$host"
scp bootstrap.sh pi@$host:/tmp/bootstrap.sh
ssh pi@$host sudo /bin/bash /tmp/bootstrap.sh
