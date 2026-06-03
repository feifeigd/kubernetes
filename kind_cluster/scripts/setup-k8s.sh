#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="k8s-cluster-demo"

log() {
    echo "[setup-k8s.sh] $*"
}

main() {
    create_cluster
    view_cluster
    # delete_cluster
}

create_cluster() {
    if kind get clusters | grep -q $CLUSTER_NAME; then
        log "集群已存在"
        return
    fi
    log "创建集群"
    kind create cluster --config k8s/kind-config.yaml
    log "集群创建完成"
}

view_cluster() {
    kind get clusters
    log "集群查看完成"
}

delete_cluster() {
    kind delete cluster --name $CLUSTER_NAME
    log "集群删除完成"
}

main "$@"
