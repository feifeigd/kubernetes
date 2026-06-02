#!/usr/bin/env bash

# 本地 kubernetes(kind)

# 
# -e: 如果命令执行失败，则退出脚本
# -u: 如果变量未定义，则退出脚本
# -o pipefail: 如果管道中的命令执行失败，则退出脚本
set -euo pipefail

log() {
    echo "[install_kind.sh] $*"
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# log ROOT_DIR=$ROOT_DIR
# 把 ${HOME}/.local/bin 添加到 PATH 中
LOCAL_BIN_DIR="${HOME}/.local/bin"
export PATH="${LOCAL_BIN_DIR}:${PATH}"

if ! grep -q '\.local/bin' "${HOME}/.bashrc"; then
    echo "export PATH=\"${HOME}/.local/bin:${PATH}\"" >> "${HOME}/.bashrc"
    log "添加 ${HOME}/.local/bin 到 PATH 中"
fi

need_cmd() {
    if ! command -v "$1" &> /dev/null; then
        log "$1 未安装"
        return 1
    fi
}

install_cli_tools() {
    log "安装 cli 工具"
    mkdir -p "${LOCAL_BIN_DIR}"
    if ! need_cmd kubectl; then
        log "安装 kubectl"
        K8S_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
        curl -fsSL https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl -o "${LOCAL_BIN_DIR}/kubectl"
        chmod +x "${LOCAL_BIN_DIR}/kubectl"
        log "kubectl 版本: $(kubectl version --client=true)"
    fi

    if ! need_cmd kind; then
        log "安装 kind"
        # https://github.com/kubernetes-sigs/kind
        KIND_VERSION="v0.31.0"
        curl -fsSL https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64 -o "${LOCAL_BIN_DIR}/kind"
        chmod +x "${LOCAL_BIN_DIR}/kind"
        log "kind 版本: $(kind version)"
    fi
    
    log "cli 工具安装完成"
}

install_docker_if_missing() {
    if ! need_cmd docker; then
        log "安装 docker"
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        log "docker 安装完成"
    fi

    if ! groups | grep -q '\bdocker\b'; then
        log "添加当前用户到 docker 组"
        sudo usermod -aG docker "$USER"
        newgrp docker 
        log "请执行: newgrp docker 或重新登录后在运行此脚本"
        exit 1
    fi

    if ! docker info &>/dev/null; then
        if ! docker info 2>&1 | grep -q 'permission denied'; then
            log "无法连接 Docker 守护进程，请确认 docker 服务已启动: sudo systemctl start docker"
        else
            log "当前用户无权访问 Docker，若已在 docker 组，请执行: newgrp docker 或重新登录"
        fi
        exit 1
    fi
}

# 检查 kind 配置
# if ! kind get clusters &> /dev/null; then
#     log "kind 配置不正确"
#     exit 1
# fi

main() {
    install_cli_tools
    install_docker_if_missing
}

main "$@"
