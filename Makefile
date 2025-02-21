
up: create-cluster \
	create-kube-prometheus-stack \
	create-kube-apiserver-audit-exporter \
	create-kwok \
	create-ingress

down: delete-cluster

create-kube-prometheus-stack:
	kubectl create -k ./base/kube-prometheus-stack
	kubectl create -k ./base/kube-prometheus-stack/prometheus
	kubectl create -k ./base/kube-prometheus-stack/alertmanager

create-kube-apiserver-audit-exporter:
	kubectl create -k ./base/kube-apiserver-audit-exporter

create-kwok:
	kubectl create -f ./base/kwok/kwok.yaml
	kubectl create -f ./base/kwok/stage-fast.yaml

create-ingress:
	kubectl create -k ./base/ingress
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=90s

	kubectl apply -f ./base/routes

create-cluster:
	kind create cluster --config ./kind.yaml

delete-cluster:
	kind delete cluster

create-coscheduling:
	kubectl create -k ./schedulers/coscheduling

delete-coscheduling:
	kubectl delete -k ./schedulers/coscheduling

create-kueue:
	kubectl create -k ./schedulers/kueue

delete-kueue:
	kubectl delete -k ./schedulers/kueue

create-volcano:
	kubectl create -k ./schedulers/volcano

delete-volcano:
	kubectl delete -k ./schedulers/volcano

create-yunikorn:
	kubectl create -k ./schedulers/yunikorn

delete-yunikorn:
	kubectl delete -k ./schedulers/yunikorn
