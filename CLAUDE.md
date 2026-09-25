# CLAUDE.md

When Claude Code (claude.ai/code) works in this repository, this file provides its guidance.

## Repository overview

This is a public, non-production, opinionated Prometheus and Grafana monitoring distribution for kubeadm Kubernetes clusters.
It is built entirely with Kustomize, the Prometheus Operator and the Grafana Operator.
There is no application code, no build system and no test suite.
The deliverable is YAML.

This repository is public.
Never commit internal information: AWS ARNs, internal project names, cluster names, hostnames, IP addresses or credentials.

## How the pieces fit together

There are three layers under `manifests/`:

- `stack/` holds the monitoring infrastructure itself: operators, Prometheus, Alertmanager, Grafana, kube-state-metrics, node-exporter, metrics-server, and `overlays/` with Day-2 patches. The file `manifests/stack/kustomization.yaml` is the source of truth for the active vendored component versions. Do not hardcode version numbers in documentation. Reference that file instead.
- `apps/` holds one directory per monitored application: ServiceMonitors, PodMonitors, PrometheusRules and GrafanaDashboards. Consumers opt in per app.
- `addons/` holds optional extras. Today that is `karma` only.

A component directory can also hold sub-directories that the consumer opts into.
Read "Kustomize components" and "Example manifests" below.

### The wiring label

The label `app.kubernetes.io/part-of: metrics-stack` wires the whole stack together.
The file `manifests/stack/prometheus/prom-instance.yaml` selects ServiceMonitors, PodMonitors, PrometheusRules and Probes by that label.
Every `GrafanaDashboard` and `GrafanaDatasource` uses it in `spec.instanceSelector`.
The `Alertmanager` instance selects `AlertmanagerConfig` resources by the same label.
The consumer's root kustomization applies the label, not the component kustomizations.
Read `README.md` for the consumer side.
So a new monitor, rule or dashboard needs no label of its own.
But if the consumer omits the root label, it stays invisible to Prometheus and Grafana.

The Prometheus instance defines a default `scrapeClass` that injects a `k8s_cluster` label.
The kubernetes-mixin dashboards in this repository depend on that label.

Consumers do not deploy from this tree directly.
They clone a tag and reference paths such as `../../releases/edge/apps/core`.
Read the "How to use" section of `README.md`.
Deployment is GitOps through ArgoCD.
Do not propose `kubectl apply`, `kubectl create` or `kubectl delete`.

### Kustomize components

Several directories are kustomize components (`kind: Component`) instead of plain kustomizations.
A consumer lists them under `components:`, not under `resources:`.
A component exists where the correct content depends on the platform or on the consumer's secret backend, so the release cannot pick one.
The current components are:

- `manifests/apps/gateway-api/`, which patches the consumer's kube-state-metrics.
- `manifests/apps/coredns/kubeadm`, `coredns/eks-auto-mode` and `coredns/ionos`, one scrape target per platform. The parent `apps/coredns` ships the rules and dashboards only. A consumer must add exactly one of the three.
- `manifests/stack/prometheus/single-pvc` and `manifests/stack/grafana/single-pvc`, which add persistent storage.
- `manifests/stack/grafana/azure-sso`, which adds Azure AD single sign-on through the External Secrets Operator.
- `manifests/stack/alertmanager/msteams`, `msteams-awssm`, `msteams-azurekv` and `smtp`, the notification receivers. The `msteams` component holds the shared receiver. Consumers reference `msteams-awssm` or `msteams-azurekv`, which pull `msteams` in through their own `components:`.

A component's transformers rewrite the parent's resources too.
So a component sets neither `namespace:` nor `labels:`.
Each of its resources carries its own `namespace:` and its own `app.kubernetes.io/name` label in its metadata.
A component cannot render standalone.
Render it through a test kustomization that lists it under `components:`.

Values that the consumer must supply appear as the literal sentinel `changeme`, for example `storageClassName: changeme`.
A sentinel binds nothing, so a missing overlay fails loudly instead of landing on a default.
List every sentinel of a component in its README.

### Example manifests

An `examples/` directory holds manifests to copy, not to reference.
It carries no `kustomization.yaml`, so the release never renders it.
Each file uses `changeme` sentinels.
The current ones are `manifests/stack/grafana/examples`, `manifests/addons/karma/examples` and `manifests/apps/quarkus/examples`.

### Vendored upstream manifests

Components that track upstream releases keep one sub-directory per version, for example `prometheus-operator/v0.90.0` or `metrics-server/v0.8.1`.
Refresh them with the component's own script instead of hand-editing them:

