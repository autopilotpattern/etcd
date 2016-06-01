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
ENV CONTAINERPILOT_VERSION 2.1.3
RUN export CP_SHA1=d890875701337513d4bb74dd30e63b9927eccefe \
    && curl -Lso /tmp/containerpilot.tar.gz \
         "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz" \
    && echo "${CP_SHA1}  /tmp/containerpilot.tar.gz" | sha1sum -c \
    && tar zxf /tmp/containerpilot.tar.gz -C /usr/local/bin \
    && rm -r /tmp/*

COPY containerpilot.json /etc/
ENV CONTAINERPILOT=file:///etc/containerpilot.json

CMD [\
    "/usr/local/bin/containerpilot",\
    "/usr/local/bin/etcd",\
    "-name","etcd0",\
    "-advertise-client-urls","http://etcd:2379,http://etcd:4001",\
    "-listen-client-urls","http://0.0.0.0:2379,http://0.0.0.0:4001",\
    "-initial-advertise-peer-urls","http://etcd:2380",\
    "-listen-peer-urls","http://0.0.0.0:2380",\
    "-initial-cluster-token","etcd-cluster-1",\
    "-initial-cluster","etcd0=http://etcd:2380",\
    "-initial-cluster-state","new"]
