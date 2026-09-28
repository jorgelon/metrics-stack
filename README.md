# Metrics Stack

A non-production, opinionated Prometheus monitoring stack for Kubernetes. Designed for kubeadm clusters, deployed to the `monitoring` namespace (mostly).

## How to use

1. Clone a tag of this repository
2. Create a `kustomization.yaml` that loads the stack, desired apps, and addons
3. To route alerts, add one of the [Alertmanager receivers](manifests/stack/alertmanager/README.md), or write your own `AlertmanagerConfig`
4. Expose services (Grafana, Karma, Prometheus) via Ingress or Gateway API
5. Add the required label `app.kubernetes.io/part-of: metrics-stack`

```yaml
resources:
  - ../../releases/edge/addons/karma
  - ../../releases/edge/apps/core
  - ../../releases/edge/apps/coredns
  - ../../releases/edge/apps/coredns/kubeadm
  - ../../releases/edge/apps/kubernetes
  - ../../releases/edge/stack
  - ../../releases/edge/stack/alertmanager/smtp
  - grafana-env.yaml
  - ingress.yaml
patches:
  - path: overlays/prometheus.yaml
  - path: overlays/grafana-datasource-loki.yaml
components:
  - ../../releases/edge/apps/gateway-api
  - ../../releases/edge/stack/grafana/single-pvc
labels:
  - pairs:
      app.kubernetes.io/part-of: metrics-stack
      app.kubernetes.io/managed-by: kustomize
      app.kubernetes.io/instance: MY-CLUSTER
      app.kubernetes.io/version: PUT-THE-TAG-HERE
```

### `resources:` or `components:`

Almost every directory of this release goes in `resources:`. Four go in `components:`,
because each one patches a resource it does not own, and kustomize cannot do that from a
plain kustomization:

| Component | Patches |
|---|---|
| [`apps/gateway-api`](manifests/apps/gateway-api/README.md) | the kube-state-metrics ClusterRole and Deployment you deploy |
| [`apps/coredns/eks-auto-mode`](manifests/apps/coredns/eks-auto-mode/README.md) | the node-exporter DaemonSet of `stack` |
| [`stack/prometheus/single-pvc`](manifests/stack/prometheus/single-pvc/README.md) | the Prometheus instance of `stack` |
| [`stack/grafana/single-pvc`](manifests/stack/grafana/single-pvc/README.md) | the Grafana instance of `stack` |

List one of these under `resources:` and the build fails, for example with `no resource
matches strategic merge patch "Deployment.v1.apps/kube-state-metrics.monitoring"`.

An optional directory is not a component. You opt in by adding its path to `resources:`.

> **Do not set `namespace:` in your root kustomization.yaml.** Each directory fixes its own namespace internally. Some deploy resources outside `monitoring`, so a root namespace override breaks them. See the [Namespaces](#namespaces) section below.

## Namespaces

Most resources are deployed to the `monitoring` namespace, as declared in each component's own `kustomization.yaml`. Do not override this at the root level.

The following component deploys resources in **additional** namespaces:

| Component                                                  | Resource                    | Namespace     | Reason                                                              |
|------------------------------------------------------------|-----------------------------|---------------|---------------------------------------------------------------------|
| [metrics-server](manifests/stack/metrics-server/README.md) | all resources               | `kube-system` | Official upstream manifest. Metrics Server must run in kube-system |
| [etcd](manifests/apps/etcd/README.md)                      | `k8s-svc-etcd-metrics.yaml` | `kube-system` | Headless Service that selects etcd pods, which run in kube-system   |

## Stack Components

| Component           | Description                                       | Docs                                                    |
|---------------------|---------------------------------------------------|---------------------------------------------------------|
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
| blackbox-exporter         | HTTP endpoint monitoring                         | [README](manifests/apps/blackbox-exporter/README.md)         |
| cilium                    | Cilium CNI and Hubble monitoring                 | [README](manifests/apps/cilium/README.md)                    |
| cloudnative-pg            | CloudNative-PG operator monitoring               | [README](manifests/apps/cloudnative-pg/README.md)            |
| core                      | Essential cluster rules (nodes, volumes)         | [README](manifests/apps/core/README.md)                      |
| coredns                   | CoreDNS monitoring                               | [README](manifests/apps/coredns/README.md)                   |
| envoy-gateway             | Envoy Gateway control plane and proxy monitoring  | [README](manifests/apps/envoy-gateway/README.md)             |
| etcd                      | etcd monitoring                                  | [README](manifests/apps/etcd/README.md)                      |
| external-secrets          | External Secrets Operator monitoring             | [README](manifests/apps/external-secrets/README.md)          |
| gateway-api               | Gateway API state monitoring                     | [README](manifests/apps/gateway-api/README.md)               |
| infisical                 | Infisical operator monitoring                    | [README](manifests/apps/infisical/README.md)                 |
| jetstream                 | NATS JetStream monitoring                        | [README](manifests/apps/jetstream/README.md)                 |
| karpenter                 | Karpenter autoscaler monitoring                  | [README](manifests/apps/karpenter/README.md)                 |
| keycloak                  | Keycloak monitoring                              | [README](manifests/apps/keycloak/README.md)                  |
| kubernetes                | Kubernetes control plane monitoring              | [README](manifests/apps/kubernetes/README.md)                |
| kured                     | Kured reboot daemon monitoring                   | [README](manifests/apps/kured/README.md)                     |
| loki                      | Loki log aggregation integration                 | [README](manifests/apps/loki/README.md)                      |
| metallb                   | MetalLB load balancer monitoring                 | [README](manifests/apps/metallb/README.md)                   |
| quarkus                   | Quarkus application monitoring                   | [README](manifests/apps/quarkus/README.md)                   |
| x509-certificate-exporter | TLS certificate expiry monitoring                | [README](manifests/apps/x509-certificate-exporter/README.md) |
| trivy-operator            | Trivy Operator vulnerability scanning monitoring | [README](manifests/apps/trivy-operator/README.md)            |

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
