FROM golang:1.9.3-stretch

LABEL version="1.0.0" \
      description="Ozone Project fork of prebid-server"

RUN set -x \
    && apt-get -qq update \
    && apt-get install -qqy apt-utils \
    && apt-get -qq upgrade \
    && apt-get -qq dist-upgrade \
    && apt-get install -qqy \
        git \
        sudo \
        wget \

    # Restore a borne-shell compatible default shell
    && rm /bin/sh \
    && ln -s /bin/bash /bin/sh


##############################################################################
# UTF-8 Locale, timezone
##############################################################################

RUN set -x \
    && apt-get install -qqy locales \
    && locale-gen C.UTF-8 ${UTF8_LOCALE} \
    && dpkg-reconfigure locales \
    && /usr/sbin/update-locale LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8 \
    && export LANG=C.UTF-8 \
    && export LANGUAGE=C.UTF-8 \
    && export LC_ALL=C.UTF-8 \
    && echo $TIMEZONE > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

RUN go get github.com/Masterminds/glide
RUN go get -u github.com/golang/dep/cmd/dep
