Mugi Server
===

About
---
Config for my personal (mostly media) server setup.

This contains the config the server needs to run, from the setup to the service configs.

* `setup.sh` documents the system setup.
* Contents of the repo are assumed to be pulled into `/config/mugi-server`.

The server is named after [Mugi](http://k-on.wikia.com/wiki/Tsumugi_Kotobuki) from K-On!, who is a server of good things.

Usage
---
Run `setup.sh` script as root on a fresh system.

One-line to start:

    cd /tmp && wget https://raw.githubusercontent.com/B-Con/mugi-server/master/setup.sh && sh setup.sh

Manual steps for system rebuild:

* Restore Deluge torrent state into: `/config/mugi-server/deluge/config/state`.
* Restore Plex caches into: `/config/mugi-server/plex/config`.
* Restore/setup flickrsyncr API keys and OAuth into: `/config/mugi-server/plex/config`.

