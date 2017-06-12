#!/bin/bash
set -e

help() {
    echo "Start an etcd cluster in Docker containers."
    echo
    echo "Usage:"
    echo "./start.sh [run-local] => Start an etcd cluster using a bootstrap node. Uses SCALE"
    echo "                          environment variable to set the number of nodes (default 3)."
    echo "./start.sh run-triton => Start an etcd cluster on Triton."
    echo "./start.sh build => Build the autopilotpattern/etcd container image"
    echo "./start.sh ship  => Ship the container image to the Docker Hub"
}

# prevent noisy warnings about unexpected ETCD_* prefixed env vars
export COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-e}
export SCALE=${SCALE:-3}

run() {
  if [[ $(echo "${DOCKER_CERT_PATH}" | grep "\.triton") ]]; then
    run-triton
  else
    run-local
  fi
}

run-local() {
    export COMPOSE_FILE=$(pwd)/local-compose.yml
    echo "Using discovery node for bootstrapping local ${SCALE}-node cluster."
    docker-compose up -d bootstrap
    local uuid=$(uuidgen)
    local bootstrap=localhost
    curl -sL -X PUT --fail -d value=3 ${bootstrap}:4001/v2/keys/discovery/${uuid}/_config/size
    export DISCOVERY="http://bootstrap:4001/v2/keys/discovery/${uuid}"
    docker-compose up -d etcd
    docker-compose scale etcd=${SCALE}
    sleep 3
    echo "Stopping bootstrap node, no longer required"
    docker stop ${COMPOSE_PROJECT_NAME}_bootstrap_1
    echo "Displaying cluster health"
    docker exec ${COMPOSE_PROJECT_NAME}_etcd_1 /usr/local/bin/etcdctl cluster-health
}

run-triton() {
    echo "Using discovery node for bootstrapping Triton ${SCALE}-node cluster."
    triton-compose up -d bootstrap
    local uuid=$(uuidgen)
    local bootstrap=$(triton ip ${COMPOSE_PROJECT_NAME}_bootstrap_1)
    curl -sL -X PUT --fail -d value=3 http://${bootstrap}:4001/v2/keys/discovery/${uuid}/_config/size
    export DISCOVERY="http://${bootstrap}:4001/v2/keys/discovery/${uuid}"
    triton-compose up -d etcd
    triton-compose scale etcd=${SCALE}
    sleep 3
    triton-docker stop ${COMPOSE_PROJECT_NAME}_bootstrap_1
    local node=$(triton ls -o name | grep -m 1 "^${COMPOSE_PROJECT_NAME}_etcd")
    triton-docker exec ${node} /usr/local/bin/etcdctl cluster-health
}

build() {
    docker pull alpine:3.5
    docker build -t autopilotpattern/etcd .
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

