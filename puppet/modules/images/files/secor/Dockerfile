FROM openjdk:8

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    maven 

RUN mkdir -p /secor_bin/
RUN mkdir -p /mnt/secor/bidresp/message_logs/partition
RUN mkdir -p /mnt/secor/httpreq/message_logs/partition

