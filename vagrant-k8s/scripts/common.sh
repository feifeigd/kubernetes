#!/bin/bash

set -e

CACHE_PACKAGES_DIR="/vagrant/packages"
# 配置
CONTAINERD_VERSION="2.2.0"
CRICTL_VERSION="1.34.0"

# 代理设置, 宿主机上clashx等代理软件的地址
PROXY_URL="http://10.0.2.2:7890"
NAT_CIDR="10.0.2.0/24"

# private_network
HOST_ONLY_CIDR="192.168.33.0/24"

echo "=== 开始通用系统配置 ==="

echo "设置 HTTP 代理"
cat > /etc/profile.d/proxy.sh << EOF
export http_proxy=$PROXY_URL
export https_proxy=$PROXY_URL
export no_proxy=localhost,127.0.0.1,.cluster.local,10.0.2.15,10.0.2.2,10.0.0.0/8,${NAT_CIDR},${HOST_ONLY_CIDR},${SERVICE_CIDR},${POD_CIDR}
EOF
. /etc/profile.d/proxy.sh

# 加载内核模块
# modprobe overlay # containerd.service 会安装
modprobe br_netfilter

echo "允许 IPv4 数据包转发"
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

echo "apt 源, 使用阿里云源"
sed -ri 's/http:\/\/.*\.ubuntu\.com\/ubuntu\//http:\/\/mirrors\.aliyun\.com\/ubuntu\//g' /etc/apt/sources.list.d/ubuntu.sources
apt-get update #&& apt upgrade -y
apt-get install -y net-tools

cd /tmp

echo "安装 containerd"

# 下载文件，如果已经存在，则替换
mkdir -p /etc/systemd/system/containerd.service.d/
tee /etc/systemd/system/containerd.service.d/http-proxy.conf <<EOF
[Service]
# 代理服务器的地址，自己修改啊
Environment="HTTP_PROXY=$PROXY_URL"
Environment="HTTPS_PROXY=$PROXY_URL"
Environment="NO_PROXY=localhost,127.0.0.1,.cluster.local,10.0.2.15,10.0.2.2,10.0.0.0/8,${NAT_CIDR},${HOST_ONLY_CIDR},${SERVICE_CIDR},${POD_CIDR}"
EOF


# wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz -O $CACHE_PACKAGES_DIR/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
tar Cxzvf /usr/local $CACHE_PACKAGES_DIR/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
mkdir -p /usr/local/lib/systemd/system/
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -O /usr/local/lib/systemd/system/containerd.service

mkdir -p /etc/containerd
echo "生成默认配置 config.toml"
containerd config default | tee /etc/containerd/config.toml
# 修改 containerd 配置使用 systemd cgroup
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

systemctl daemon-reload
# systemctl restart containerd
echo "启动并设置为开机自启 containerd"
systemctl enable --now containerd

# echo "下载 crictl"
# curl -fsSL https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.34.0/crictl-v1.34.0-linux-amd64.tar.gz | sudo tar -C /usr/local/bin -xz
# wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CRICTL_VERSION}/crictl-v${CRICTL_VERSION}-linux-amd64.tar.gz -O $CACHE_PACKAGES_DIR/crictl-v${CRICTL_VERSION}-linux-amd64.tar.gz

echo "安装 crictl"
tar -C /usr/local/bin -xzvf $CACHE_PACKAGES_DIR/crictl-v${CRICTL_VERSION}-linux-amd64.tar.gz

# 配置 crictl
cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF

echo "禁用 swap"
swapoff -a
# 原本已经是注释的行（以 #开头）不会重复添加注释。
sed -ri 's/^[^#].*swap.*/#&/' /etc/fstab 

# 关闭防火墙
ufw disable

echo "安装 kubelet kubeadm kubectl"
apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "安装 runc"
# wget https://github.com/opencontainers/runc/releases/download/v1.3.3/runc.amd64 -O $CACHE_PACKAGES_DIR/runc.amd64
install -m 755 $CACHE_PACKAGES_DIR/runc.amd64 /usr/local/sbin/runc

# echo "安装 CNI 插件"
# wget https://github.com/containernetworking/plugins/releases/download/v1.8.0/cni-plugins-linux-amd64-v1.8.0.tgz -O cni-plugins-linux-amd64-v1.8.0.tgz
# mkdir -p /opt/cni/bin
# tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.8.0.tgz
