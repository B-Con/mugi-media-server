#!/bin/sh

# Execute the flickrsyncr command to sync local to the cloud.
# * Uses the bin/flickrsyncr installed with pip install flickrsyncr.
# * Don't set --logfile to use stderr, easier integration with docker.
docker-compose -f /home/b-con/mugi-server/docker-compose.yml run --detach flickrsyncr \
	--config_dir /config --path /data/wallpapers/backdrop \
	--album Backdrop --push --sync --checksum --loglevel WARNING --dryrun

