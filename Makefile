export PATH := $(CURDIR)/bin:$(PATH)

TEST_TIMEOUT_SECONDS ?= 3600

RESULT_RECENT_DURATION_SECONDS ?= 300

NODES_SIZE ?= 1

QUEUES_SIZE ?= 1
JOBS_SIZE_PER_QUEUE ?= 1
PODS_SIZE_PER_JOB ?= 1

IMPACTING_QUEUES_SIZE ?= 0
IMPACTING_JOBS_SIZE_PER_QUEUE ?= 1
IMPACTING_PODS_SIZE_PER_JOB ?= 1

CRITICAL_QUEUES_SIZE ?= 0
CRITICAL_JOBS_SIZE_PER_QUEUE ?= 1
CRITICAL_PODS_SIZE_PER_JOB ?= 1

CPU_REQUEST_PER_POD ?= 1
MEMORY_REQUEST_PER_POD ?= 1Gi

CPU_PER_NODE ?= 128
MEMORY_PER_NODE ?= 1024Gi

CPU_PER_QUEUE ?= 10000
MEMORY_PER_QUEUE ?= 10000Gi
CPU_LENDING_LIMIT ?=
MEMORY_LENDING_LIMIT ?=

GANG ?= false
PREEMPTION ?= false

SCHEDULERS ?= kueue volcano yunikorn

LIMIT_CPU ?= 8

IMAGE_PREFIX ?= 
GO_IMAGE ?= $(IMAGE_PREFIX)docker.io/library/golang:1.24
GOPROXY ?= https://proxy.golang.org,direct
GOOS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
GO_IN_DOCKER = docker run --rm --network host \
	-u $(shell id -u):$(shell id -g) \
	-v $(shell pwd):/workspace/ -w /workspace/ \
	-e GOOS=$(GOOS) -e CGO_ENABLED=0 -e GOPATH=/workspace/gopath/ -e GOPROXY=$(GOPROXY) -e GOCACHE=/workspace/.cache $(GO_IMAGE)

TEST_ENVS = \
		NODES_SIZE=$(NODES_SIZE) \
		CPU_PER_NODE=$(CPU_PER_NODE) \
		MEMORY_PER_NODE=$(MEMORY_PER_NODE) \
		QUEUES_SIZE=$(QUEUES_SIZE) \
		JOBS_SIZE_PER_QUEUE=$(JOBS_SIZE_PER_QUEUE) \
		PODS_SIZE_PER_JOB=$(PODS_SIZE_PER_JOB) \
		IMPACTING_QUEUES_SIZE=$(IMPACTING_QUEUES_SIZE) \
		IMPACTING_JOBS_SIZE_PER_QUEUE=$(IMPACTING_JOBS_SIZE_PER_QUEUE) \
		IMPACTING_PODS_SIZE_PER_JOB=$(IMPACTING_PODS_SIZE_PER_JOB) \
		CRITICAL_QUEUES_SIZE=$(CRITICAL_QUEUES_SIZE) \
		CRITICAL_JOBS_SIZE_PER_QUEUE=$(CRITICAL_JOBS_SIZE_PER_QUEUE) \
		CRITICAL_PODS_SIZE_PER_JOB=$(CRITICAL_PODS_SIZE_PER_JOB) \
		CPU_PER_QUEUE=$(CPU_PER_QUEUE) \
		MEMORY_PER_QUEUE=$(MEMORY_PER_QUEUE) \
		CPU_LENDING_LIMIT=$(CPU_LENDING_LIMIT) \
		MEMORY_LENDING_LIMIT=$(MEMORY_LENDING_LIMIT) \
		CPU_REQUEST_PER_POD=$(CPU_REQUEST_PER_POD) \
		MEMORY_REQUEST_PER_POD=$(MEMORY_REQUEST_PER_POD) \
		PREEMPTION=$(PREEMPTION) \
		GANG=$(GANG)

