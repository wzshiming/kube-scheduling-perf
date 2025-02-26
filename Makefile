
up: \
	create-registry \
	create-cluster \
	create-kube-prometheus-stack \
	create-kube-apiserver-audit-exporter \
	create-kwok \
	create-ingress

down: \
	delete-cluster \
	delete-registry \
	cleanup

create-kube-prometheus-stack:
	kubectl create -k ./base/kube-prometheus-stack/crd
	kubectl create -k ./base/kube-prometheus-stack

create-kube-apiserver-audit-exporter:
	kubectl create -k ./base/kube-apiserver-audit-exporter

create-kwok:
	kubectl create -k ./base/kwok/crd
	kubectl create -k ./base/kwok

create-ingress:
	kubectl create -k ./base/ingress
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=180s
	sleep 1
	kubectl apply -k ./base/routes

create-cluster:
	./hack/kind-with-local-registry.sh 

delete-cluster:
	kind delete cluster

create-registry:
	./hack/local-registry-with-load-images.sh

delete-registry:
	docker kill kind-registry
	docker rm kind-registry

create-coscheduling:
	kubectl create -k ./schedulers/coscheduling

delete-coscheduling:
	kubectl delete -k ./schedulers/coscheduling

create-kueue:
	kubectl create -k ./schedulers/kueue
	kubectl wait --namespace kueue-system \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=180s

delete-kueue:
	kubectl delete -k ./schedulers/kueue

test-kueue:
	go test -timeout 300s ./test/kueue -v

create-volcano:
	kubectl create -k ./schedulers/volcano

delete-volcano:
	kubectl delete -k ./schedulers/volcano

test-volcano:
	go test -timeout 300s ./test/volcano -v

create-yunikorn:
	kubectl create -k ./schedulers/yunikorn

delete-yunikorn:
	kubectl delete -k ./schedulers/yunikorn

test-yunikorn:
	go test -timeout 300s ./test/yunikorn -v

cleanup:
	rm -rf ./logs/
