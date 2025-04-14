KIND_CLUSTER_NAME = overview

KIND_CONFIG = ./kind.yaml 

KUBECONFIG = ./kubeconfig.yaml

.PHONY: up
up: \
	create-cluster
	make wait
	-make chmod
	make -j 2 \
		create-ingress \
		create-kube-prometheus-stack
	make create-ingress-routes

.PHONY: start-export
start-export:
	./patch/deployment.patch.yaml.gen.sh > ./patch/deployment.patch.yaml
	KUBECONFIG=$(KUBECONFIG) kubectl kustomize ./patch | ../../hack/local-registry-with-load-images.sh
	KUBECONFIG=$(KUBECONFIG) kubectl create -k ./patch

.PHONY: down
down: \
	delete-cluster

.PHONY: create-kube-prometheus-stack
create-kube-prometheus-stack:
	KUBECONFIG=$(KUBECONFIG) kubectl create -k ../../base/kube-prometheus-stack/crd
	KUBECONFIG=$(KUBECONFIG) kubectl kustomize ../../base/kube-prometheus-stack | ../../hack/local-registry-with-load-images.sh
	sleep 1
	KUBECONFIG=$(KUBECONFIG) kubectl create -k ../../base/kube-prometheus-stack

.PHONY: create-kube-apiserver-audit-exporter
create-kube-apiserver-audit-exporter:
	KUBECONFIG=$(KUBECONFIG) kubectl kustomize ../../base/kube-apiserver-audit-exporter | ../../hack/local-registry-with-load-images.sh
	KUBECONFIG=$(KUBECONFIG) kubectl create -k ../../base/kube-apiserver-audit-exporter

.PHONY: create-ingress
create-ingress:
	KUBECONFIG=$(KUBECONFIG) kubectl kustomize ../../base/ingress | ../../hack/local-registry-with-load-images.sh
	KUBECONFIG=$(KUBECONFIG) kubectl create -k ../../base/ingress

.PHONY: create-ingress-routes
create-ingress-routes: \
	wait
	-for i in $$(seq 1 60); do \
		sleep 1; \
		KUBECONFIG=$(KUBECONFIG) kubectl apply -k ../../base/routes && break; \
	done

.PHONY: create-cluster
create-cluster:
	cat kind.yaml | ../../hack/local-registry-with-load-images.sh
	KUBECONFIG=$(KUBECONFIG) KIND_CONFIG=$(KIND_CONFIG) KIND_CLUSTER_NAME=$(KIND_CLUSTER_NAME) ../../hack/kind-with-local-registry.sh

.PHONY: delete-cluster
delete-cluster:
	-make chmod
	KUBECONFIG=$(KUBECONFIG) KIND_CLUSTER_NAME=$(KIND_CLUSTER_NAME) kind delete cluster
	-rm $(KUBECONFIG)

.PHONE: chmod
chmod:
	docker exec -i $(KIND_CLUSTER_NAME)-control-plane sh -c 'chmod 0666 /var/log/kubernetes/*'

.PHONY: wait
wait:
	-for i in $$(seq 1 60); do \
		KUBECONFIG=$(KUBECONFIG) kubectl wait -A \
			--for=condition=Ready=True pod \
			--all \
			--timeout=10s >/dev/null 2>&1 && break; \
	done
	sleep 1
