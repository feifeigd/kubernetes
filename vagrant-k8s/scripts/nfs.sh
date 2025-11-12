#!/bin/bash

# 安装 NFS 
```shell
echo "安装 NFS 服务端"
apt-get update
apt-get install -y nfs-kernel-server
# 创建 NFS 共享目录
nfs_share_dir="/srv/nfs/share"
chmod 777 $nfs_share_dir
# 配置 NFS 导出
echo "$nfs_share_dir *(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exportsnfs_share_dir="$nfs_share_dir"
mkdir -p $nfs_share_dir
chown nobody:nogroup $nfs_
# 基本语法：共享目录 客户端IP(选项)
# /srv/nfs/share 192.168.1.0/24(rw,sync,no_subtree_check)
# /srv/nfs/share 10.0.0.0/8(ro,sync,no_subtree_check)
# /srv/nfs/share *(ro,insecure)  # 允许所有客户端只读访问

# 重启 NFS 服务
exportfs -a
systemctl restart nfs-kernel-server
echo "NFS 服务端安装完成"
echo "安装 NFS 客户端"
apt-get install -y nfs-common
echo "NFS 客户端安装完成"
```

