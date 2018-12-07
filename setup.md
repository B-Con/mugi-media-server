Server setup
---
* Fetch config
    * `$ git clone https://github.com/B-Con/mugi-server.git`
* Install packages
    * `$ apt-get install zfSnap`
* SSH
	* Setup SSH keys
* ZFS
	* `$ zpool import pot`
	* ZFS daily backup
		`
# zfsnap
#   * hourly, daily, weekly, monthly
#   * "-a" is the TTL
#   * "-d" triggers a TTL cleanse
#   * log to /var/log/zfsnapcron.log
 0  *  *  *  * /usr/sbin/zfSnap -vd -a 24h -p cron-hourly-  pot/tea >> /var/log/zfsnapcron.log
 0  5  *  *  * /usr/sbin/zfSnap -v  -a 7d  -p cron-daily-   pot/tea >> /var/log/zfsnapcron.log
 0  5  *  *  1 /usr/sbin/zfSnap -v  -a 4w  -p cron-weekly-  pot/tea >> /var/log/zfsnapcron.log
 0  5  1  *  * /usr/sbin/zfSnap -v  -a 12m -p cron-monthly- pot/tea >> /var/log/zfsnapcron.log
* NFS
	* TODO: nfs config...?`
* `$ docker-compose build`
* flickrsyncr
	* Create cron entry for the self-contained docker image:
    ` *  6   *   *   *   /home/b-con/mugi-server/flickrsyncr/flickrsyncr-exporter.sh`
