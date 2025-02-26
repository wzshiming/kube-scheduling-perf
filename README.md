# kube-scheduling-perf

## Collecting Scheduling Metrics

This project uses the [kube-apiserver-audit-exporter](https://github.com/wzshiming/kube-apiserver-audit-exporter) to collect metrics from the kube-apiserver's audit log, providing a unified view of scheduling performance across different scheduler implementations.

## Prerequisites and Setup

### Dependencies

To use this project, you'll need to have the following tools installed:

- kind
- kubectl
- golang

### Cluster Management

> This project allows for quick deletion and recreation of the cluster, as it uses the kind local registry.  
> This approach also helps control variables during different scheduler tests and does not have to wait for the slow deletion process.  

To create a cluster, run the following command:

`make up`

Once the cluster is up, you can access the performance dashboard at:

`http://127.0.0.1:8080/grafana/d/perf/`

To delete the cluster:

`make down`

## Supported Schedulers

### Kueue

To install Kueue, use the following command:

`make create-kueue`

For testing Kueue, use:

`make test-kueue`

### Additional Schedulers

You can also test other schedulers using the following commands:

- Volcano: `make create-volcano` and `make test-volcano`
- Yunikorn: `make create-yunikorn` and `make test-yunikorn`
