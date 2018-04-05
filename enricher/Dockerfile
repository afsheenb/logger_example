
FROM ubuntu:14.04
MAINTAINER Afsheen Bigdeli

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    python-pip python-dev
    
RUN pip install uwsgi flask geoip2
