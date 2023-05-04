package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"path/filepath"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
)

func main() {
	flag.Parse()
	config, err := rest.InClusterConfig()
	if err != nil {
		// fallback to kubeconfig
		kubeconfig := filepath.Join("/Users/feifeigd", ".kube", "config")
		if envvar := os.Getenv("KUBECONFIG"); len(envvar) > 0 {
			kubeconfig = envvar
		}
		config, err = clientcmd.BuildConfigFromFlags("", kubeconfig)
		if err != nil {
			fmt.Println(os.Getenv("HOME"))
			fmt.Printf("The kubeconfig connot be loaded: %v\n", err)
			os.Exit(1)
		}
	}
	// /api/v1/namespaces/book/pods/example
	clientset, err := kubernetes.NewForConfig(config)
	pod, err := clientset.CoreV1().
		// namespace=book
		Pods("book").Get(context.Background(), "example", metav1.GetOptions{})
	fmt.Println(pod, err)
}
