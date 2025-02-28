package kwok_test

import (
	"sync"
	"testing"

	"github.com/wzshiming/kube-scheduling-perf/test/utils"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/util/flowcontrol"
)

func TestNodes(t *testing.T) {
	restConfig := cfg.Client().RESTConfig()
	restConfig.RateLimiter = flowcontrol.NewFakeAlwaysRateLimiter()

	cs, err := kubernetes.NewForConfig(restConfig)
	if err != nil {
		t.Fatal(err)
	}

	wg := sync.WaitGroup{}
	for range 10 {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for i := range 10000 {
				t.Log("create node", i)
				_, err = cs.CoreV1().Nodes().Create(t.Context(), utils.Nodes(), metav1.CreateOptions{})
				if err != nil {
					t.Error(err)
				}
			}
		}()
	}
	wg.Wait()
}
