#!/bin/sh

S_USER=b-con
S_UID=1000
S_GID=1000

#####
# TODO:
# * Configure caddy certs.
#####

# Install core packages.
apt install git sudo cron vim apt-transport-https tar gunzip smartmontools 
apt install traceroute wget curl dnsutils net-tools ntp iptables ufw sshguard

# Enable contrib repo (necessary for ZFS).
echo "Edit /etc/apt/sources.list and add 'contrib'."
read CONT
vim /etc/apt/sources.list
apt update
apt upgrade

# Install server-specific functionality.
# ZFS docs: https://github.com/zfsonlinux/zfs/wiki/Debian
apt install spl-dkms linux-headers-$(uname -r)
apt install nfs-common nfs-kernel-server
apt install zfs-dkms zfsutils-linux zfsnap
apt install openipmi ipmiutil

# Install Docker.
# docker - community edition from docker repos
# jq - json parser (for docker outputs)
# docker-compose - direct pull because there's no package for some insane reason.
echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee -a /etc/apt/sources.list.d/docker.list
apt update
apt install docker-ce jq
curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)
" -o /usr/local/bin/docker-compose

# Create the main user and a group named after them if they do not already
# exist. Add dotfiles and SSH key login. Stomp whatever is already there.
getent group $S_USER || groupadd -g $S_GID $S_USER
getent passwd $S_USER || useradd -u $S_UID -g $G_UID -G sudo $S_USER
sudo -u $S_USER /bin/sh <<EOF
	cd /tmp
	git clone https://github.com/B-Con/dotfiles.git
	cd dotfiles/.ssh
	cat id_mugi.pub >> authorized_keys
	chmod 600 authorized_keys
EOF
rm -rf /home/$S_USER
mv /tmp/dotfiles /home/$S_USER

# Setup the server's config root.
mkdir -p /config/mugi-server
chown root:root /config
chmod 755 /config
chown $S_USER:$S_USER /config/mugi-server
chmod 755 /config/mugi-server
cd /config
sudo -u $S_USER git clone https://github.con/B-Con/mugi-server.git

# Restore ZFS pool "pot", with volume "tea" into /media/tea.
mkdir -p /media/pot
mkdir -p /media/tea
chown $S_USER:$S_USER /media/tea
zpool import pot

# Install custom system settings, reload the configs.
# ./etc is a flat collection of /etc-esque files, NOT a skeleton /etc.
install -m 644 etc/sshd_config         /etc/ssh/sshd_config
install -m 644 etc/exports             /etc/exports
install -m 644 etc/nfs-common          /etc/default/nfs-common
install -m 644 etc/nfs-kernel-server   /etc/default/nfs-kernel-server
install -m 644 etc/modprobe-local.conf /etc/modprobe.d/local.conf
install -m 644 etc/custom-sshserver    /etc/ufw/applications.d/
install -m 644 etc/custom-nfsserver    /etc/ufw/applications.d/

# Enable and start (restart in case any already started) services.
systemctl enable sshd
systemctl restart sshd
systemctl enable nfs-server
systemctl restart nfs-server
systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server
systemctl enable ufw
systemctl restart ufw

# Set up firewall
ufw default allow outgoing
ufw allow https/tcp
ufw limit CustomSSH
ufw allow Deluge
ufw allow Plex
ufw allow NFSDaemon
ufw allow portmapper
# Available but unnecessary(?): NFSKernel,mountd,statd
ufw enable
echo "Add sshguard to ufw in /etc/ufw/before.rules, after the line
  # End required lines 

add the following:

# CUSTOM: sshguard
:sshguard - [0:0]
-A ufw-before-input -p tcp --dport 31416 -j sshguard
# /CUSTOM
"
read CONT
vim /etc/ufw/before.rules

# Install the crons.
crontab -u $S_USER etc/crontab.b-con
crontab -u root    etc/crontab.root

# Allow manual steps (eg, restoring caches) before starting services.
echo "Everything's installed. Start docker services...? [y/n]"
read CONT
[ "$CONT" = y ] || exit 0

# Start the services.
docker-compose up deluge
docker-compose up plex
docker-compose up caddy

