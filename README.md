# raspbian-greengrass

Shell scripts for provisioning an rpi model B 3 with AWS Greengrass.

This is a work in progress. :)

It currently requires you to manually download the Greengrass Core SDK and the core's configuration to `files\`.
 
## write-image.sh

Copies a raspbian jessie lite 64 image from the internet, does just enough to get it on a wifi network and writes it's to a device.

`./write-image.sh -d=/dev/sdc -s="=^,,^=" -p="secret" -y`

Use `lsblk` to identify the device.

## provision.sh

Sets up SSH and runs bootstrap.sh on the RPI.

`./provision.sh -h=<rpi host> -c=<Greengrass Core GUID>`
