#!/bin/bash

# Install Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

# Patch the dashboard to allow skipping login
# kubectl patch deployment kubernetes-dashboard -n kubernetes-dashboard --type 'json' -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--enable-skip-login"}]'

# Install Metrics Server
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.2/components.yaml

# Patch the metrisc server to work with insecure TLS
# kubectl patch deployment metrics-server -n kube-system --type 'json' -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

# 创建token
kubectl -n kubernetes-dashboard create token kubernetes-dashboard

# Run the Kubectl proxy to allow accessing the dashboard
kubectl proxy
