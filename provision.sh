#!/usr/bin/env bash

# Put software onto a raspbian imaged rpi

set -e
set -u

host=
core_GUID=
gg_platform=arm7l
gg_version=1.3.0
tmp=files

for i in "$@"
do
case $i in
    -h=*|--host=*)
    host="${i#*=}"
    shift
    ;;
    -c=*|--core=*)
    core_GUID="${i#*=}"
    shift
    ;;
esac
done

[ -z "$host" ] && echo "Please provide -h/--host option" && return 1
[ -z "$core_GUID" ] && echo "Please provide -c/--core GUID option" && return 1

[ ! -f $tmp/greengrass-linux-$gg_platform-$gg_version.tar.gz] && echo "Please download GreenGrass to $tmp" && return 1
[ ! -f $tmp/$core_GUID-setup.tar.gz] && echo "Please download core GUID $core_GUID configuration to $tmp" && return 1

# enable only ssh key auth for pi@rpi
echo "Default password from ISO is 'raspberry'"
ssh-copy-id "pi@$host"
scp $tmp/* pi@$host:/tmp
scp bootstrap.sh pi@$host:/tmp/bootstrap.sh
ssh pi@$host sudo /bin/bash /tmp/bootstrap.sh
