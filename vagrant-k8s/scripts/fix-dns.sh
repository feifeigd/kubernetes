#!/bin/bash
echo "开始修复 CoreDNS 网络问题..."

# echo "1. 重启 CoreDNS..."
# kubectl delete pods -n kube-system -l k8s-app=kube-dns

# echo "2. 重启网络插件..."
# # kubectl delete pods -n kube-system -l k8s-app=calico-node 2>/dev/null || \
# kubectl delete pods -n kube-flannel -l app=flannel 2>/dev/null

# echo "3. 等待组件就绪..."
# # sleep 60
# kubectl wait --for=condition=Ready pod -n kube-system -l k8s-app=kube-dns --timeout=120s
# kubectl wait --for=condition=Ready pod -n kube-flannel -l app=flannel --timeout=120s

echo "4. 验证修复..."
kubectl run dns-test --image=busybox --rm -it --restart=Never -- \
  nslookup kubernetes.default.svc.cluster.local

kubectl run dns-test --image=busybox --rm -it --restart=Never -- \
  nslookup google.com

echo "修复完成！"
