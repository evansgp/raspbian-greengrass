#!/usr/bin/env bash

# Prepare software on base raspbian

set -e
set -u

locale=en_AU.UTF-8
nodeversion=v8.9.4-linux-armv7l
verisign_root_CA=http://www.symantec.com/content/en/us/enterprise/verisign/roots/VeriSign-Class%203-Public-Primary-Certification-Authority-G5.pem

# locales
sed -i "s/^\# $locale UTF-8$/$locale UTF-8/" /etc/locale.gen
locale-gen $locale
update-locale

# OS upgrade
apt-get install dirmngr
apt-key adv --recv-key --keyserver keyserver.ubuntu.com EEA14886

cat <<- EOF >> /etc/apt/sources.list
deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main 
deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main
EOF

apt-get update -y
apt-get upgrade -y
apt-get autoremove -y

# Disable plain password auth
passwd -d pi
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?UsePAM .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
/etc/init.d/ssh restart

# add system user for greengrass to run under
adduser --system ggc_user
addgroup --system ggc_group

cat <<- EOF >> /etc/sysctl.d/98-rpi.conf
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
EOF

# install tools and dependencies
apt-get -y install \
  sqlite3 \
  rpi-update \
  git \
  oracle-java8-installer

wget https://nodejs.org/dist/v8.9.4/node-$nodeversion.tar.xz -O /tmp/node-$nodeversion.tar.xz
tar -xf /tmp/node-$nodeversion.tar.xz -C /usr/local/share

# update firmware, unsure if this is necessary
rpi-update b81a11258fc911170b40a0b09bbd63c84bc5ad59

# Greengrass
tar -xzvf /tmp/greengrass-linux-*.tar.gz -C /
tar -xzvf /tmp/*-setup.tar.gz -C /greengrass
wget $verisign_root_CA -O /greengrass/certs/root.ca.pem
cp /tmp/greengrass.sh /etc/init.d/greengrass.sh
chmod 755 /etc/init.d/greengrass.sh
update-rc.d greengrass.sh defaults

# echo and reboot
echo 'Done, rebooting.'
reboot
