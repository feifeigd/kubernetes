# 学习资源
https://kubectl.docs.kubernetes.io/zh/

# k8s 创建或修改对象
```shell
kubectl apply -f .yaml 
kubectl delete -f .yaml 
```

# 应用整个目录的 .yaml
```shell
kubectl apply -f 目录
# 比较
kubectl diff -f 目录
# 删除
kubectl delete -f 目录
```

# 递归应用目录
```shell
kubectl apply -R -f 目录
```
