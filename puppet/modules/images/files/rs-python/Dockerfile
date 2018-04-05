FROM debian:jessie

WORKDIR /rankscience
RUN apt-get -y update && apt-get -y install build-essential python python-dev python-pip curl git libssl-dev libffi-dev && \
  rm -rf /tmp/* 

RUN pip install github-webhook slacker boto3 boto

