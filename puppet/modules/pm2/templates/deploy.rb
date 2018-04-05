#!/bin/bash

while true; do
cd /rankscience/$TELENV
sleep 60
PM2_ONLINE=`pm2 status $TELENV | grep online`

[ "`git log --pretty=%H ...refs/heads/master^ | head -n 1`" = "`git ls-remote origin -h refs/heads/master |cut -f1`" ] && status="current"|| status="behind"
echo "Current git status of" $TELENV "is" $status
if [ $status = "behind" ] ; then
    cd /rankscience/$TELENV && git pull origin master && npm install nodegit && yarn install && yarn build 
    if [ -n "$PM2_ONLINE" ]; then
    nohup pm2 reload /rankscience/pm2/$TELENV.config.js
    echo "Git was behind, is now up to date, and PM2 was running - reloading now."
    else
    nohup pm2 start /rankscience/pm2/$TELENV.config.js &
    echo "Git was behind, is now up to date, but PM2 is not running - starting up now."
    fi
elif [ $status = "current" ] ; then
    if [ -n "$PM2_ONLINE" ]; then
    echo "Git is up to date and PM2 is running, we should be live."
    else
    echo "Git is up to date but PM2 is not running, starting now."
    cd /rankscience/$TELENV && nohup pm2 start /rankscience/pm2/$TELENV.config.js &
    fi
fi
done


