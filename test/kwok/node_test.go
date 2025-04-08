package kueue_test

import (
	"fmt"
	"testing"

	"github.com/wzshiming/kube-scheduling-perf/test/utils"
)

func TestNode(t *testing.T) {
	builder := utils.NewNodeBuilder()
	for i := range 10000 {
		err := utils.Resources.Create(t.Context(),
			builder.
				WithName(fmt.Sprintf("node-%d", i)).
				Build(),
		)
		if err != nil {
			t.Fatal(err)
		}
	}
}
