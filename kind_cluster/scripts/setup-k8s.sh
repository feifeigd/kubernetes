#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="k8s-cluster-demo"

log() {
    echo "[setup-k8s.sh] $*"
}

require_cmd() {
    if ! command -v "$1" &> /dev/null; then
        log "$1 未安装"
        exit 1
    fi
}

main() {
    require_cmd docker
    require_cmd kind
    require_cmd kubectl
    
    create_cluster
    view_cluster
    # delete_cluster
    kubectl config use-context kind-${CLUSTER_NAME}

    kubectl get nodes
    log "节点查看完成"

    kubectl get namespaces
    log "命名空间查看完成"

    kubectl get pods
    log "Pod 查看完成"

    kubectl get services
    log "服务查看完成"

    kubectl get deployments
    log "部署查看完成"

    kubectl get statefulsets
    log "状态集查看完成"

    kubectl get jobs
    log "任务查看完成"
    
    kubectl get cronjobs
    log "定时任务查看完成"
}

create_cluster() {
    if kind get clusters | grep -qx "$CLUSTER_NAME"; then
        log "集群已存在"
        return
    fi
    log "创建集群"
    # 使用宿主机的代理, IP 通过 ip addr show docker0 查看
    PROXY_URL="http://172.17.0.1:20171"
    export HTTP_PROXY=$PROXY_URL
    export HTTPS_PROXY=$PROXY_URL
    export NO_PROXY=localhost,127.0.0.1,.svc,.cluster.local,172.17.0.0/16,10.96.0.0/12,10.244.0.0/16
    export http_proxy=$HTTP_PROXY
    export https_proxy=$HTTPS_PROXY
    export no_proxy=$NO_PROXY
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
