package utils

import (
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"sigs.k8s.io/e2e-framework/pkg/envconf"
)

type option struct {
	name      string
	fastReady bool
}

type Option func(opt *option)

func WithName(name string) Option {
	return func(opt *option) {
		opt.name = name
	}
}

func WithFastReady() Option {
	return func(opt *option) {
		opt.fastReady = true
	}
}

func Name(name string) Option {
	return func(opt *option) {
		opt.name = name
	}
}

func Nodes(opts ...Option) *corev1.Node {
	var o option
	for _, opt := range opts {
		opt(&o)
	}
	if o.name == "" {
		o.name = envconf.RandomName("kwok-node", 16)
	}
	n := &corev1.Node{
		ObjectMeta: metav1.ObjectMeta{
			Name: o.name,
			Annotations: map[string]string{
				"node.alpha.kubernetes.io/ttl": "0",
				"kwok.x-k8s.io/node":           "fake",
			},
			Labels: map[string]string{
				"beta.kubernetes.io/arch":       "amd64",
				"beta.kubernetes.io/os":         "linux",
				"kubernetes.io/arch":            "amd64",
				"kubernetes.io/hostname":        o.name,
				"kubernetes.io/os":              "linux",
				"kubernetes.io/role":            "agent",
				"node-role.kubernetes.io/agent": "",
				"type":                          "kwok",
			},
		},
		Spec: corev1.NodeSpec{
			Taints: []corev1.Taint{
				{
					Key:    "kwok.x-k8s.io/node",
					Value:  "fake",
					Effect: corev1.TaintEffectNoSchedule,
				},
			},
		},
	}

	if o.fastReady {
		n.Status = corev1.NodeStatus{
			Allocatable: corev1.ResourceList{
				"cpu":    resource.MustParse("32"),
				"memory": resource.MustParse("256Gi"),
				"pods":   resource.MustParse("110"),
			},
			Capacity: corev1.ResourceList{
				"cpu":    resource.MustParse("32"),
				"memory": resource.MustParse("256Gi"),
				"pods":   resource.MustParse("110"),
			},
			Conditions: []corev1.NodeCondition{
				// Make sure the node is ready immediately.
				{
					Type:               corev1.NodeReady,
					Status:             corev1.ConditionTrue,
					Reason:             "KubeletReady",
					Message:            "kubelet is posting ready status",
					LastHeartbeatTime:  metav1.Now(),
					LastTransitionTime: metav1.Now(),
				},
			},
			Phase: corev1.NodeRunning,
		}
	}

	return n
}
