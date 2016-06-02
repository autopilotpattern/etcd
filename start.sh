#!/bin/bash
set -e

help() {
    echo "Start an etcd cluster in Docker containers."
    echo
    echo "Usage:"
    echo "./start.sh [run] => Start an etcd cluster using a bootstrap node. Uses SCALE"
    echo "                    environment variable to set the number of nodes (default 3)."
    echo "./start.sh build => Build the autopilotpattern/etcd container image"
    echo "./start.sh ship  => Ship the container image to the Docker Hub"
}

# prevent noisy warnings about unexpected ETCD_* prefixed env vars
export COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-e}
export SCALE=${SCALE:-3}

run() {
    echo "Using discovery node for bootstrapping ${SCALE}-node cluster."
    docker-compose up -d bootstrap
    local uuid=$(uuidgen)
    local bootstrap=localhost
    if [[ -n ${DOCKER_HOST} ]]; then
        local bootstrap=$(triton ip ${COMPOSE_PROJECT_NAME}_bootstrap_1)
    fi
    curl -sL -X PUT --fail -d value=3 ${bootstrap}:4001/v2/keys/discovery/${uuid}/_config/size
    export DISCOVERY="http://bootstrap:4001/v2/keys/discovery/${uuid}"
    docker-compose up -d etcd
    docker-compose scale etcd=${SCALE}
}

build() {
    docker build -t='autopilotpattern/etcd' .
}

ship() {
    docker push autopilotpattern/etcd
}

until
    cmd=$1
    if [ ! -z "$cmd" ]; then
        shift 1
        $cmd "$@"
        if [ $? == 127 ]; then
            help
        fi
        exit
    fi
do
    echo
done

run # default
