package k8s

import (
	"fmt"
	"os"
	"runtime"
	"time"

	"k8s.io/apimachinery/pkg/util/wait"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/cert"
)

// 创建 k8s 客户端
func CreateK8sApiSeverClient(apiServerHost, rootCaFile, kubeConfig string) (client *kubernetes.Clientset, err error) {
	var cfg *rest.Config
	if apiServerHost == "" {
		cfg, err = rest.InClusterConfig()
	}
	if kubeConfig == "" {
		if envvar := os.Getenv("KUBECONFIG"); len(envvar) > 0 {
			kubeConfig = envvar
		}
	}
	if cfg == nil {
		cfg, err = clientcmd.BuildConfigFromFlags(apiServerHost, kubeConfig)
	}
	if err != nil {
		return
	}

	cfg.UserAgent = fmt.Sprintf("K8s-Operator-Agent: %s/%s/%s",
		runtime.GOOS, runtime.GOARCH, runtime.Version(),
	)
	if apiServerHost != "" && rootCaFile != "" {
		tlsClientConfig := rest.TLSClientConfig{}
		if _, err = cert.NewPool(rootCaFile); err != nil {
			return
		}
		tlsClientConfig.CAFile = rootCaFile
		cfg.TLSClientConfig = tlsClientConfig
	}
	if client, err = kubernetes.NewForConfig(cfg); err != nil {
		return
	}

	defaultBackOff := wait.Backoff{
		Duration: 1 * time.Second,
		Factor:   1.5,
		Jitter:   0.1,
		Steps:    10,
	}
	retries := 0 // 重试次数
	var lastErr error
	// var v *discovery.Info
	err = wait.ExponentialBackoff(defaultBackOff, func() (done bool, err error) {
		_, lastErr = client.Discovery().ServerVersion() // 读到api server 版本
		if lastErr == nil {
			return true, nil
		}
		retries++
		return
	})
	if err != nil {
		return nil, lastErr
	}
	if retries > 0 {

	}

	return
}
