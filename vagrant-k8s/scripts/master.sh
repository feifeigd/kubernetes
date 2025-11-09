#!/bin/bash

echo "master.sh"

# kubeadm init --apiserver-advertise-address=192.168.33.10
kubeadm init --apiserver-advertise-address=$MASTER_IP \
    --pod-network-cidr=$POD_CIDR \
    --service-cidr=$SERVICE_CIDR \
    --image-repository=registry.aliyuncs.com/google_containers 

# 配置 kubectl 用于普通用户
mkdir -p $HOME/.kube
cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# 配置 root 用户
export KUBECONFIG=/etc/kubernetes/admin.conf
# kubectl get nodes

echo "安装网络插件 (Calico)"
# curl -fsSL https://docs.projectcalico.org/manifests/calico.yaml -o calico.yaml
# kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml 

# echo "安装 Flannel 网络插件"
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# 这是加入集群的命令内容
kubeadm token create --print-join-command > /vagrant/join-command.sh

echo "Kubernetes master 初始化完成！"

# 将主控节点的配置文件备份到别处
config_path="/vagrant/configs"

if [ -d $config_path ]; then
sudo rm -f $config_path/*
else
sudo mkdir -p $config_path
fi

sudo cp -i /etc/kubernetes/admin.conf $config_path/config