#!/usr/bin/env bash

# Software for headless SDR on an rpi3

set -e
set -u

# Disable plain password auth
#newpw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
#echo "pi:$newpw" | /usr/sbin/chpasswd
passwd -d pi
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?UsePAM .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
/etc/init.d/ssh restart

# OS upgrade
apt-get update -y
apt-get upgrade -y

# install tools and dependencies
apt-get -y install \
  git build-essential cmake vim \
  libusb-1.0-0-dev pkg-config \
  libpython-dev python-numpy swig \
  i2c-tools

# build code...
mkdir -p ~pi/git
pushd ~pi/git

# ... airspy
git clone https://github.com/airspy/host.git
mkdir host/build
pushd host/build
cmake ../ -DINSTALL_UDEV_RULES=ON
make
make install
popd

# ... rtlsdr
git clone https://github.com/keenerd/rtl-sdr.git
mkdir rtl-sdr/build
pushd rtl-sdr/build
cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON
make
make install
popd

# ... SoapySDR
git clone https://github.com/pothosware/SoapySDR.git
mkdir SoapySDR/build
pushd SoapySDR/build
cmake ..
make -j4
make install
popd

# ... Soapy Remote
git clone https://github.com/pothosware/SoapyRemote.git
mkdir SoapyRemote/build
pushd SoapyRemote/build
cmake ..
make -j4
make install
popd

# ... SoapyAirspy
git clone https://github.com/pothosware/SoapyAirspy.git
mkdir SoapyAirspy/build
pushd SoapyAirspy/build
cmake ..
make -j4
make install
popd

# ... SoapyRTLSDR
git clone https://github.com/pothosware/SoapyRTLSDR.git
mkdir SoapyRTLSDR/build
pushd SoapyRTLSDR/build
cmake ..
make
make install
popd

# ... WiringPi
git clone git://git.drogon.net/wiringPi
pushd wiringPi
./build
popd

# ... Witty Pi
git clone https://github.com/evansgp/Witty-Pi.git
mkdir ~pi/wittyPi
pushd ~pi/wittyPi
ln -s ~pi/git/Witty-Pi/wittyPi/{wittyPi,daemon,syncTime,runScript}.sh .
chmod +x ~pi/wittyPi/*.sh
cp ~pi/git/Witty-Pi/wittyPi/init.sh /etc/init.d/wittypi
chmod +x /etc/init.d/wittypi
update-rc.d wittypi defaults
cd ~pi
sh ~pi/git/Witty-Pi/installWittyPi.sh
popd

# ... done

# One of these deps insisted it needed a reboot...
echo "Rebooting now..."
reboot