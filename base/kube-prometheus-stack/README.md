# kube-prometheus-stack

https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md

helm template monitoring --skip-tests --create-namespace=true --include-crds -n monitoring prometheus-community/kube-prometheus-stack > deploy.yaml
