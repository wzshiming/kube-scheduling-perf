package utils

import (
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"sigs.k8s.io/e2e-framework/pkg/envconf"
)

type PodBuilder struct {
	pod *corev1.Pod
}

func NewPodBuilder() *PodBuilder {
	name := envconf.RandomName("kwok-pod", 16)
	return &PodBuilder{
		pod: &corev1.Pod{
			ObjectMeta: metav1.ObjectMeta{
				Name:      name,
				Namespace: "default",
				Labels: map[string]string{
					"app": name,
				},
			},
			Spec: corev1.PodSpec{
				Containers: []corev1.Container{
					{
						Name:  "main",
						Image: "busybox",
						Command: []string{
							"sleep",
							"infinity",
						},
					},
				},
				RestartPolicy: corev1.RestartPolicyAlways,
			},
		},
	}
}

func (b *PodBuilder) WithName(name string) *PodBuilder {
	b.pod.Name = name
	b.pod.Labels["app"] = name
	return b
}

func (b *PodBuilder) WithNodeName(nodeName string) *PodBuilder {
	b.pod.Spec.NodeName = nodeName
	return b
}

func (b *PodBuilder) WithLabels(labels map[string]string) *PodBuilder {
	if b.pod.Labels == nil {
		b.pod.Labels = make(map[string]string)
	}
	for k, v := range labels {
		b.pod.Labels[k] = v
	}
	return b
}

func (b *PodBuilder) WithAnnotations(annotations map[string]string) *PodBuilder {
	if b.pod.Annotations == nil {
		b.pod.Annotations = make(map[string]string)
	}
	for k, v := range annotations {
		b.pod.Annotations[k] = v
	}
	return b
}

func (b *PodBuilder) Build() *corev1.Pod {
	return b.pod.DeepCopy()
}