.PHONY: default
default: ensure-directories
	make serial-test \
		RESULT_RECENT_DURATION_SECONDS=250 TEST_TIMEOUT_SECONDS=350 \
		NODES_SIZE=1000 \
		QUEUES_SIZE=1  JOBS_SIZE_PER_QUEUE=10000  PODS_SIZE_PER_JOB=1
	make serial-test \
		RESULT_RECENT_DURATION_SECONDS=100 TEST_TIMEOUT_SECONDS=200 \
		NODES_SIZE=1000 \
		QUEUES_SIZE=1  JOBS_SIZE_PER_QUEUE=500    PODS_SIZE_PER_JOB=20
	make serial-test \
		RESULT_RECENT_DURATION_SECONDS=60 TEST_TIMEOUT_SECONDS=160 \
		NODES_SIZE=1000 \
		QUEUES_SIZE=1  JOBS_SIZE_PER_QUEUE=20     PODS_SIZE_PER_JOB=500
	make serial-test \
		RESULT_RECENT_DURATION_SECONDS=90 TEST_TIMEOUT_SECONDS=190 \
		NODES_SIZE=1000 \
		QUEUES_SIZE=1  JOBS_SIZE_PER_QUEUE=1      PODS_SIZE_PER_JOB=10000

	make serial-test \
		RESULT_RECENT_DURATION_SECONDS=330 TEST_TIMEOUT_SECONDS=430 \
		NODES_SIZE=1000 GANG=true \
		QUEUES_SIZE=1  JOBS_SIZE_PER_QUEUE=10000  PODS_SIZE_PER_JOB=1
	make serial-test \
		RESULT_RECENT_DURATION_SECONDS=210 TEST_TIMEOUT_SECONDS=310 \
		NODES_SIZE=1000 GANG=true \
		QUEUES_SIZE=1  JOBS_SIZE_PER_QUEUE=500    PODS_SIZE_PER_JOB=20
	make serial-test \
		RESULT_RECENT_DURATION_SECONDS=210 TEST_TIMEOUT_SECONDS=310 \
		NODES_SIZE=1000 GANG=true \
		QUEUES_SIZE=1  JOBS_SIZE_PER_QUEUE=20     PODS_SIZE_PER_JOB=500
	make serial-test \
		RESULT_RECENT_DURATION_SECONDS=300 TEST_TIMEOUT_SECONDS=400 \
		NODES_SIZE=1000 GANG=true \
		QUEUES_SIZE=1  JOBS_SIZE_PER_QUEUE=1      PODS_SIZE_PER_JOB=10000

.PHONY: ensure-directories
ensure-directories:
	./hack/ensure-directories.sh

define test-scheduler

.PHONY: prepare-$(1)
prepare-$(1):
	make up-$(1)
	make wait-$(1)
	make test-init-$(1)

.PHONY: start-$(1)
start-$(1):
	make reset-auditlog-$(1)
	make test-batch-job-$(1)

.PHONY: end-$(1)
end-$(1):
	make down-$(1)

.PHONY: up-$(1)
up-$(1):
	make -C ./clusters/$(1) up

.PHONY: down-$(1)
down-$(1):
	-make -C ./clusters/$(1) down

.PHONY: wait-$(1)
wait-$(1):
	make -C ./clusters/$(1) wait

bin/test-$(1): $(shell find ./test/utils ./test/$(1) -type f)
	$(GO_IN_DOCKER) go test -c -o ./bin/test-$(1) ./test/$(1)

.PHONY: test-init-$(1)
test-init-$(1): bin/test-$(1)
	KUBECONFIG=./clusters/$(1)/kubeconfig.yaml ./bin/test-$(1) -test.timeout $(TEST_TIMEOUT_SECONDS)s -test.run '^TestInit' -test.v

.PHONY: test-batch-job-$(1)
test-batch-job-$(1): test-batch-job-$(1)
	KUBECONFIG=./clusters/$(1)/kubeconfig.yaml ./bin/test-$(1) -test.timeout $(TEST_TIMEOUT_SECONDS)s -test.run '^TestBatchJob' -test.v

.PHONY: reset-auditlog-$(1)
reset-auditlog-$(1):
	make -C ./clusters/$(1) reset-auditlog

endef

$(foreach sched,$(SCHEDULERS),$(eval $(call test-scheduler,$(sched))))

bin/kind:
	$(GO_IN_DOCKER) go build -o ./bin/kind sigs.k8s.io/kind

.PHONY: up
up: bin/kind
	echo $(TEST_ENVS)
	make -j \
		$(addprefix up-,$(SCHEDULERS)) \
		up-overview

	make -j \
		$(addprefix bin/test-,$(SCHEDULERS))

	make \
		$(addprefix wait-,$(SCHEDULERS))

	make -j \
		$(addprefix test-init-,$(SCHEDULERS))

	make wait-overview

	sleep 1

	make -j \
		$(addprefix start-,$(SCHEDULERS)) \
		start-overview

.PHONY: down
down:
	-make move-to-result
	make -j \
		$(addprefix end-,$(SCHEDULERS)) \
		end-overview

.PHONY: serial-test
serial-test: ensure-directories bin/kind
	$(foreach sched,$(SCHEDULERS), \
		make prepare-$(sched); \
		make start-$(sched); \
		make end-$(sched); \
	)

	make \
		prepare-overview \
		start-overview \
		save-result \
		end-overview

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

.PHONY: save-result
save-result:
	sleep $(RESULT_RECENT_DURATION_SECONDS)
	RECENT_DURATION="$(RESULT_RECENT_DURATION_SECONDS)second" ./hack/save-result-images.sh
	make down
	mkdir -p ./tmp
	echo $(TEST_ENVS) > ./tmp/envs.txt
	-mv ./output ./tmp/output
	-mv ./logs ./tmp/logs
	mkdir -p ./results
	mv ./tmp ./results/$(shell date +%s)

.PHONY: move-to-result
move-to-result:
	mkdir -p ./tmp
	-mv ./logs ./tmp/logs
	mkdir -p ./results
	mv ./tmp ./results/$(shell date +%s)

.PHONY: delete-registry
delete-registry:
	-docker rm -f kind-registry

.PHONY: cleanup
cleanup:
	-make down \
		delete-registry
	-rm -rf ./logs/
