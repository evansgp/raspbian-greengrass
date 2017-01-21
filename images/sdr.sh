#!/usr/bin/env bash

# Software for headless SDR on an rpi3

set -e
set -u

# enable only ssh key auth for pi@rpi
echo 'pi' | ssh-copy-id pi@rpi
ssh pi@rpi
newpw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
echo "pi:$newpw" | chpasswd
sudo passwd -d pi
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?UsePAM .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo /etc/init.d/ssh restart

# OS upgrade
sudo apt-get update -y
sudo apt-get upgrade -y

# install tools and dependencies
sudo apt-get -y install \
  git build-essential cmake vim \
  libusb-1.0-0-dev pkg-config \
  libpython-dev python-numpy swig \
  i2c-tools

# build code...
mkdir -p ~/git
pushd ~/git

# ... airspy
git clone https://github.com/airspy/host.git
mkdir host/build
pushd host/build
cmake ../ -DINSTALL_UDEV_RULES=ON
make
sudo make install
popd

# ... rtlsdr
git clone https://github.com/keenerd/rtl-sdr.git
mkdir rtl-sdr/build
pushd rtl-sdr/build
cmake ../
make
sudo make install
popd

# ... SoapySDR
git clone https://github.com/pothosware/SoapySDR.git
mkdir SoapySDR/build
pushd SoapySDR/build
cmake ..
make -j4
sudo make install
popd

# ... Soapy Remote
git clone https://github.com/pothosware/SoapyRemote.git
mkdir SoapyRemote/build
pushd SoapyRemote/build
cmake ..
make -j4
sudo make install
popd

# ... SoapyAirspy
git clone https://github.com/pothosware/SoapyAirspy.git
mkdir SoapyAirspy/build
pushd SoapyAirspy/build
cmake ..
make -j4
sudo make install
popd

# ... SoapyRTLSDR
git clone https://github.com/pothosware/SoapyRTLSDR.git
mkdir SoapyRTLSDR/build
pushd SoapyRTLSDR/build
cmake ..
make
sudo make install
popd

# ... WiringPi
git clone git://git.drogon.net/wiringPi
pushd wiringPi
./build
popd

# ... Witty Pi
git clone https://github.com/evansgp/Witty-Pi.git
mkdir ~/wittyPi
pushd ~/wittyPi
ln -s ~/git/Witty-Pi/wittyPi/{wittyPi,daemon,syncTime,runScript}.sh .
chmod +x ~/wittyPi/*.sh
sudo cp /home/pi/git/Witty-Pi/wittyPi/init.sh /etc/init.d/wittypi
sudo chmod +x /etc/init.d/wittypi
sudo update-rc.d wittypi defaults
cd ~
sudo sh ~/git/Witty-Pi/installWittyPi.sh
popd

# ... done

# One of these deps insisted it needed a reboot...
echo "Rebooting now..."
sudo reboot
