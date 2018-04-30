FROM ubuntu:14.04
MAINTAINER Phillip Bailey <phillip@bailey.st>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    python-pip python-dev uwsgi-plugin-python

RUN pip install uwsgi flask geoip2 python-geoip-geolite2 referer-parser

