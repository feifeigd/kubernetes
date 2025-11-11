


# 切换到管理员
```shell
kubectl config use-context kubernetes-admin@kubernetes
```

# 重启 Deployment 中所有的 pod
```shell
kubectl rollout restart deployment/coredns -n kube-system
```
