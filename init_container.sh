#!/bin/bash
#set server timezone to Istanbul
ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime

##add monitor_nas.sh to crontab
#write out current crontab

# crontab -l > monitor_nas
# #echo new cron into cron file
# echo "*/1 * * * * /etc/monitor_nas/monitor_nas.sh" >> monitor_nas
# #install new cron file
# crontab monitor_nas
# rm monitor_nas

cd /home && chmod +x setup_mysql.sh && bash setup_mysql.sh
cd /home && chmod +x setup_mysql_radius.sh && bash setup_mysql_radius.sh
cd /home && unzip radiusmanager-4.1.6.zip
chmod +x populate_passwords.sh && bash populate_passwords.sh
cd radiusmanager-4.1.6 && chmod +x install.sh && chmod +x /home/radiusmanager-4.1.6/install.sh  && ./install.sh
cd /usr/local/bin && chmod +x rmauth && chmod +x rmacnt && chmod +x rmconntrack && chmod +x rmpoller
rm /var/www/index.html
mv /home/index.php /var/www/radiusmanager/
cd /home && chmod +x setup_phpmyadmin.sh && bash setup_phpmyadmin.sh

#update dma admin poassword
DMA_ADMIN_PASSWORD_HASHED=$(echo -n "$DMA_ADMIN_PASSWORD" | md5sum | awk '{print $1}')
mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
USE radius;
UPDATE rm_managers SET password='$DMA_ADMIN_PASSWORD_HASHED' WHERE managername='admin';
EOF
#populate passwords
killall -q radiusd
bash populate_passwords.sh

service apache2 restart
radiusd
chmod +x monitor_nas.sh
./monitor_nas.sh &
