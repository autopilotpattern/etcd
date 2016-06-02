#!/bin/sh
set -e

# TODO: ideally we'd just run etcd directly under ContainerPilot but
# current ContainerPilot doesn't support getting the IP address of the
# container into the forked environment, which we need as part of the
# command line options for etcd.
# Follow https://github.com/joyent/containerpilot/issues/171 for more.
# Once that's available we can eliminate this file entirely.

ip=$(ip addr show eth0 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
echo "Setting up listeners on IP $ip"

/usr/local/bin/etcd \
    -name $(hostname) \
    -initial-advertise-peer-urls http://${ip}:2380 \
    -listen-peer-urls http://${ip}:2380 \
    -listen-client-urls http://${ip}:2379,http://127.0.0.1:2379 \
    -advertise-client-urls http://${ip}:2379 \
    -discovery ${DISCOVERY}
