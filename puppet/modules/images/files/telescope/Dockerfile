FROM debian:jessie

WORKDIR /rankscience
RUN apt-get -y update && apt-get -y install build-essential python curl git libssl-dev && \
  rm -rf /tmp/* 
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get -y install nodejs 

#Install etcd

RUN mkdir /opt/etcd
RUN export ETCD_VERSION=v0.5.0-alpha.3 \
  && apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
  curl -L  https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz \
  | tar -zxC /opt/etcd --strip-components=1 \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*
ENV PATH /opt/etcd:$PATH


# Install Nodegit

RUN npm install -g nodegit
    
# Install PM2.
RUN npm install pm2 -g
# Install Yarn
RUN npm install yarn -g

EXPOSE 5050

EXPOSE 6060

CMD /bin/bash -c "./pull-transforms.sh > /dev/null 2>&1 & pm2-docker ecosystem.config.js"

