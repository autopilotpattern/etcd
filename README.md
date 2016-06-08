# Autopilot pattern etcd

*[Autopilot Pattern](http://autopilotpattern.io/) implementation of etcd*

[![DockerPulls](https://img.shields.io/docker/pulls/autopilotpattern/etcd.svg)](https://registry.hub.docker.com/u/autopilotpattern/etcd/)
[![DockerStars](https://img.shields.io/docker/stars/autopilotpattern/etcd.svg)](https://registry.hub.docker.com/u/autopilotpattern/etcd/)
[![ImageLayers](https://badge.imagelayers.io/autopilotpattern/etcd:latest.svg)](https://imagelayers.io/?images=autopilotpattern/etcd:latest)
[![Join the chat at https://gitter.im/autopilotpattern/general](https://badges.gitter.im/autopilotpattern/general.svg)](https://gitter.im/autopilotpattern/general)

This repo is a demonstration of [etcd](https://coreos.com/etcd/docs/latest/) designed for self-operation according to the [Autopilot pattern](http://autopilotpattern.io/).

An etcd cluster needs an external source of data for all the nodes to find each other initially. This can be a bootstrap service (another etcd cluster) or an SRV record. Triton CNS does not yet support SRV records, so until it does we're standing up a temporary single-node cluster to bootstrap the cluster. After the cluster is scaled-up we can remove the bootstrap node.


### Getting started

1. [Get a Joyent account](https://my.joyent.com/landing/signup/) and [add your SSH key](https://docs.joyent.com/public-cloud/getting-started).
1. Install the [Docker Toolbox](https://docs.docker.com/installation/mac/) (including `docker` and `docker-compose`) on your laptop or other environment.
1. Install the the [Joyent Triton CLI](https://docs.joyent.com/public-cloud/api-access/cloudapi) (`triton` replaces our old `sdc-*` CLI tools) and set up your Triton profile.

At this point you're ready to start the cluster. A script `./start.sh` has been provided. It uses Docker Compose and creates the initial discovery token (see the [etcd docs on cluster discovery](https://coreos.com/os/docs/latest/cluster-discovery.html) for details) before scaling up the cluster. You can pass an environment variable `SCALE` to the `./start.sh` script to set the cluster size to something other than the default 3 nodes.

```
$ ./start.sh
Using discovery node for bootstrapping 3-node cluster.
e_bootstrap_1 is up-to-date
{"action":"set","node":{"key":"/discovery/DD6E6035-9795-49E7-8762-49DDEE8455A9/_config/size","value":"3","modifiedIndex":4,"createdIndex":4}}
e_bootstrap_1 is up-to-date
Creating e_etcd_1
Creating and starting e_etcd_2 ... done
Creating and starting e_etcd_3 ... done
```

```
$ docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED              STATUS              PORTS                                                      NAMES
dd08958fb3e6        autopilotpattern/etcd   "/usr/local/bin/conta"   45 seconds ago       Up 36 seconds       0.0.0.0:2379-2380->2379-2380/tcp, 0.0.0.0:4001->4001/tcp   e_etcd_2
8fa74cc415de        autopilotpattern/etcd   "/usr/local/bin/conta"   57 seconds ago       Up 42 seconds       0.0.0.0:2379-2380->2379-2380/tcp, 0.0.0.0:4001->4001/tcp   e_etcd_3
59b1028eabec        autopilotpattern/etcd   "/usr/local/bin/conta"   About a minute ago   Up About a minute   0.0.0.0:2379-2380->2379-2380/tcp, 0.0.0.0:4001->4001/tcp   e_etcd_1
adf54d657250        autopilotpattern/etcd   "/usr/local/bin/etcd "   3 minutes ago        Up 3 minutes        0.0.0.0:2379-2380->2379-2380/tcp, 0.0.0.0:4001->4001/tcp   e_bootstrap_1
```

And we can now check the cluster health:

```
$ docker exec -it e_etcd_2 /usr/local/bin/etcdctl cluster-health
member 2c2faabfc9a8dee9 is healthy: got healthy result from http://192.168.129.168:2379
member 5d4b828adc525786 is healthy: got healthy result from http://192.168.129.169:2379
member f556ea8cb6e4c0f0 is healthy: got healthy result from http://192.168.129.170:2379
cluster is healthy
```
