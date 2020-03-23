---
layout: post
title:  "How to properly backup MySQL"
date:   2020-03-22 22:21:55 +0300
image:  mysql.png
tags:   Backup Database Mysql
published: true
---

# Introduction

The goal of this post is to have a reliable way of restoring a MySQL database to any past state within the backup window. For this we'll configure two things:

* Daily SQL dumps of the whole database
* Enable MySQL binary log

# Create Dump script

Create the file `/etc/cron.weekly/mariadb-backup` with `sudo nano /etc/cron.weekly/mariadb-backup` and populate it with:

```
#!/bin/bash
pass=mypass
threads=4
/usr/bin/mysqldump -u root -p$pass -A -R -E --triggers --single-transaction | /usr/bin/xz -T $threads > /var/log/mysql/deawebobak_`/bin/date +%d_%b_%Y_%H_%M_%S`.sql.xz
```
This script creates a full backup of the MySQL installation, and then runs it through **XZ** for compression. Make sure to change `pass` and `threads` to the root MySQL password and the number of available cores respecively.

We also need to set permissions on this file, cron won't run it if they're not properly set, plus we'll be storing a password in plaintext so it's very important to make sure nobody can read it other than root.

```
chmod 0711 /etc/cron.weekly/mariadb-backup   # -rwx--x--x 
```

# Enable MySQL binary log

The MySQL binlog is a record of all the changes done to the database, it includes very useful tools like restoring to a specific point in time, or even to a specific SQL query.

To enable the binlog you must edit `/etc/mysql/my.cnf` and enable (or add):
```
server-id               = 1
log_bin                 = /var/log/mysql/mariadb-bin
log_bin_index           = /var/log/mysql/mariadb-bin.index
expire_logs_days        = 7
max_binlog_size         = 100M
binlog_format = MIXED
```
Preferably set the binlog directory to the same one used by the above script, so that we can backup a single directory.

Now we need to restart mysql:

```
sudo service mysql restart
```

If no errors showed upon restart, you're set! just check periodically that your weekly backups are being made.

# Restoring

We are storing binlogs only 7 days because after that, our mysqldumps should have us covered. So the idea is to restore the latest dump first, then "fine tune" to the exact position using the binary logs. Configure this strategy to your liking, could be mont-week, day-hour or both. 

