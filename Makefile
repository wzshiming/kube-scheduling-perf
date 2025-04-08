export PATH := $(CURDIR)/bin:$(PATH)

TEST_TIMEOUT_SECONDS ?= 3600

RESULT_RECENT_DURATION_SECONDS ?= 300

IMAGE_PREFIX ?= 
GO_IMAGE ?= $(IMAGE_PREFIX)docker.io/library/golang:1.24
GOPROXY ?= https://proxy.golang.org,direct
GOOS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
GO_IN_DOCKER = docker run --rm --network host \
	-v $(shell pwd):/workspace/ -w /workspace/ \
	-e GOOS=$(GOOS) -e CGO_ENABLED=0 -e GOPATH=/workspace/gopath/ -e GOPROXY=$(GOPROXY) $(GO_IMAGE)

bin/kind:
	$(GO_IN_DOCKER) go build -o ./bin/kind sigs.k8s.io/kind

bin/test-kwok: $(shell find ./test/utils ./test/kwok -type f)
	$(GO_IN_DOCKER) go test -c -o ./bin/test-kwok ./test/kwok

.PHONY: test-kwok
test-kwok: bin/test-kwok
	KUBECONFIG=./clusters/kwok/kubeconfig.yaml ./bin/test-kwok -test.timeout $(TEST_TIMEOUT_SECONDS)s -test.v

.PHONY: up
up: bin/kind
	make -j up-overview up-kwok
	make -j wait-overview wait-kwok
	make start-overview

	make test-kwok

.PHONY: down
down:
	make -j end-overview  down-kwok

.PHONY: up-kwok
up-kwok:
	make -C ./clusters/kwok up

.PHONY: down-kwok
down-kwok:
	make -C ./clusters/kwok down

.PHONY: wait-kwok
wait-kwok:
	make -C ./clusters/kwok wait

.PHONY: up-overview
up-overview:
	make -C ./clusters/overview up

.PHONY: down-overview
down-overview:
	make -C ./clusters/overview down

.PHONY: wait-overview
wait-overview:
	make -C ./clusters/overview wait

.PHONY: prepare-overview
prepare-overview:
	make up-overview
	make wait-overview

.PHONY: start-overview
start-overview:
	make -C ./clusters/overview start-export

.PHONY: end-overview
end-overview:
	make down-overview

.PHONY: delete-registry
delete-registry:
	-docker rm -f kind-registry

.PHONY: cleanup
cleanup:
	-make down \
		delete-registry
	-rm -rf ./logs/
