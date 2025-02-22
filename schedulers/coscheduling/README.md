# Coscheduling

https://scheduler-plugins.sigs.k8s.io/docs/user-guide/installation/

helm template --repo https://scheduler-plugins.sigs.k8s.io coscheduling scheduler-plugins --set plugins.enabled='{Coscheduling}' --set plugins.disabled='{CapacityScheduling,NodeResourceTopologyMatch,NodeResourcesAllocatable,PrioritySort}'> deploy.yaml
