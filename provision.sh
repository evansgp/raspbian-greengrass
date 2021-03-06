#!/usr/bin/env bash

# Put software onto a raspbian imaged rpi

set -e
set -u

host=
core_GUID=
gg_platform=armv7l
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

[ -z "$host" ] && echo "Please provide -h/--host option" && exit 1
[ -z "$core_GUID" ] && echo "Please provide -c/--core GUID option" && exit 1

gg_core=greengrass-linux-$gg_platform-$gg_version.tar.gz
gg_config=$core_GUID-setup.tar.gz

[ ! -f $tmp/$gg_core ] && echo "Please download $gg_core to $tmp" && exit 1
[ ! -f $tmp/$gg_config ] && echo "Please download $gg_config  to $tmp" && exit 1

# enable only ssh key auth for pi@rpi
echo "Default password from ISO is 'raspberry'"
ssh-copy-id "pi@$host"
scp $tmp/$gg_core $tmp/$gg_config $tmp/greengrass.sh $tmp/bootstrap.sh pi@$host:/tmp
ssh pi@$host sudo /bin/bash /tmp/bootstrap.sh
