package perf_test

import (
	"strings"
	"testing"

	"sigs.k8s.io/e2e-framework/klient/decoder"
	"sigs.k8s.io/e2e-framework/klient/k8s/resources"
)

var yunikornBatchJobYaml string = `
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: sleep
    applicationId: "application-sleep-0001"
    queue: "root.sandbox"
  name: task0
  namespace: default
spec:
  schedulerName: yunikorn
  restartPolicy: Never
  containers:
    - name: sleep-30s
      image: "alpine:latest"
      command: ["sleep", "30"]
      resources:
        requests:
          cpu: "100m"
          memory: "500M"
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: type
            operator: In
            values:
            - kwok
  tolerations:
  - key: "kwok.x-k8s.io/node"
    operator: "Exists"
    effect: "NoSchedule"
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: sleep
    applicationId: "application-sleep-0002"
    queue: "root.sandbox"
  name: task1
  namespace: default
spec:
  schedulerName: yunikorn
  restartPolicy: Never
  containers:
    - name: sleep-30s
      image: "alpine:latest"
      command: ["sleep", "30"]
      resources:
        requests:
          cpu: "100m"
          memory: "500M"
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: type
            operator: In
            values:
            - kwok
  tolerations:
  - key: "kwok.x-k8s.io/node"
    operator: "Exists"
    effect: "NoSchedule"
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: sleep
    applicationId: "application-sleep-0003"
    queue: "root.sandbox"
  name: task2
  namespace: default
spec:
  schedulerName: yunikorn
  restartPolicy: Never
  containers:
    - name: sleep-30s
      image: "alpine:latest"
      command: ["sleep", "30"]
      resources:
        requests:
          cpu: "100m"
          memory: "500M"
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: type
            operator: In
            values:
            - kwok
  tolerations:
  - key: "kwok.x-k8s.io/node"
    operator: "Exists"
    effect: "NoSchedule"
`

func TestYunikornBatchJob(t *testing.T) {
	cfg := testenv.EnvConf()
	r, err := resources.New(cfg.Client().RESTConfig())
	if err != nil {
		t.Fatal(err)
	}

	for range 10 {
		err := r.Create(t.Context(), Nodes())
		if err != nil {
			t.Fatal(err)
		}
	}

	err = decoder.DecodeEach(t.Context(), strings.NewReader(yunikornBatchJobYaml), decoder.DeleteHandler(r))

	err = decoder.DecodeEach(t.Context(), strings.NewReader(yunikornBatchJobYaml), decoder.CreateHandler(r))
	if err != nil {
		t.Fatal(err)
	}
}
