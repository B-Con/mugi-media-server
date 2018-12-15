#!/bin/sh

S_USER=b-con
S_UID=1000
S_GID=1000

cd /config/mugi-server

# Install necessary pacakges.
apt-get install ...

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

# Install custom system settings.
# ./etc is a flat collection of /etc-esque files, NOT a skeleton /etc.
install etc/sshd_config /etc/ssh/sshd_config
install etc/exports     /etc/exports

# Restart services to pickup new settings.
systemctl restart sshd
systemctl restart nfs-server

# Install the crons.
crontab -u $S_USER etc/crontab.b-con
crontab -u root    etc/crontab.root

# Start the services.
docker-compose up deluge
docker-compose up plex

