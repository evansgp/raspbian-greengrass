# raspbian-greengrass

Shell scripts for provisioning an rpi model B 3 with AWS Greengrass.

This is a work in progress. :)

## write-image.sh

Copies a raspbian jessie lite 64 image from the internet, does just enough to get it on a wifi network and writes it's to a device.

`./write-image.sh -d=/dev/sdc -s="=^,,^=" -p="secret" -y`

Use `lsblk` to identify the device.

## provision.sh

Sets up SSH and runs bootstrap.sh on the RPI.

`./provision.sh`

## bootstrap.sh

Installs SDR software on the RPI. Ran by provision.sh.

`ssh pi@rpi sudo /bin/bash /tmp/bootstrap.sh`