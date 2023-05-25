package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"path/filepath"

	"d7kj.com/k8s"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
)

func main() {
	flag.Parse()
	os.Unsetenv("https_proxy")
	fmt.Println(os.Getenv("https_proxy"))
	kubeconfig := filepath.Join(os.Getenv("HOME"), ".kube", "config")

	// /api/v1/namespaces/book/pods/example

	clientset, err := k8s.CreateK8sApiSeverClient("", "", kubeconfig)
	if err != nil {
		fmt.Println(err)
	}
	// pod, err := clientset.CoreV1().
	// 	// namespace=book
	// 	Pods("book").Get(context.Background(), "example", metav1.GetOptions{})
	// fmt.Println(pod, err)
	// 列出所有 nodes/namespace
	// ListNodes(clientset)
	// ListNamespaces(clientset)
	// ListDeployment(clientset)
	ListService(clientset)

}

func ListNodes(client *kubernetes.Clientset) {
	nodes, err := client.CoreV1().Nodes().List(context.Background(), metav1.ListOptions{})
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(nodes)
}

func ListNamespaces(client *kubernetes.Clientset) {
	nodes, err := client.CoreV1().Namespaces().List(context.Background(), metav1.ListOptions{})
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(nodes)
}

func ListDeployment(client *kubernetes.Clientset) {
	ns := "default"
	nodes, err := client.AppsV1().Deployments(ns).List(context.Background(), metav1.ListOptions{})
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(nodes)
}
func ListService(client *kubernetes.Clientset) {
	ns := "default"
	nodes, err := client.CoreV1().Services(ns).List(context.Background(), metav1.ListOptions{})
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(nodes)
}

func CreateDeployment(client *kubernetes.Clientset) {
	// deployment := &apiAppv1.Deployment{}
}
