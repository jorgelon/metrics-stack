# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Kubernetes metrics stack deployment using Kustomize and the Prometheus Operator ecosystem. It's designed for non-production use on kubeadm clusters and deploys monitoring infrastructure to the "monitoring" namespace.

## Core Architecture

The repository is organized into three main sections:

### `/manifests/stack/` - Core Infrastructure
Contains the fundamental monitoring components:
- **Prometheus Operator** (v0.82.0) - Manages Prometheus instances
- **Grafana Operator** (v5.17.1) - Manages Grafana instances  
- **Prometheus** - Main metrics collection and storage
- **Alertmanager** - Alert routing and management
- **Grafana** - Metrics visualization
- **Kube State Metrics** (v2.15.0) - Kubernetes object metrics
- **Node Exporter** - Host-level metrics
- **Metrics Server** (v0.7.2) - Basic CPU/memory metrics

### `/manifests/apps/` - Application Monitoring
Contains monitoring configurations for specific applications:
- **control-plane/** - Kubernetes control plane components (API server, scheduler, kubelet)
- **core/** - Essential cluster monitoring (nodes, pods, volumes, namespaces)
- **workloads/** - Generic workload monitoring (deployments, pods, jobs, etc.)
- **cilium/**, **coredns/**, **karpenter/** - Specific application integrations
- **argocd/**, **cloudnative-pg/**, **keycloak/** - Third-party application monitoring

### `/manifests/addons/` - Optional Components
Additional tools like Karma for alert management.

## Key Deployment Patterns

- **Kustomize-based**: All deployments use kustomization.yaml files for configuration management
- **Operator-driven**: Uses Prometheus and Grafana operators for declarative management
- **Modular**: Each application has its own monitoring configuration in separate directories
- **Version-pinned**: Core components are pinned to specific versions in subdirectories

## Common Commands

### Deploy the complete stack:
```bash
kubectl apply -k manifests/stack/
```

### Deploy specific application monitoring:
```bash
kubectl apply -k manifests/apps/core/
kubectl apply -k manifests/apps/cilium/
```

### Update operator manifests:
```bash
# Download latest operator manifests
./manifests/stack/prometheus-operator/download_releases.sh
./manifests/stack/grafana-operator/download_release.sh
```

### View current deployments:
```bash
kubectl get pods -n monitoring
kubectl get prometheus -n monitoring
kubectl get grafana -n monitoring
```

## Configuration Management

- **ServiceMonitors**: Defined in individual app directories (e.g., `prom-sm-*.yaml`)
- **PrometheusRules**: Alert rules in `prom-rule-*.yaml` files
- **Grafana Dashboards**: Dashboard definitions in `grafana-db-*.yaml` files
- **PodMonitors**: Alternative to ServiceMonitors for direct pod scraping

## Special Considerations

### CNPG (CloudNative-PG)
- Assumes operator deployed in `cnpg-system` namespace
- Disable built-in PodMonitor in clusters: `enablePodMonitor: false`

### Keycloak
- Requires manual ServiceMonitor creation
- Enable metrics: `metrics-enabled=true` and `event-metrics-user-enabled=true`

### Loki Integration
- Creates Grafana datasource pointing to `http://loki.loki.svc.cluster.local:3100`
- Dashboards sourced from loki-mixin-compiled

### Quarkus Applications
- No standardized ServiceMonitor - create manually per application

## Day 2 Operations

The repository supports production-ready configurations through overlays:
- Persistent storage for Prometheus, Alertmanager, and Grafana
- Resource requests/limits configuration
- High availability with replicas and PodDisruptionBudgets
- Ingress exposure for web interfaces
- AlertManagerConfig for alert routing

## Monitoring Sources

The stack incorporates rules and dashboards from:
- https://github.com/bdossantos/prometheus-alert-rules
- https://samber.github.io/awesome-prometheus-alerts/
- https://github.com/dotdc/grafana-dashboards-kubernetes
- https://monitoring.mixins.dev/

## Documentation Rules

- `README.md` at the repository root **must include a link to the README.md of every stack component, app, and addon** under `manifests/stack/`, `manifests/apps/`, and `manifests/addons/`. When adding a new component directory, add its entry to the tables in `README.md`.
- Each component directory must have its own `README.md` describing its purpose, files, prerequisites, and relevant references. Content from the `doc/` folder has been distributed into the appropriate component READMEs — do not recreate the `doc/` folder.
- **Never set `namespace:` in the root kustomization.yaml** that composes this stack. Each component declares its own namespace. Some components (e.g. etcd) deploy resources into namespaces other than `monitoring` — a root namespace override would break them.
- **If a component includes Grafana dashboards**, its `README.md` must include a **Dashboard Sources** section listing where each dashboard was obtained: upstream git repository URL, grafana.com dashboard ID (with URL), or official project documentation. This applies to both inline JSON dashboards and `grafanaCom.id` references.