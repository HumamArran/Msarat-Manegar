#!/bin/bash
docker start radius-manager 
docker exec radius-manager mysqld_safe --user=mysql &
docker exec radius-manager cron
docker exec radius-manager service apache2 restart 
docker exec radius-manager radiusd
docker exec radius-manager ./monitor_nas.sh &
