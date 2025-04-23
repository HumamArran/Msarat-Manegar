#!/bin/bash
docker run --name radius-manager --env-file ./passwords.env -v dma-freeradius-1:/usr/local/etc/raddb -v dma-mysql-1:/var/lib/mysql -v /var/www/radiusmanager:/var/www/radiusmanager --mac-address 00:24:81:F7:1D:2F -p 80:80/tcp -p 1812:1812/tcp -p 1812:1812/udp -p 1813:1813/tcp -p 1813:1813/udp -d -it --restart always dma-radius-manager-image
docker exec radius-manager bash init_container.sh

# Path to the script you want to run on reboot
cp -f onreboot_dma_docker.sh /var/
# Define the paths to the scripts
DOCKER_EXEC="docker exec radius-manager"
# Define the paths to the scripts
SCRIPT_PATH="/var/onreboot_dma_docker.sh"
WLAN_POLLER_PATH="/var/www/radiusmanager/wlanpoller.php"
PHPSESS_CLEANUP_PATH="/var/www/radiusmanager/phpsesscleanup.php"
CMTS_POLLER_PATH="/var/www/radiusmanager/cmtspoller.php"
NEWUSERS_CLEANUP_PATH="/var/www/radiusmanager/newuserscleanup.php"
RM_SCHEDULER_PATH="/var/www/radiusmanager/rmscheduler.php"
TMPIMAGES_CLEANUP_PATH="/var/www/radiusmanager/tmpimages/*"

# Function to check if a script exists and make it executable
check_and_make_executable() {
    local script_path=$1
    if [ ! -f "$script_path" ]; then
        echo "Error: Script $script_path does not exist."
        exit 1
    fi
    chmod +x "$script_path"
}

# Function to check if a cron job exists and add it if it doesn't
add_cron_job_if_not_exists() {
    local cron_job=$1
    if ! crontab -l | grep -Fq "$cron_job"; then
        (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
        echo "Cron job added: $cron_job"
    else
        echo "Cron job already exists: $cron_job"
    fi
}

# Check and make executable for each script
check_and_make_executable "$SCRIPT_PATH"

# Add cron jobs only if they don't already exist
add_cron_job_if_not_exists "@reboot $SCRIPT_PATH"
add_cron_job_if_not_exists "*/5 * * * * $DOCKER_EXEC php $WLAN_POLLER_PATH > /dev/null 2>&1"
add_cron_job_if_not_exists "*/5 * * * * $DOCKER_EXEC  php $PHPSESS_CLEANUP_PATH > /dev/null 2>&1"
add_cron_job_if_not_exists "*/5 * * * * $DOCKER_EXEC php $CMTS_POLLER_PATH > /dev/null 2>&1"
add_cron_job_if_not_exists "* 00 * * * $DOCKER_EXEC php $NEWUSERS_CLEANUP_PATH > /dev/null 2>&1"
add_cron_job_if_not_exists "02 00 * * * $DOCKER_EXEC php $RM_SCHEDULER_PATH"
add_cron_job_if_not_exists "01 00 * * * rm -f $TMPIMAGES_CLEANUP_PATH"
