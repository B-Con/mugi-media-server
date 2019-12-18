#!/bin/sh

# Execute the flickrsyncr command to sync local to the cloud.
# * Uses the bin/flickrsyncr installed with pip install flickrsyncr.
# * Don't set --logfile to use stderr, easier integration with docker.
~/.local/bin/flickrsyncr \
	--config_dir /config/mugi-server/flickrsyncr/config \
	--path /media/tea/images/wallpapers/backdrop \
	--album Backdrop --push --sync --checksum --logfile /tmp/flickrsyncr.log --dryrun

