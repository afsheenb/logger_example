#!/bin/bash

cd /rankscience/$TELENV && ln -sf ../transforms
while true; do
cd /rankscience/$TELENV
sleep 60
PM2_ONLINE=`pm2 status $TELENV | grep online`

sha1_remote="$(git ls-remote origin -h refs/heads/production|cut -f1)"
[ "`git log --pretty=%H ...refs/heads/production^ | head -n 1`" = "`git ls-remote origin -h refs/heads/production |cut -f1`" ] && status="current"|| status="behind"
echo "Current git status of" $TELENV "is" $status

if ! [[ $sha1_remote =~ ^[a-zA-Z0-9] ]]; then
  echo "Couldn't find a valid sha1, value of remote sha1 is " $sha1_remote
  echo "Spoofing status to current now..."
  status="current"
fi

if [ $status = "behind" ] ; then
    cd /rankscience/$TELENV && git fetch origin && git reset --hard origin/production && npm install nodegit && yarn install && yarn build 
    HEAD=`git log --pretty=%H ...refs/heads/production^ | head -n 1`
    /opt/etcd/etcdctl -C http://172.17.0.1:4001  set /current_commit/$TELENV $HEAD
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
    HEAD=`git log --pretty=%H ...refs/heads/production^ | head -n 1`
    /opt/etcd/etcdctl -C http://172.17.0.1:4001  set /current_commit/$TELENV $HEAD
    fi
fi
done


