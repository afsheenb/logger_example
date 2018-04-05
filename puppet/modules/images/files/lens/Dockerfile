FROM debian:jessie


RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get -y update


RUN echo "===> install Java and supporting utilities"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive apt-get -y update --fix-missing && apt-get install -y --force-yes supervisor psmisc git wget oracle-java8-installer oracle-java8-set-default


RUN echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk8-installer  && \
    apt-get -y clean  && \
    rm -rf /var/lib/apt/lists/*

ENV LEIN_ROOT true

RUN wget -q -O /usr/bin/lein \
    https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein \
&& chmod +x /usr/bin/lein

WORKDIR /usr/src

RUN mkdir /opt/etcd
RUN export ETCD_VERSION=v0.5.0-alpha.3 \
  && apt-get update && apt-get install -y curl --no-install-recommends ca-certificates && \
  curl -L  https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz \
  | tar -zxC /opt/etcd --strip-components=1 \
  && apt-get remove --purge -y curl \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*
ENV PATH /opt/etcd:$PATH

