package kueue_test

import (
	"fmt"
	"os"
	"testing"

	"sigs.k8s.io/e2e-framework/klient/conf"
	"sigs.k8s.io/e2e-framework/klient/k8s/resources"
	"sigs.k8s.io/e2e-framework/pkg/env"
	"sigs.k8s.io/e2e-framework/pkg/envconf"
)

var (
	testenv env.Environment
	cfg     *envconf.Config
	r       *resources.Resources
)

func TestMain(m *testing.M) {
	var err error
	path := conf.ResolveKubeConfigFile()
	cfg = envconf.NewWithKubeConfig(path)
	testenv = env.NewWithConfig(cfg)

	restConfig := cfg.Client().RESTConfig()
	restConfig.RateLimiter = nil
	restConfig.QPS = 1000
	restConfig.Burst = 1000

	r, err = resources.New(restConfig)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	os.Exit(testenv.Run(m))
}
