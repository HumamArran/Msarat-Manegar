#!/bin/bash

# Replace placeholders in radiusmanager.cfg files
sed -i "s/RADIUS_USER_PASSWORD/$RADIUS_USER_PASSWORD/g" /home/radiusmanager-4.1.6/etc/radiusmanager.cfg
sed -i "s/CONNTRACK_USER_PASSWORD/$CONNTRACK_USER_PASSWORD/g" /home/radiusmanager-4.1.6/etc/radiusmanager.cfg

# Hash the DMA admin password
chmod +x /home/radiusmanager-4.1.6/sql/radius.sql
DMA_ADMIN_PASSWORD_HASHED=$(echo -n "$DMA_ADMIN_PASSWORD" | md5sum | awk '{print $1}')
sed -i "s/'admin', '[^']*'/'admin', '$DMA_ADMIN_PASSWORD_HASHED'/g" /home/radiusmanager-4.1.6/sql/radius.sql

# Replace placeholders in system_cfg.php files
sed -i "s/RADIUS_USER_PASSWORD/$RADIUS_USER_PASSWORD/g" /home/radiusmanager-4.1.6/www/radiusmanager/config/system_cfg.php
sed -i "s/CONNTRACK_USER_PASSWORD/$CONNTRACK_USER_PASSWORD/g" /home/radiusmanager-4.1.6/www/radiusmanager/config/system_cfg.php
sed -i "s/TELEBOT_USER_PASSWORD/$TELEBOT_USER_PASSWORD/g"/home/radiusmanager-4.1.6/www/radiusmanager/includes/dbconn.php

# Replace placeholders in global radiusmanager.cfg and system_cfg.php files
sed -i "s/RADIUS_USER_PASSWORD/$RADIUS_USER_PASSWORD/g" /etc/radiusmanager.cfg
sed -i "s/CONNTRACK_USER_PASSWORD/$CONNTRACK_USER_PASSWORD/g" /etc/radiusmanager.cfg
sed -i "s/RADIUS_USER_PASSWORD/$RADIUS_USER_PASSWORD/g" /var/www/radiusmanager/config/system_cfg.php
sed -i "s/CONNTRACK_USER_PASSWORD/$CONNTRACK_USER_PASSWORD/g" /var/www/radiusmanager/config/system_cfg.php
sed -i "s/TELEBOT_USER_PASSWORD/$TELEBOT_USER_PASSWORD/g" /var/www/radiusmanager/includes/dbconn.php

# Replace MySQL root password in config.inc.php
sed -i "s/MYSQL_ROOT_PASSWORD/$MYSQL_ROOT_PASSWORD/g" /home/config.inc.php

# Replace placeholders in SQL configuration file
sed -i "s/RADIUS_USER_PASSWORD/$RADIUS_USER_PASSWORD/g" /usr/local/etc/raddb/sql.conf