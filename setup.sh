#!/bin/sh

S_USER=b-con
S_UID=1000
S_GID=1000

# Install necessary pacakges.
apt-get install openssh git sudo cron
apt-get install zfsutils-linux zfsnap
apt-get install vim traceroute tar gunzip
apt-get install nfs-common
apt-get install docker docker-compose

# Create the main user and a group named after them if they do not already
# exist. Add dotfiles and SSH key login.
getent group $S_USER || groupadd -g $S_GID $S_USER
getent passwd $S_USER || useradd -u $S_UID -g $G_UID -G sudo $S_USER
sudo -u $S_USER /bin/sh <<EOF
	cd ~
	git clone https://github.com/B-Con/dotfiles.git
	cd .ssh
	cat id_mugi.pub >> authorized_keys
	chmod 600 authorized_keys
EOF

# Setup the server's config root.
mkdir -p /config/mugi-server
chown root:root /config
chmod 755 /config
chown b-con:b-con /config/mugi-server
chmod 755 /config/mugi-server
cd /config
sudo -u b-con git pull https://github.con/B-Con/mugi-server.git

# Restore ZFS pool "pot", with volume "tea" into /media/tea.
mkdir -p /media/pot
mkdir -p /media/tea
chown b-con:b-con /media/tea
zpool import pot

# Install custom system settings, reload the configs.
# ./etc is a flat collection of /etc-esque files, NOT a skeleton /etc.
install etc/sshd_config /etc/ssh/sshd_config
install etc/exports     /etc/exports
systemctl restart sshd
systemctl restart nfs-server

# Install the crons.
crontab -u $S_USER etc/crontab.b-con
crontab -u root    etc/crontab.root

# Allow manual steps (eg, restoring caches) before starting services.
echo "Everything's installed. Start services...? [y/n]"
read CONT
[ "$CONT" = y ] || exit 0

# Start the services.
docker-compose up deluge
docker-compose up plex

