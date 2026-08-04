# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Public, non-production, opinionated Prometheus/Grafana monitoring distribution for kubeadm Kubernetes clusters, built entirely with Kustomize and the Prometheus Operator + Grafana Operator ecosystems. There is no application code, no build system and no test suite — the deliverable is YAML.

This repository is **public**: never commit internal information (AWS ARNs, internal project names, cluster names, hostnames, IPs, credentials).

## How the pieces fit together

Three layers under `manifests/`:

- `stack/` — the monitoring infrastructure itself (operators, Prometheus, Alertmanager, Grafana, kube-state-metrics, node-exporter, metrics-server, plus `overlays/` with Day-2 patches). `manifests/stack/kustomization.yaml` is the source of truth for which vendored component versions are active — do not hardcode version numbers in docs, reference that file.
- `apps/` — one directory per monitored application (ServiceMonitors/PodMonitors, PrometheusRules, GrafanaDashboards). Consumers opt in per app.
- `addons/` — optional extras (currently `karma`).

**The label `app.kubernetes.io/part-of: metrics-stack` is the wiring for the whole stack.** `manifests/stack/prometheus/prom-instance.yaml` selects ServiceMonitors, PodMonitors, PrometheusRules and Probes by that label, and every `GrafanaDashboard`/`GrafanaDatasource` uses it in `spec.instanceSelector`. The label is applied by the *consumer's* root kustomization (see `README.md`), not by the component kustomizations — so a new monitor/rule/dashboard needs no label of its own, but it is invisible to Prometheus/Grafana if the consumer omits the root label.

The Prometheus instance defines a default `scrapeClass` that injects a `k8s_cluster` label; kubernetes-mixin dashboards in this repo depend on that label existing.

Consumers do not deploy from this tree directly — they clone a tag and reference paths like `../../releases/edge/apps/core` (see `README.md` "How to use"). Deployment is GitOps (ArgoCD); do not propose `kubectl apply/create/delete`.

### Vendored upstream manifests

Components that track upstream releases keep one subdirectory per version (`prometheus-operator/v0.90.0`, `grafana-operator/v5.22.2`, `metrics-server/v0.8.1`, `kubernetes/kubernetes-mixin/releases/version-1.4.2`) and are refreshed with the component's own script rather than hand-edited:

```bash
./manifests/stack/prometheus-operator/download_releases.sh
./manifests/stack/grafana-operator/download_release.sh
./manifests/stack/metrics-server/download.sh
./manifests/apps/kubernetes/kubernetes-mixin/download_release.sh   # or build_in_container.sh / build_from_source.sh
./manifests/stack/node-exporter/generate-prometheus-rule.sh
./manifests/apps/x509-certificate-exporter/generate-manifests.sh
```

Upgrading = add the new version directory, then repoint the `resources:` entry in the parent `kustomization.yaml`. Old version directories are kept.

## Working commands

```bash
# Render any component (this is the closest thing to a build/test)
kubectl kustomize manifests/stack/
kustomize build manifests/apps/envoy-gateway/

# Validate rendered output against CRD-aware schemas
kustomize build manifests/apps/core/ | kubeconform -strict -summary \
  -schema-location default \
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'

yamllint manifests/            # lint
pre-commit run --all-files     # secret scanning (betterleaks + trufflehog); CI also runs gitleaks
```

Always render the component you touched — a missing entry in `resources:` fails silently in review but breaks the consumer.

## File conventions

Manifest filenames encode the resource kind (the `gitops-name-k8s-yaml` skill enforces this):

- `prom-sm-*` ServiceMonitor · `prom-pm-*` PodMonitor · `prom-rule-*` PrometheusRule · `prom-am*` Alertmanager · `prom-amc-*` AlertmanagerConfig · `prom-instance` Prometheus
- `grafana-db-*` GrafanaDashboard · `grafana-ds-*` GrafanaDatasource · `grafana-instance`
- `k8s-*` plain Kubernetes resources, with a kind abbreviation: `k8s-cm-`, `k8s-cr-`, `k8s-crb-`, `k8s-sa-`, `k8s-svc-`, `k8s-deploy-`, `k8s-ds-`, `k8s-secret-`

Each component `kustomization.yaml` declares its own `namespace:` and an `app.kubernetes.io/name` label. Dashboards set `spec.folder` to the app name and are sourced by `url:`, `grafanaCom.id:` or inline JSON.

## Hard rules

- **Never set `namespace:` in a root kustomization.** Each component fixes its own namespace; `metrics-server` and one etcd Service intentionally live in `kube-system`, and a root override breaks them. The `README.md` "Namespaces" table must list every component that deploys outside `monitoring`.
- `README.md` at the repo root **must link to the README.md of every component** under `manifests/stack/`, `manifests/apps/` and `manifests/addons/`. Adding a component directory means adding a table row.
- Every component directory needs its own `README.md` (purpose, files, prerequisites, references). The old `doc/` folder was distributed into these — do not recreate it.
- **Components shipping Grafana dashboards must have a "Dashboard Sources" section** in their README, naming for each dashboard the upstream git URL, the grafana.com ID (with URL), or the official project docs. Applies to inline JSON and `grafanaCom.id` alike.
- Record user-visible changes in `CHANGELOG.md` under `## [Unreleased]` (Keep a Changelog 1.1.0 format, entries prefixed `**stack**:` / `**apps**:` / `**addons**:`). Releases are SemVer git tags (`v0.0.x`).
- Bash scripts start with `set -euf -o pipefail` immediately after the shebang.

## Component-specific gotchas

- **CloudNative-PG**: operator assumed in `cnpg-system`; set `enablePodMonitor: false` on Clusters so this repo's monitor is the only one.
- **Keycloak**: needs `metrics-enabled=true` and `event-metrics-user-enabled=true` on the Keycloak CR; ServiceMonitor is hand-made here.
- **Quarkus**: no standard ServiceMonitor upstream — one must be written per application.
- **Loki**: adds a Grafana datasource pointing at `http://loki.loki.svc.cluster.local:3100`; dashboards come from loki-mixin-compiled.
- **Grafana**: the instance mounts a `grafana` PVC and reads env from an optional `grafana-env` Secret, with Stakater Reloader annotations — both are supplied by the consumer.
- **kubernetes-mixin**: scheduler, controller-manager and kube-proxy alerts are deliberately disabled (managed control planes do not expose them).

## Upstream rule/dashboard sources

<https://monitoring.mixins.dev/> · <https://github.com/bdossantos/prometheus-alert-rules> · <https://samber.github.io/awesome-prometheus-alerts/> · <https://github.com/dotdc/grafana-dashboards-kubernetes>
