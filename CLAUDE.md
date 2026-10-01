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

- `stack/` holds the monitoring infrastructure itself: operators, Prometheus, Alertmanager, Grafana, kube-state-metrics, node-exporter, metrics-server, and `overlays/` with Day-2 patches. Each vendored component selects its active version in its own `kustomization.yaml`, for example `manifests/stack/prometheus-operator/kustomization.yaml`. That file is the source of truth for the version. Do not hardcode version numbers in documentation. Reference that file instead. The file `manifests/stack/kustomization.yaml` lists the children only.
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
Read `DEPLOYING.md` for the consumer side.
So a new monitor, rule or dashboard needs no label of its own.
But if the consumer omits the root label, it stays invisible to Prometheus and Grafana.

The Prometheus instance defines a default `scrapeClass` that injects a `k8s_cluster` label.
The kubernetes-mixin dashboards in this repository depend on that label.

Consumers do not deploy from this tree directly.
They clone a tag and reference paths such as `../../releases/edge/apps/core`.
Read `DEPLOYING.md`, which holds the whole consumer side: the layout, the catalog of paths, the namespaces and a worked example. The root `README.md` is an introduction and carries no deployment instructions.
Deployment is GitOps through ArgoCD.
Do not propose `kubectl apply`, `kubectl create` or `kubectl delete`.

### Kustomize components

A few directories are kustomize components (`kind: Component`). A consumer lists those under `components:`.
Every other directory is a plain kustomization that the consumer lists under `resources:`.

**The rule.** A directory that must change a resource it does not own is a component.
Every other directory is a plain kustomization.
"Change a resource it does not own" means a `patches:` entry, a `replacements:` entry, or a transformer.
The target is a resource that the parent or the consumer brought in.
A plain kustomization cannot do that. It sees only its own root, and a patch with no matching target fails the build.

Being optional is not a reason to write a component.
The consumer opts in by adding the path to `resources:`.
Prefer a plain kustomization for two reasons.
It renders on its own, so `kustomize build <dir>` and `kubeconform` test it directly.
And it sets its own `namespace:` and `labels:`, instead of repeating them in every file.

The two current components, with what each one patches:

- `manifests/apps/gateway-api/`, the kube-state-metrics ClusterRole and Deployment that the consumer deploys.
- `manifests/apps/coredns/eks-auto-mode`, the node-exporter DaemonSet of `manifests/stack`. It is one of the three coredns scrape targets. The parent `apps/coredns` ships the rules and dashboards only, and the consumer adds exactly one target. The other two, `coredns/kubeadm` and `coredns/ionos`, patch nothing and go in `resources:`.

A patch on a custom resource such as `Grafana` must be a JSON 6902 patch when it touches a list.
Kustomize has no schema for a custom resource, so a strategic merge patch replaces the whole list, for example every container with its `envFrom`.

A component's transformers rewrite the parent's resources too.
So a component sets neither `namespace:` nor `labels:`.
Each of its resources carries its own `namespace:` and its own `app.kubernetes.io/name` label in its metadata.
A component cannot render standalone.
Render it through a test kustomization that lists it under `components:`.

### Example manifests

A manifest that holds the literal sentinel `changeme` is an example, never a resource and never a component.
It lives in an `examples/` sub-directory of the component it belongs to.
That directory carries no `kustomization.yaml`, so the release never renders it, and no kustomization lists it under `resources:` or `components:`.
The current ones are `manifests/stack/examples`, `manifests/stack/alertmanager/examples`, `manifests/stack/grafana/examples`, `manifests/stack/prometheus/examples`, `manifests/addons/karma/examples` and `manifests/apps/quarkus/examples`.

Every other directory renders complete.
It needs no overlay to work, so a build of it is either deployable or broken, never quietly useless.
A sentinel binds nothing: a claim stays unbound, a mail alert goes nowhere, a SecretStore points at no region.
Inside an example that failure is the point, because the consumer replaces the value before the manifest ever reaches a cluster.
Inside a rendered resource the same failure lands at run time, far from the consumer who forgot the overlay.

An example carries no `namespace:` and no label from a parent kustomization, because the consumer copies it into a kustomization this repository does not control.
So each file holds its own `metadata.namespace` and its own `app.kubernetes.io/name` label, unless the resource is cluster-scoped.
Its header comment says what to replace and which field to list the copy under, `resources:` or `patches:`.
An `examples/` directory carries no `README.md` of its own.
List every file of it in the README of the component that owns it.
Give each file its sentinels, the folder the consumer copies it into, and the field the consumer lists it under.
A patch goes into `overlays/` and a resource goes into `instance/`.

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
Then repoint the `resources:` entry in the `kustomization.yaml` of the component directory, for example `metrics-server/kustomization.yaml`.
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

