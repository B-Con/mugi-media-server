Mugi Server
===

About
---
Config for my personal (mostly media) at-home server.

This contains the config the server needs to run, from the host setup to the service configs.

* `setup.sh` documents the system setup.
* Contents of the repo are assumed to be pulled into `/config/mugi-server`.

It's named after [Mugi](http://k-on.wikia.com/wiki/Tsumugi_Kotobuki) from K-On!, a server of good things.

Usage
---
Run `setup.sh` script as root on a fresh system.

One-line to start:

    cd /tmp && wget https://raw.githubusercontent.com/B-Con/mugi-server/master/setup.sh && sh setup.sh

Manual steps for system rebuild:

* Deluge
	* Restore torrent state into: `/config/mugi-server/deluge/config/state`.
	* Use (or add to) user:pwd pairs in `/config/mugi-server/deluge/config/auth`.
* Plex
	* TODO: Restore caches into: `/config/mugi-server/plex/config`.
* flickrsyncr
	* Restore/setup API keys and OAuth into: `/config/mugi-server/flickrsyncr/config`.

