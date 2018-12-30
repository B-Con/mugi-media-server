#!/bin/sh

S_USER=b-con
S_UID=1000
S_GID=1000

#####
# TODO:
# * Configure caddy certs.
#####

# Install core packages.
apt-get install git sudo cron vim apt-transport-https tar gunzip smartmontools 
apt-get install traceroute wget curl dnsutils ntp

# Enable contrib repo (necessary for ZFS).
echo "Edit /etc/apt/sources.list and add 'contrib'."
read CONT
vim /etc/apt/sources.list
apt-get update

# Install server-specific functionality.
# ZFS docs: https://github.com/zfsonlinux/zfs/wiki/Debian
apt-get install spl-dkms linux-headers-$(uname -r)
apt-get install nfs-common nfs-kernel-server
apt-get install zfs-dkms zfsutils-linux zfsnap

# Install Docker.
# docker - community edition from docker repos
# jq - json parser (for docker outputs)
# docker-compose - direct pull because there's no package for some insane reason.
echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee -a /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install docker-ce jq
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
install etc/sshd_config /etc/ssh/sshd_config
install etc/exports     /etc/exports
systemctl restart sshd
systemctl restart nfs-server
systemctl restart nfs-kernel-server

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

