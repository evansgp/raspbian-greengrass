#!/usr/bin/env bash

# Write a raspbian image that's set up for a wireless network and ssh.

set -e
set -u

device=
ssid=
psk=
url="https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-12-01/2017-11-29-raspbian-stretch-lite.zip"
yes="false"

tmp=files
download=$tmp/raspbian.zip
boot=$tmp/mnt/boot
root=$tmp/mnt/root

for i in "$@"
do
case $i in
    -d=*|--device=*)
    device="${i#*=}"
    shift
    ;;
    -s=*|--ssid=*)
    ssid="${i#*=}"
    shift
    ;;
    -p=*|--psk=*)
    psk="${i#*=}"
    shift
    ;;
    -u=*|--url=*)
    url="${i#*=}"
    shift
    ;;
    -y|--yes)
    yes=true
    shift
    ;;
esac
done

if [ ! "$device" ] || [ ! "$ssid" ] || [ ! "$psk" ] || [ ! "$url" ] ; then
  echo "Requires --device, --ssid, --psk and --url to be specified"
  exit 1
fi

mkdir -p $tmp

if [ -f $download ] ; then
  echo "Using existing image: $(ls -lathr $download)"
else
  echo "Downloading $url to $download"
  curl $url > $download
fi

sha1sum $download
curl $url.sha1

[ ! -f $tmp/*raspbian*.img ] && echo "Unzipping" && unzip -o $download -d $tmp

img=$(ls $tmp/*raspbian*.img)

if [ ! -f $img ] ; then
  echo "$img is not a file"
  exit 1
fi

command="dd bs=4M if=${img} of=${device}"

if [ "$yes" = "false" ] ; then
  echo "Execute? $command"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) break;;
          No ) exit;;
      esac
  done
fi

sudo $command
sync

mkdir -p $boot $root
sudo mount "$device"1 $boot
sudo mount "$device"2 $root

# Enable SSH on first boot
sudo touch $boot/ssh

# enable WPA
wpa=$(cat <<-EOM

network={
  ssid="$ssid"
  psk="$psk"
}
EOM
)

echo "$wpa" | sudo tee --append $root/etc/wpa_supplicant/wpa_supplicant.conf
sync

sudo umount $root
sudo umount $boot

echo "Done."