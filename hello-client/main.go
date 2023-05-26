package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"path/filepath"

	"d7kj.com/k8s"
	apiAppv1 "k8s.io/api/apps/v1"
	apiCorev1 "k8s.io/api/core/v1"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/intstr"
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
	// ListService(clientset)
	CreateDeployment(clientset)
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

func CreateDeployment(client *kubernetes.Clientset) error {
	var (
		replicas                        int32 = 2
		AutomountServiceAccountTokenYes       = true
	)

	deployment := &apiAppv1.Deployment{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Deployment",
			APIVersion: "apps/v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      "k8s-test-stub",
			Namespace: "testing",
			Labels: map[string]string{
				"app": "k8s-test-app",
			},
			Annotations: map[string]string{
				"creator": "k8s-test-app",
			},
		},
		Spec: apiAppv1.DeploymentSpec{
			Selector: &metav1.LabelSelector{
				MatchLabels: map[string]string{
					"app": "k8s-test-app",
				},
			},
			Replicas: &replicas,
			Template: v1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: map[string]string{
						"app": "k8s-test-app",
					},
				},
				Spec: v1.PodSpec{
					Containers: []apiCorev1.Container{
						{
							Name:  "nginx",
							Image: "nginx:alpine",
						},
					},
					RestartPolicy:                apiCorev1.RestartPolicyAlways,
					DNSPolicy:                    apiCorev1.DNSClusterFirst,
					NodeSelector:                 nil,
					ServiceAccountName:           "",
					AutomountServiceAccountToken: &AutomountServiceAccountTokenYes,
				},
			},
			Strategy: apiAppv1.DeploymentStrategy{
				Type: apiAppv1.RollingUpdateDeploymentStrategyType,
				RollingUpdate: &apiAppv1.RollingUpdateDeployment{
					MaxUnavailable: &intstr.IntOrString{
						Type:   intstr.String,
						IntVal: 0,
						StrVal: "25%",
					},
					MaxSurge: &intstr.IntOrString{
						Type:   intstr.String,
						IntVal: 0,
						StrVal: "25%",
					},
				},
			},
		},
	}

	dp, err := client.AppsV1().Deployments("testing").Create(context.Background(), deployment, metav1.CreateOptions{})
	if err != nil {
		// return err
	}
	fmt.Println(dp)
	fmt.Println(err)
	return err
}