```bash
./manifests/stack/prometheus-operator/download_releases.sh
./manifests/stack/grafana-operator/download_release.sh
./manifests/stack/metrics-server/download.sh
./manifests/apps/kubernetes/kubernetes-mixin/download_release.sh   # or build_in_container.sh / build_from_source.sh
./manifests/stack/node-exporter/generate-prometheus-rule.sh
./manifests/apps/cilium/generate-prometheus-rule.sh
./manifests/apps/x509-certificate-exporter/generate-manifests.sh
```

To upgrade, add the new version directory.
Then repoint the `resources:` entry in the parent `kustomization.yaml`.
Keep the old version directories.

## Working commands

```bash
# Render any component. This is the closest thing to a build or a test.
kubectl kustomize manifests/stack/
kustomize build manifests/apps/envoy-gateway/

# Validate rendered output against CRD-aware schemas
kustomize build manifests/apps/core/ | kubeconform -strict -summary \
  -schema-location default \
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'

yamllint manifests/            # lint
pre-commit run --all-files     # secret scanning (betterleaks + trufflehog); CI also runs gitleaks
```

Always render the component you touched.
A missing entry in `resources:` renders without an error, so review does not catch it, but the consumer breaks.

## File conventions

A manifest filename encodes the resource kind.
The `gitops-name-k8s-yaml` skill enforces this.

- `prom-sm-` ServiceMonitor, `prom-pm-` PodMonitor, `prom-rule-` PrometheusRule, `prom-am` Alertmanager, `prom-amc-` AlertmanagerConfig, `prom-instance` Prometheus
- `grafana-db-` GrafanaDashboard, `grafana-ds-` GrafanaDatasource, `grafana-instance` Grafana
- `eso-es-` ExternalSecret, `eso-ss-` SecretStore, `eso-css-` ClusterSecretStore
- `gapi-httproute` HTTPRoute
- `k8s-` plain Kubernetes resources, with a kind abbreviation: `k8s-cm-`, `k8s-cr-`, `k8s-crb-`, `k8s-sa-`, `k8s-svc-`, `k8s-deploy-`, `k8s-ds-`, `k8s-secret-`, `k8s-pvc-`

Each component `kustomization.yaml` declares its own `namespace:` and an `app.kubernetes.io/name` label.
A `kind: Component` kustomization is the exception, as described above.
Dashboards set `spec.folder` to the app name.
A dashboard is sourced by `url:`, by `grafanaCom.id:` or by inline JSON.

## Hard rules

- Never set `namespace:` in a root kustomization. Each component fixes its own namespace. The `metrics-server` and one etcd Service live in `kube-system` on purpose, and a root override breaks them. The "Namespaces" table of `README.md` must list every component that deploys outside `monitoring`.
- The root `README.md` must link to the README of every component under `manifests/stack/`, `manifests/apps/` and `manifests/addons/`. A new component directory means a new table row.
- Every component directory needs its own `README.md`: purpose, files, prerequisites and references. The old `doc/` folder went into these. Do not recreate it.
- A component that ships Grafana dashboards must have a "Dashboard Sources" section in its README. For each dashboard, name the upstream git URL, the grafana.com ID with its URL, or the official project documentation. This covers inline JSON and `grafanaCom.id` alike.
- Record user-visible changes in `CHANGELOG.md` under `## [Unreleased]`. The format is Keep a Changelog 1.1.0. Prefix each entry with `**stack**:`, `**apps**:` or `**addons**:`. Releases are SemVer git tags such as `v0.0.x`.
- A bash script starts with `set -euf -o pipefail` on the line after the shebang.

## Component-specific notes

- CloudNative-PG: the operator is assumed to run in `cnpg-system`. Set `enablePodMonitor: false` on Clusters, so this repository's monitor is the only one.
- Keycloak: the Keycloak CR needs `metrics-enabled=true` and `event-metrics-user-enabled=true`. The ServiceMonitor here is hand-made.
- Quarkus: upstream ships no standard ServiceMonitor. Write one per application, starting from `apps/quarkus/examples`.
- Loki: this component adds a Grafana datasource that points at `http://loki.loki.svc.cluster.local:3100`. The dashboards come from loki-mixin-compiled.
- Grafana: the instance reads environment variables from an optional `grafana-env` Secret and carries Stakater Reloader annotations. The consumer supplies that Secret. Storage lives in the `single-pvc` component, not in the instance.
- kubernetes-mixin: the scheduler, controller-manager and kube-proxy alerts are disabled on purpose, because managed control planes do not expose them.

## Upstream rule and dashboard sources

<https://monitoring.mixins.dev/> · <https://github.com/bdossantos/prometheus-alert-rules> · <https://samber.github.io/awesome-prometheus-alerts/> · <https://github.com/dotdc/grafana-dashboards-kubernetes>