- Never set `namespace:` in a root kustomization. Each component fixes its own namespace. The `metrics-server` and one etcd Service live in `kube-system` on purpose, and a root override breaks them. The namespaces table of `DEPLOYING.md` must list every component that deploys outside `monitoring`.
- The root `README.md` must link to the README of every component under `manifests/stack/`, `manifests/apps/` and `manifests/addons/`. A new component directory means a new table row.
- Every component directory needs its own `README.md`: purpose, files, prerequisites and references. The old `doc/` folder went into these. Do not recreate it.
- Every component `README.md` needs a "How to deploy" section. It says whether the directory is a plain kustomization or a component. It names the namespace and the field the consumer lists it under. It holds a `resources:` or `components:` block with the `<release>` shorthand, and a link to `DEPLOYING.md`.
- A component that ships Grafana dashboards must have a "Dashboard Sources" section in its README. For each dashboard, name the upstream git URL, the grafana.com ID with its URL, or the official project documentation. This covers inline JSON and `grafanaCom.id` alike.
- Record user-visible changes in `CHANGELOG.md` under `## [Unreleased]`. The format is Keep a Changelog 1.1.0. Prefix each entry with `**stack**:`, `**apps**:` or `**addons**:`. Releases are SemVer git tags such as `v0.0.x`.
- A bash script starts with `set -euf -o pipefail` on the line after the shebang.

## Component-specific notes

- CloudNative-PG: the operator is assumed to run in `cnpg-system`. Set `enablePodMonitor: false` on Clusters, so this repository's monitor is the only one.
- Keycloak: the Keycloak CR needs `metrics-enabled=true` and `event-metrics-user-enabled=true`. The ServiceMonitor here is hand-made.
- Quarkus: upstream ships no standard ServiceMonitor. Write one per application, starting from `apps/quarkus/examples`.
- Loki: this component adds a Grafana datasource that points at `http://loki.loki.svc.cluster.local:3100`. The dashboards come from loki-mixin-compiled.
- Grafana: the instance reads environment variables from an optional `grafana-env` ConfigMap and an optional `grafana-env` Secret, in that order, and carries the generic Stakater Reloader annotation `reloader.stakater.com/auto: "true"`. The consumer supplies both, or copies `stack/examples/eso-css.yaml` and the two files of `stack/grafana/examples/azure-auth` to build them for Azure AD. The ConfigMap holds the settings with no secret, and the ExternalSecret builds the Secret from Azure Key Vault. The store in `stack/examples/eso-css.yaml` is shared by the whole stack, so it lives in no child directory. The instance runs one replica with the `Recreate` strategy and mounts a claim named `grafana`. The release does not create that claim, so the consumer copies `stack/grafana/examples/k8s-pvc-grafana.yaml`. Without the copy the pod stays `Pending`.
- kubernetes-mixin: the scheduler, controller-manager and kube-proxy alerts are disabled on purpose, because managed control planes do not expose them.
- Prometheus and Alertmanager: the shipped instances declare no storage and no container size. Both values track the cluster, so `stack/prometheus/examples/prom-instance.yaml` and `stack/alertmanager/examples/prom-am-instance.yaml` carry them. The `--config-reloader-cpu-limit=0` argument in `manifests/stack/prometheus-operator/kustomization.yaml` removes the 10m CPU limit that the operator gives every config-reloader sidecar. Without it the request in either example is above the limit and the StatefulSet is invalid.
- Metrics Server: `stack/metrics-server/kustomization.yaml` selects the version directory and adds `--kubelet-insecure-tls` with a JSON 6902 patch. A version directory holds the upstream manifest only, so a consumer never references it directly.
- Alertmanager: the instance ships with no routing. `stack/alertmanager/msteams` is the one deployable receiver, and it reads a secret it does not create. The mail receiver and both webhook secret sources are examples.

## Upstream rule and dashboard sources

<https://monitoring.mixins.dev/> · <https://github.com/bdossantos/prometheus-alert-rules> · <https://samber.github.io/awesome-prometheus-alerts/> · <https://github.com/dotdc/grafana-dashboards-kubernetes>
