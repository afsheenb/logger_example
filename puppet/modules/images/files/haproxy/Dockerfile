FROM alpine:3.5

ENV confd_ver 0.10.0
ENV BACKEND_POLLING_INTERVAL 10

# Install needed packages
RUN apk update && apk --update add ca-certificates \
    libssl1.0 openssl bash coreutils curl pcre  && \
    mkdir -p /etc/haproxy/certs/

# Install HAProxy 1.6
RUN apk --update add --virtual build-dependencies build-base linux-headers pcre-dev openssl-dev && \
  wget https://s3-us-west-2.amazonaws.com/ranksci-bootstrap/haproxy-1.6.0.tar.gz && \
  tar zxvf haproxy-1.6.0.tar.gz && cd haproxy-1.6.0 && \
  make TARGET=linux2628 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_CRYPT_H=1 USE_LIBCRYPT=1 && \
  make install-bin && cd .. && \
  rm -rf haproxy-1.6.0* && \
  apk del build-dependencies

RUN adduser -D haproxy

# Install confd
RUN wget https://github.com/jnummelin/confd/releases/download/v0.11.0/confd_alpine -O /bin/confd && \
	chmod +x /bin/confd

# Expose ports.
EXPOSE 80
