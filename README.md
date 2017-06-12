# Autopilot pattern etcd

*[Autopilot Pattern](http://autopilotpattern.io/) implementation of etcd*

[![DockerPulls](https://img.shields.io/docker/pulls/autopilotpattern/etcd.svg)](https://registry.hub.docker.com/u/autopilotpattern/etcd/)
[![DockerStars](https://img.shields.io/docker/stars/autopilotpattern/etcd.svg)](https://registry.hub.docker.com/u/autopilotpattern/etcd/)
[![ImageLayers](https://badge.imagelayers.io/autopilotpattern/etcd:latest.svg)](https://imagelayers.io/?images=autopilotpattern/etcd:latest)
[![Join the chat at https://gitter.im/autopilotpattern/general](https://badges.gitter.im/autopilotpattern/general.svg)](https://gitter.im/autopilotpattern/general)

This repo is a demonstration of [etcd](https://coreos.com/etcd/docs/latest/) designed for self-operation according to the [Autopilot pattern](http://autopilotpattern.io/).

An etcd cluster needs an external source of data for all the nodes to find each other initially. This can be a bootstrap service (another etcd cluster) or an SRV record. Triton CNS does not yet support SRV records, so until it does we're standing up a temporary single-node cluster to bootstrap the cluster. After the cluster is scaled-up we can remove the bootstrap node.


## Getting started

1. [Get a Joyent account](https://my.joyent.com/landing/signup/) and [add your SSH key](https://docs.joyent.com/public-cloud/getting-started).
1. Install the [Docker Toolbox](https://docs.docker.com/installation/mac/) (including `docker` and `docker-compose`) on your laptop or other environment.
1. Install the [Triton Docker CLI](https://github.com/joyent/triton-docker-cli) when utilizing this pattern on Triton as well. This provides both `triton-docker` and `triton-compose`.
1. Install the the [Joyent Triton CLI](https://docs.joyent.com/public-cloud/api-access/cloudapi) (`triton` replaces our old `sdc-*` CLI tools) and set up your Triton profile.

At this point you're ready to start the cluster. A script `./start.sh` has been provided. It detects your deployment options, either Triton or local Docker, and uses Docker Compose to create each node. An initial bootstrap node is created along with a discovery token (see the [etcd docs on cluster discovery](https://coreos.com/os/docs/latest/cluster-discovery.html) for details) before the cluster can be scaled up. You can pass an environment variable `SCALE` to the `./start.sh` script to set the cluster size to something other than the default 3 nodes.

### Starting

```sh
$ ./start.sh
Using discovery node for bootstrapping local 3-node cluster.
Starting e_bootstrap_1
{"action":"set","node":{"key":"/discovery/2AF6A60D-5196-4358-AA7B-A706DC74D3BD/_config/size","value":"3","modifiedIndex":24,"createdIndex":24}}
e_bootstrap_1 is up-to-date
Creating e_etcd_3
Creating e_etcd_2
Creating e_etcd_1
Desired container number already achieved
Stopping bootstrap node, no longer required
e_bootstrap_1
Displaying cluster health
member 4ed7a60797acad53 is healthy: got healthy result from http://172.18.0.4:2379
member aef40bf222ea5e2f is healthy: got healthy result from http://172.18.0.3:2379
member c329c4aa339bb6f7 is healthy: got healthy result from http://172.18.0.5:2379
```

```sh
$ docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                                                                       NAMES
8e65eb4e319c        autopilotpattern/etcd   "/usr/local/bin/et..."   12 minutes ago      Up 12 minutes       0.0.0.0:32851->2379/tcp, 0.0.0.0:32850->2380/tcp, 0.0.0.0:32849->4001/tcp   e_etcd_1
ef351973dd19        autopilotpattern/etcd   "/usr/local/bin/et..."   12 minutes ago      Up 12 minutes       0.0.0.0:32848->2379/tcp, 0.0.0.0:32847->2380/tcp, 0.0.0.0:32846->4001/tcp   e_etcd_2
930804bf69fd        autopilotpattern/etcd   "/usr/local/bin/et..."   12 minutes ago      Up 12 minutes       0.0.0.0:32845->2379/tcp, 0.0.0.0:32844->2380/tcp, 0.0.0.0:32843->4001/tcp   e_etcd_3
```


## Stopping

```sh
$ COMPOSE_PROJECT_NAME=e docker-compose -f local-compose.yml stop
Stopping e_etcd_1 ... done
Stopping e_etcd_2 ... done
Stopping e_etcd_3 ... done
```

You can also run the previous example with `COMPOSE_PROJECT_NAME=e triton-compose stop`.
