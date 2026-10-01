# Metrics Stack

A non-production, opinionated Prometheus monitoring stack for Kubernetes. Designed for kubeadm clusters, deployed to the `monitoring` namespace (mostly).

You clone a tag of this repository and build your own `kustomization.yaml` on top of it.
Read [DEPLOYING.md](DEPLOYING.md) for the layout, the catalog of paths, the namespaces and
a worked example. The tables below say what each directory contains.

## Stack Components

| Component           | Description                                       | Docs                                                    |
|---------------------|---------------------------------------------------|---------------------------------------------------------|
| Stack               | The root of every stack component below           | [README](manifests/stack/README.md)                     |
| Prometheus Operator | Manages Prometheus instances (official manifests) | [README](manifests/stack/prometheus-operator/README.md) |
| Grafana Operator    | Manages Grafana instances (official manifests)    | [README](manifests/stack/grafana-operator/README.md)    |
| Prometheus          | Metrics collection and storage                    | [README](manifests/stack/prometheus/README.md)          |
| Alertmanager        | Alert routing and management                      | [README](manifests/stack/alertmanager/README.md)        |
| Grafana             | Metrics visualization                             | [README](manifests/stack/grafana/README.md)             |
| Kube State Metrics  | Kubernetes object metrics (hand-made manifests)   | [README](manifests/stack/kube-state-metrics/README.md)  |
| Node Exporter       | Host-level metrics (hand-made manifests)          | [README](manifests/stack/node-exporter/README.md)       |
| Metrics Server      | Basic CPU/memory metrics                          | [README](manifests/stack/metrics-server/README.md)      |
| Overlays            | Day 2 configuration patches                       | [README](manifests/stack/overlays/README.md)            |

## Application Monitoring

| Application               | Description                                      | Docs                                                         |
|---------------------------|--------------------------------------------------|--------------------------------------------------------------|
| argocd                    | ArgoCD monitoring                                | [README](manifests/apps/argocd/README.md)                    |
| cilium                    | Cilium CNI and Hubble monitoring                 | [README](manifests/apps/cilium/README.md)                    |
| cloudnative-pg            | CloudNative-PG operator monitoring               | [README](manifests/apps/cloudnative-pg/README.md)            |
| core                      | Essential cluster rules (nodes, volumes)         | [README](manifests/apps/core/README.md)                      |
| coredns                   | CoreDNS monitoring                               | [README](manifests/apps/coredns/README.md)                   |
| envoy-gateway             | Envoy Gateway control plane and proxy monitoring  | [README](manifests/apps/envoy-gateway/README.md)             |
| etcd                      | etcd monitoring                                  | [README](manifests/apps/etcd/README.md)                      |
| external-secrets          | External Secrets Operator monitoring             | [README](manifests/apps/external-secrets/README.md)          |
| gateway-api               | Gateway API state monitoring                     | [README](manifests/apps/gateway-api/README.md)               |
| infisical                 | Infisical operator monitoring                    | [README](manifests/apps/infisical/README.md)                 |
| karpenter                 | Karpenter autoscaler monitoring                  | [README](manifests/apps/karpenter/README.md)                 |
| keycloak                  | Keycloak monitoring                              | [README](manifests/apps/keycloak/README.md)                  |
| kubernetes                | Kubernetes control plane monitoring              | [README](manifests/apps/kubernetes/README.md)                |
| kured                     | Kured reboot daemon monitoring                   | [README](manifests/apps/kured/README.md)                     |
| loki                      | Loki log aggregation integration                 | [README](manifests/apps/loki/README.md)                      |
| metallb                   | MetalLB load balancer monitoring                 | [README](manifests/apps/metallb/README.md)                   |
| quarkus                   | Quarkus application monitoring                   | [README](manifests/apps/quarkus/README.md)                   |
| x509-certificate-exporter | TLS certificate expiry monitoring                | [README](manifests/apps/x509-certificate-exporter/README.md) |

## Addons

| Addon | Description                        | Docs                                       |
|-------|------------------------------------|--------------------------------------------|
| karma | Multi-Alertmanager alert dashboard | [README](manifests/addons/karma/README.md) |

## Upstream Sources

| Source                    | Link                                                     |
|---------------------------|----------------------------------------------------------|
| Monitoring Mixins         | <https://monitoring.mixins.dev/>                         |
| bdossantos alert rules    | <https://github.com/bdossantos/prometheus-alert-rules>   |
| Awesome Prometheus Alerts | <https://samber.github.io/awesome-prometheus-alerts/>    |
| dotdc Grafana dashboards  | <https://github.com/dotdc/grafana-dashboards-kubernetes> |
| Kustomize                 | <https://github.com/kubernetes-sigs/kustomize>           |
| Stakater Reloader         | <https://github.com/stakater/Reloader>                   |
