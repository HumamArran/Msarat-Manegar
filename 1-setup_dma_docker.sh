#!/bin/bash
#يتشغل مرة وحدة هذا بكل سيرفر
if [ "$(dpkg -l | awk '/cron/ {print }'|wc -l)" -ge 1 ]; then
 echo ''
else
  apt -y install cron
fi

docker volume create dma-mysql-1
docker volume create dma-freeradius-1
echo "Finished setup successfully!" .