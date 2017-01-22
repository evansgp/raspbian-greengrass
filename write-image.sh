#!/usr/bin/env bash
#
# Write to USB a headless raspbian jessie lite image that's set up for evansgp's network.

set -e
set -u

device=
url="http://vx2-downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-01-10/2017-01-11-raspbian-jessie-lite.zip"
yes="false"
ssid="=^,,^="
psk=

tmp=/tmp/rasp
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

if [ ! "$device" ] || [ ! "$psk" ] ; then
  echo "Requires -d|--device=* and -p|--psk=* to be specified"
  exit 1
fi

mkdir -p $tmp

if [ -f $download ] ; then
  echo "Using existing image: $(ls -lathr $download)"
else
  echo "Downloading $url to $download"
  mkdir -p $tmp
  echo curl $url > $download
fi

sha1sum $download
curl $url.sha1

unzip -o $download *raspbian-jessie-lite.img -d $tmp
img=$(ls $tmp/*raspbian-jessie-lite.img)

if [ ! -f $img ] ; then
  echo "$img is not a file"
  exit 1
fi

mounts=$(ls $device?* 2>/dev/null) || true
if [ "$mounts" ] ; then
  sudo umount $(ls $device?*)
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

mounts=$(ls $device?* 2>/dev/null)
if [ "$mounts" ] ; then
  sudo umount $(ls $device?*) || true
fi

echo "Done."