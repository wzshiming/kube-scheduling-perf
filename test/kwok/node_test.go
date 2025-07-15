package kueue_test

import (
	"fmt"
	"sync"
	"testing"

	"github.com/wzshiming/kube-scheduling-perf/test/utils"
)

// func TestNode(t *testing.T) {
// 	builder := utils.NewNodeBuilder()
// 	for i := range 5000 {
// 		err := utils.Resources.Create(t.Context(),
// 			builder.
// 				WithName(fmt.Sprintf("node-%d", i)).
// 				Build(),
// 		)
// 		if err != nil {
// 			t.Fatal(err)
// 		}
// 	}
// }

func TestNode(t *testing.T) {
	wg := sync.WaitGroup{}
	for j := 0; j != 10; j++ {
		wg.Add(1)
		builder := utils.NewNodeBuilder()

		nodeName := fmt.Sprintf("node-%d", j)
		err := utils.Resources.Create(t.Context(),
			builder.
				WithName(nodeName).
				Build(),
		)
		if err != nil {
			t.Fatal(err)
		}

		go func(j int) {
			defer wg.Done()
			builder := utils.NewPodBuilder()
			for i := range 100 {
				err := utils.Resources.Create(t.Context(),
					builder.
						WithName(fmt.Sprintf("pod-%d-%d", j, i)).
						WithNodeName(nodeName).
						Build(),
				)
				if err != nil {
					t.Fatal(err)
				}
			}
		}(j)
	}
	wg.Wait()
}
