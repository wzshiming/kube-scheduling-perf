package perf_test

import (
	"strings"
	"testing"

	"sigs.k8s.io/e2e-framework/klient/decoder"
	"sigs.k8s.io/e2e-framework/klient/k8s/resources"
)

var volcanoBatchJobYaml string = `
apiVersion: scheduling.volcano.sh/v1beta1
kind: Queue
metadata:
  name: test
  namespace: default
spec:
  weight: 1
  reclaimable: false
  capability:
    cpu: 2
---
apiVersion: batch.volcano.sh/v1alpha1
kind: Job
metadata:
  name: job-1
  namespace: default
spec:
  minAvailable: 1
  schedulerName: volcano
  queue: test
  policies:
  - event: PodEvicted
    action: RestartJob
  tasks:
  - replicas: 3
    name: nginx
    policies:
    - event: TaskCompleted
      action: CompleteJob
    template:
      spec:
        containers:
          - command:
            - sleep
            - 30s
            image: gcr.io/k8s-staging-perf-tests/sleep:v0.1.0
            name: nginx
            resources:
              requests:
                cpu: 1
              limits:
                cpu: 1
        restartPolicy: Never
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

func TestVolcanoBatchJob(t *testing.T) {
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

	err = decoder.DecodeEach(t.Context(), strings.NewReader(volcanoBatchJobYaml), decoder.DeleteHandler(r))

	err = decoder.DecodeEach(t.Context(), strings.NewReader(volcanoBatchJobYaml), decoder.CreateHandler(r))
	if err != nil {
		t.Fatal(err)
	}
}
