# we don't want to use quay.io/coreos/etcd because they only ship
# the etcd and etcd-ctl binaries in a scratch container
FROM alpine:3.3

RUN apk update && apk add curl

# get etcd release
# TODO: get gnupg set up to check the sig here
RUN curl -Lso /tmp/etcd.tar.gz https://github.com/coreos/etcd/releases/download/v2.3.6/etcd-v2.3.6-linux-amd64.tar.gz \
    && tar zxf /tmp/etcd.tar.gz -C /tmp \
    && mv /tmp/etcd-v2.3.6-linux-amd64/etcd* /usr/local/bin/

EXPOSE 2379 2380 4001

# get ContainerPilot release
ENV CONTAINERPILOT_VERSION 2.1.4
RUN export CP_SHA1=480056e1667db33839fd647d60ec6da1fc9543d9 \
    && curl -Lso /tmp/containerpilot.tar.gz \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz" \
    && echo "${CP_SHA1}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /usr/local/bin \
    && rm -r /tmp/*

COPY etc/containerpilot.json /etc/
ENV CONTAINERPILOT=file:///etc/containerpilot.json

# TODO: ideally we'd just run etcd directly under ContainerPilot but
# current ContainerPilot doesn't support getting the IP address of the
# container into the forked environment, which we need as part of the
# command line options for etcd.
# Follow https://github.com/joyent/containerpilot/issues/171 for more.
COPY bin/etcd.sh /usr/local/bin/
