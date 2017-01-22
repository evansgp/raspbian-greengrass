
# raspbian-sdr

Shell scripts for creating a portable SDR box on an rpi. Pretty customised to what evansgp needs.

## write-image.sh

Copies a raspbian jessie lite image from the internet, does just enough to get it on evansgp's network and writes it's to USB.

Usage: ./write-image.sh -d=/dev/<device> -p="<psk>" -y

## provision.sh

Sets up SSH and runs bootstrap.sh on the RPI.

Usage: ./provision.sh

## bootstrap.sh

Installs SDR software on the RPI. This bit might be useful to someone else.
