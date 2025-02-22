package yunikorn_test

import (
	_ "embed"
	"strings"
	"testing"

	"github.com/wzshiming/kube-scheduling-perf/test/utils"

	"sigs.k8s.io/e2e-framework/klient/decoder"
)

//go:embed batch_job.yaml
var batchJobYaml string

func TestBatchJob(t *testing.T) {
	t.Log("create nodes")
	for range 10 {
		err := r.Create(t.Context(), utils.Nodes())
		if err != nil {
			t.Fatal(err)
		}
	}

	for i := range 1000 {
		t.Log("create batch job", i)
		err := decoder.DecodeEach(t.Context(), strings.NewReader(batchJobYaml), decoder.CreateHandler(r))
		if err != nil {
			t.Fatal(err)
		}
	}
}
