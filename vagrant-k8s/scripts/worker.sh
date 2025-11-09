#!/bin/bash

echo "worker.sh"

echo "加入集群"
# 等待主节点生成加入命令
while [ ! -f /vagrant/join-command.sh ]; do
    echo "等待加入命令生成..."
    sleep 10
done

# 执行加入命令
bash /vagrant/join-command.sh -v

echo "节点 `hostname` 已成功加入集群！"

# 如果希望在工作节点中也能使用kubectl，可执行以下命令
config_path="/vagrant/configs"
sudo -i -u vagrant bash << EOF
mkdir -p /home/vagrant/.kube
sudo cp -f $config_path/config /home/vagrant/.kube/
sudo chown 1000:1000 /home/vagrant/.kube/config
EOF
