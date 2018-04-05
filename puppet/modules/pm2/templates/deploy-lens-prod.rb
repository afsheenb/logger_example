#!/bin/bash

while true; do
cd /rankscience/$TELENV
sleep 20

LENS_GALILEO_HOST=<%= @ipaddress_ens3 %>

sha1_remote="$(git ls-remote origin -h refs/heads/production|cut -f1)"
[ "`git log --pretty=%H ...refs/heads/production^ | head -n 1`" = "`git ls-remote origin -h refs/heads/production|cut -f1`" ] && status="current"|| status="behind"
echo "Current git status of" $TELENV "is" $status

if ! [[ $sha1_remote =~ ^[a-zA-Z0-9] ]]; then
  echo "Couldn't find a valid sha1, value of remote sha1 is " $sha1_remote
  echo "Spoofing status to current now..."
  status="current"
fi

if [ $status = "behind" ] ; then
    cd /rankscience/$TELENV && git fetch origin && git reset --hard origin/production
    /opt/etcd/etcdctl -C http://172.17.0.1:4001 rm /services/$TELENV
    HEAD=`git log --pretty=%H ...refs/heads/production^ | head -n 1`
    /opt/etcd/etcdctl -C http://172.17.0.1:4001  set /current_commit/$TELENV $HEAD
    echo "Git was behind and has been updated; deregistering from etcd as part of zero-downtime deployment"
    sleep 20
    echo "Going away now..."
    kill -9 `cat /tmp/lein_is_running_$TELENV`
    killall -9 java
    rm /tmp/lein_is_running_$TELENV
elif [ $status = "current" ] ; then
    if [ -f /tmp/lein_is_running_$TELENV ]; then
    echo "Git is up to date and lens should be running, we should be live."
    else
    echo "Git is up to date but lens does not appear to be running, starting up now."
    cd /rankscience/$TELENV && rm target/lens-0.1.0-SNAPSHOT-standalone.jar
    cd /rankscience/$TELENV && lein uberjar && java -jar target/lens-0.1.0-SNAPSHOT-standalone.jar &
    jvpid=$!
    sleep 35
    echo "Lens is starting, registering with etcd now, java PID is" $jvpid
    HEAD=`git log --pretty=%H ...refs/heads/production^ | head -n 1`
    /opt/etcd/etcdctl -C http://172.17.0.1:4001  set /current_commit/$TELENV $HEAD
    /opt/etcd/etcdctl -C http://172.17.0.1:4001 set /services/$TELENV <%= @ipaddress_ens3 %>:$LENS_PORT
    date +%Y%m%d%H%M%S
    echo $jvpid > /tmp/lein_is_running_$TELENV
    fi
fi
done
