#!/bin/bash
# BASH script to fetch online users list from Mikrotik NAS & compare it with local FR online users
# IF difference found, then kick the missed users from NAS, but if user is NAS local , then skip it
# This way the missing users will re-establishes there session and will be inserted properly in radacct table AGAIN ,
# This is just a workaround only, ITs not a proper solution, It also assumes you have single NAS only
# Created on : 11-JUL-2018
# Syed Jahanzaib / aacable at hotmnail dot com / https://aacable dot wordpress dot com
 
#set -x
# Setting various variables ...
 
# MYSQL related data
SQLID="root"
SQLPASS="SQLROOTPASSWORD"
DB="radius"
TBL_LOG="log"
export MYSQL_PWD=$SQLPASS
FOOTER="Script Ends Here. Thank you
Syed Jahanzaib / aacable at hotmail dot com"
# MIKROTIK related Data

MT_USER="admin"
MT_IP="10.10.0.1"
MT_PORT="10022"
MT_SECRET="RADIUS_INCOMING_SECRET"
MT_COA_PORT=$MT_COA_PORT
 
# SSH commands for Mikrotik & Freeradius
MT_SSH_CMD="ssh $MT_USER@$MT_IP -p $MT_PORT"
FR_SSH_CMD="mysql -uroot --skip-column-names -s -e"
 
# Temporary holder for various data
MT_ACTIVE_USERS_LIST="/tmp/mt_active_users.txt"
MT_ACTIVE_USERS_NAME_ONLY_LIST="/tmp/mt_active_users_name_only_list.txt"
FR_ACTIVE_USERS_LIST="/tmp/fr_active_users_list.txt"
FR_MISSING_USERS_NAME_LIST="/tmp/fr_active_users_missing_list.txt"
> $MT_ACTIVE_USERS_LIST
> $MT_ACTIVE_USERS_NAME_ONLY_LIST
> $FR_ACTIVE_USERS_LIST
> $FR_MISSING_USERS_NAME_LIST
 
# Execute SSH commands & store data in temporary holders
echo "1- Getting list of Mikrotik Online users via ssh ..."
$MT_SSH_CMD "/ppp active print terse " | sed '/^\s*$/d' > $MT_ACTIVE_USERS_LIST
echo "2- Getting list of Freeradius Online users from 'RADACCT' table ..."
$FR_SSH_CMD "use radius; select username from radacct WHERE acctstoptime IS NULL;" > $FR_ACTIVE_USERS_LIST
 
# Run loop forumla to run CMD for single or multi usernames
echo "3- Running loop formula to fetch usernames only from the mikrotik PPP online users list ..."
num=0
cat $MT_ACTIVE_USERS_LIST | while read users
do
num=$[$num+1]
USERNAME=`echo $users |sed -n -e 's/^.*name=//p' | awk '{print $1}'`
echo "$USERNAME" >> $MT_ACTIVE_USERS_NAME_ONLY_LIST
done
 
# calculate and display Users from Mikrotik Active PPP list vs Freeradius Local Actvive Users List
MT_USERS_COUNT=`cat $MT_ACTIVE_USERS_LIST | wc -l`
FR_USERS_COUNT=`cat $FR_ACTIVE_USERS_LIST | wc -l`
USER_DIFFERENCE=`echo "($MT_USERS_COUNT)-($FR_USERS_COUNT)" |bc`
echo "
Result:
echo MIKROTIK ACTIVE USERS = $MT_USERS_COUNT
echo RADIUS ACTIVE USERS = $FR_USERS_COUNT
echo Freeradius Missing Users = $USER_DIFFERENCE
"
#comm -23 <(sort < $MT_ACTIVE_USERS_NAME_ONLY_LIST) <(sort < $FR_ACTIVE_USERS_LIST)
 
# Make separate list for users that are foung missing in Freeradius online users list
comm -23 <(sort < $MT_ACTIVE_USERS_NAME_ONLY_LIST) <(sort  $FR_MISSING_USERS_NAME_LIST
 
# Check if missing user is NAS local or FR user
echo "4- Running loop formula to check if missing users from FR are NAS local or radius users ...
"
cat $FR_MISSING_USERS_NAME_LIST | while read users
do
num=$[$num+1]
USERNAME=`echo $users | awk '{print $1}'`
REMOTE_OR_LOCAL=`cat $MT_ACTIVE_USERS_LIST |grep $USERNAME |awk '{print $2}'`
if [ "$REMOTE_OR_LOCAL" != "R" ]; then
echo "$USERNAME = This user is ON-LINE in NAS but OFF-LINE in FR radacct table, BUT its NAS local user, so skipping it ..."
else
# IF user is a FR user, then consider his MISSED user & kick him so that he will reconnect & proper entries will be made in radius radacct table
echo "$USERNAME = This user is ON-LINE in NAS, but OFF-LINE in FR radacct table, kicking it so it will reconnect & session will be recreated properly **********"
#$MT_SSH_CMD "/ppp active remove [find name=$USERNAME]"
# KICK user via RADCLIENT / zaib
echo user-name=$USERNAME | radclient -x $MT_IP:$MT_COA_PORT disconnect $MT_SECRET
$FR_SSH_CMD "use $DB; INSERT into $TBL_LOG (data, msg) VALUES ('$USERNAME', '$USERNAME - Kicked from NAS dueto missing session in FR');"
fi
done
 
echo "$FOOTER" 