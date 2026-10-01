# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [0.0.21-alpha11] - 2026-10-01

### Changed
- **stack**: **BREAKING**: you must choose the Grafana version. Add an `images:` entry for `docker.io/grafana/grafana` with your `newTag` to your kustomization. `stack/grafana` sets the tag of `spec.version` to `changeme`, so without the entry the Grafana pod stays in `ImagePullBackOff`. Before, the Grafana Operator wrote its own default into the empty `spec.version` once and never changed it, so an operator upgrade left Grafana on an old version. The new `kustomizeconfig-images.yaml` lets `images:` change `spec.version`. Read the Grafana release notes before a major upgrade, because Grafana 12 removed Angular panels

## [0.0.21-alpha10] - 2026-10-01

### Fixed
- **apps**: the three ServiceMonitors of `apps/external-secrets` now set `honorLabels: true`. The `namespace` label of the External Secrets metrics now holds the namespace of the ExternalSecret, not `external-secrets`. The "Not Ready ExternalSecrets" panel and the alert descriptions now name the correct namespace. If you query `exported_namespace` for these metrics, query `namespace` instead

## [0.0.21-alpha9] - 2026-10-01

### Changed
- **stack**: **BREAKING**: `stack/grafana/examples/eso-es-grafana-env.yaml` is now `stack/grafana/examples/eso-es-grafana-env-akv.yaml`, and it has no template. It copies every `GF-` vault secret into the `grafana-env` Secret. The fixed Azure AD settings, such as `GF_AUTH_AZUREAD_ENABLED`, moved to `stack/grafana/examples/azure-auth/k8s-cm-grafana-env.yaml`, a ConfigMap named `grafana-env`. The Grafana instance now also loads that optional ConfigMap with `envFrom`, before the Secret. Copy both files and list both under `resources:`. With only your old copy, the Secret loses the fixed settings and the Azure AD login does not show. The README of `stack/grafana` lists the seven vault secrets that Azure AD needs
- **stack**: **BREAKING**: the Grafana instance in `stack/grafana/grafana-instance.yaml` now mounts the claim named `grafana` at `/var/lib/grafana` and sets the `Recreate` strategy itself. The release does not create the claim. Copy `stack/grafana/examples/k8s-pvc-grafana.yaml`, replace `storageClassName: changeme`, and list the copy under `resources:`. Without it the Grafana pod stays `Pending`
- **stack**: **BREAKING**: `stack/grafana-operator` and `stack/prometheus-operator` now select their own version. `stack/prometheus-operator` also adds `--config-reloader-cpu-limit=0`, which used to live in `stack/kustomization.yaml`. If you list a version directory such as `stack/prometheus-operator/v0.90.0` directly, list `stack/prometheus-operator` instead, or the sidecar CPU limit comes back and the Prometheus and Alertmanager StatefulSets are invalid
- **stack**: **BREAKING**: `stack/grafana/examples/eso-css.yaml` is now `stack/examples/eso-css.yaml`, because the Grafana and the Alertmanager examples both read the `akv-metrics-stack` store. Its `app.kubernetes.io/name` label is now `metrics-stack`. Copy it again from the new path. A copy you made before keeps working
- **stack**: **BREAKING**: `stack/metrics-server` is now a plain kustomization. It selects `v0.9.0` and adds `--kubelet-insecure-tls` with a JSON 6902 patch, which used to live in `stack/kustomization.yaml`. If you list `stack/metrics-server/v0.9.0` directly, list `stack/metrics-server` instead, or the flag is missing
- **stack**: the Grafana instance in `stack/grafana/grafana-instance.yaml` now carries the generic Stakater Reloader annotation `reloader.stakater.com/auto: "true"` instead of `secret.reloader.stakater.com/reload: "grafana-env"`. Grafana now restarts when any Secret or ConfigMap that its pod reads changes, not only `grafana-env`
### Removed
- **stack**: **BREAKING**: `stack/overlays/metrics-server.yaml` is gone. `stack/metrics-server` now adds `--kubelet-insecure-tls` itself. Remove your copy from `patches:`, or the flag shows up twice
- **stack**: **BREAKING**: `stack/grafana/examples/grafana-instance.yaml` is gone, because the instance carries the volume itself. Remove your copy from `patches:`. Keep your copy of `k8s-pvc-grafana.yaml`
### Fixed
- **stack**: Grafana storage no longer drops the `envFrom` and the `resources` of the Grafana container. The old `examples/grafana-instance.yaml` was a strategic merge patch. Kustomize has no schema for the `Grafana` custom resource, so it replaced the whole `containers` list. Grafana then never read the `grafana-env` secret, and the Azure AD login did not show. The instance now declares the volume itself, so no patch is needed

## [0.0.21-alpha8] - 2026-09-28

### Added
- a `.gitignore` that holds `/later/`, a folder for work that is not ready for a release. The folder stays on disk and never reaches a commit
- `DEPLOYING.md`, the consumer walkthrough. It holds the suggested layout of your own source, the namespaces table, a catalog of every path, and a worked example. It also holds the rule for `resources:` against `components:` against a copy. The suggested layout is a root `kustomization.yaml` with no `namespace:`. Next to it go an `instance/` folder for copied example resources and an `overlays/` folder for copied example patches
- a "How to deploy" section in the README of every component under `manifests/stack/`, `manifests/apps/` and `manifests/addons/`. Each one names the namespace, the field and the path, and links to `DEPLOYING.md`

### Changed
- **BREAKING**: an `examples/` directory no longer carries a `README.md`. Its content moved into the README of the component that owns it, under an "Examples" heading. Each file now lists the folder you copy it into and the field you list the copy under. A patch goes into `overlays/` and a resource goes into `instance/`. The five merged READMEs were `stack/prometheus/examples`, `stack/alertmanager/examples`, `stack/grafana/examples`, `addons/karma/examples` and `apps/quarkus/examples`
- the root `README.md` is an introduction only. The "How to use", "resources:, components: or a copy", "examples/, the third kind" and "Namespaces" sections moved to `DEPLOYING.md`
- **BREAKING**: a manifest that holds the literal sentinel `changeme` is now an example, never a resource and never a component. It lives in an `examples/` sub-directory, which carries no `kustomization.yaml`. The release never renders that directory, and you reference it in neither `resources:` nor `components:`. You copy the file, replace every sentinel, and list your copy in your own kustomization. Every directory you do reference now renders complete, so it needs no overlay to work. The rule is written in `CLAUDE.md` and in the root `README.md`. Two components remain: `apps/gateway-api` and `apps/coredns/eks-auto-mode`. `manifests/stack` now holds none
- **stack**: **BREAKING**: `stack/prometheus/single-pvc` is now `stack/prometheus/examples`. Remove `stack/prometheus/single-pvc` from `components:`, copy `examples/prom-instance.yaml` into your own source, replace `storageClassName: changeme`, and list the copy under `patches:`
- **stack**: **BREAKING**: `stack/grafana/single-pvc` is gone. Its two files are now `stack/grafana/examples/k8s-pvc-grafana.yaml` and `stack/grafana/examples/grafana-instance.yaml`. Remove `stack/grafana/single-pvc` from `components:`, copy both files, replace `storageClassName: changeme`, and list the claim under `resources:` and the patch under `patches:`
- **stack**: **BREAKING**: `stack/grafana/azure-sso` is gone. Its two files are now `stack/grafana/examples/eso-css.yaml` and `stack/grafana/examples/eso-es-grafana-env.yaml`. Remove `stack/grafana/azure-sso` from `resources:`, copy both files, replace `tenantId` and the host part of `vaultUrl`, and list both copies under `resources:`. Set no `namespace:` in the kustomization that lists them, because `eso-css.yaml` is cluster-scoped
- **stack**: **BREAKING**: `stack/alertmanager/smtp` is gone. Its config is now `stack/alertmanager/examples/prom-amc-smtp.yaml`. Remove `stack/alertmanager/smtp` from `resources:`, copy the file, replace `from`, `to`, `smarthost` and the subject prefix, and list the copy under `resources:`
- **stack**: **BREAKING**: `stack/alertmanager/msteams-awssm` and `stack/alertmanager/msteams-azurekv` are gone. `stack/alertmanager/msteams` is now the one deployable Teams receiver, and you list it under `resources:` directly. Replace each removed directory with `stack/alertmanager/msteams` plus one copied ExternalSecret example: `examples/eso-es-msteams-webhook-url-awssm.yaml` with `examples/eso-ss.yaml` for AWS Secrets Manager, or `examples/eso-es-msteams-webhook-url-azurekv.yaml` for Azure Key Vault. Copy one, never both
- **stack**: **BREAKING**: `stack/alertmanager/prom-am-instance.yaml` no longer declares storage. It carried `storageClassName: changeme` in a manifest the release renders. Copy `stack/alertmanager/examples/prom-am-instance.yaml`, replace the storage class, and list the copy under `patches:`. Without it the operator writes the notification log and the silences to an `emptyDir`
- **stack**: **BREAKING**: neither shipped instance sizes its containers any more. `stack/prometheus/prom-instance.yaml` and `stack/alertmanager/prom-am-instance.yaml` declared the `config-reloader` requests and limits, and the Alertmanager also sized its own container. Both values track the cluster, so they moved into the same example that carries the storage. The Prometheus example now also sizes the `prometheus` container, at a 500m CPU request and 4Gi of memory. That container was sized nowhere before

### Deprecated
### Removed
- **apps**: **BREAKING**: `apps/blackbox-exporter`, `apps/jetstream` and `apps/trivy-operator` left the repository. None of them shipped a `kustomization.yaml`, so a consumer who listed one got `must build at directory: not a valid directory`. Two of them also held unrendered Helm expressions such as `{{ .Values.jetstream.namespace }}`. Each one returns once it renders

### Fixed
- **stack**: the operator now runs with `--config-reloader-cpu-limit=0`, so the `config-reloader` sidecar of the Prometheus and the Alertmanager instances gets no CPU limit. The operator applied a 10m CPU limit to that sidecar by default. That default limit survived the merge with the resources block of each instance. The CPU request of 100m was then above the limit, so the `prometheus-k8s` StatefulSet was invalid and the operator stopped reconciling it

### Security

## [0.0.21-alpha7] - 2026-09-28

### Added
- **stack**: a `README.md` for each of the four Alertmanager receivers, `msteams`, `msteams-awssm`, `msteams-azurekv` and `smtp`. They were documented in the parent `alertmanager/README.md` only

### Changed
- **stack**: **BREAKING**: `alertmanager/msteams`, `alertmanager/msteams-awssm`, `alertmanager/msteams-azurekv`, `alertmanager/smtp` and `grafana/azure-sso` are now plain kustomizations instead of kustomize components. None of them patches anything, so none needs a component. Move each one from `components:` to `resources:`. The two `msteams-*` backends now pull `../msteams` in through `resources:` as well
- **apps**: **BREAKING**: `coredns/ionos` is now a plain kustomization instead of a kustomize component. It adds a PodMonitor and patches nothing. Move it from `components:` to `resources:`. `coredns/eks-auto-mode` stays a component, because it patches the node-exporter DaemonSet
- **stack**: the converted directories now set their own `namespace: monitoring` and their own `app.kubernetes.io/name` label. `grafana/azure-sso` is the exception: it sets no `namespace:`, because kustomize writes one into its cluster-scoped `ClusterSecretStore`
- the rule for `components:` against `resources:` is now written in `CLAUDE.md` and in the root `README.md`. Only a directory that must change a resource it does not own is a component. Being optional is not a reason. Four components remain: `apps/gateway-api`, `apps/coredns/eks-auto-mode`, `stack/prometheus/single-pvc` and `stack/grafana/single-pvc`

### Fixed
- **stack**: eight resources inside components carried no `metadata.namespace`. A component sets no `namespace:` of its own, so they landed in whatever namespace the consumer supplied instead of `monitoring`. The five converted directories now get it from their `kustomization.yaml`, and `grafana/single-pvc/k8s-pvc-grafana.yaml` and `grafana/azure-sso/eso-es-grafana-env.yaml` carry it in their own metadata

## [0.0.21-alpha6] - 2026-09-28

### Added
### Changed
- **apps**: **BREAKING**: `coredns/kubeadm` is now a plain kustomization instead of a kustomize component. It adds a ServiceMonitor and patches nothing, so it needs no component. Move it from `components:` to `resources:`. It now sets its own `namespace: monitoring` and its own `app.kubernetes.io/name: coredns` label, which it took from the parent before. `coredns/eks-auto-mode` and `coredns/ionos` stay components
- **apps**: `kured/` and `loki/` now set `namespace: monitoring` in their own `kustomization.yaml`. Both relied on the consumer for the namespace, so a consumer without a root namespace landed them in `default`

### Deprecated
### Removed
### Fixed
### Security

## [0.0.21-alpha5] - 2026-09-25

### Added
- **apps**: add `coredns/ionos`, a kustomize component that scrapes CoreDNS through the pods instead of through the `kube-dns` Service. IONOS Managed Kubernetes ships a `kube-dns` Service without the `metrics` port, so the ServiceMonitor finds no targets. The PodMonitor selects pods in `kube-system` labeled `app.kubernetes.io/name: coredns`, on the port named `tcp-9153`. It sets `jobLabel: k8s-app`, so the series stay `job="kube-dns"` and the existing CoreDNS PrometheusRule and dashboards match unmodified

- **apps**: add `quarkus/examples/prom-sm-quarkus.yaml`, a starting point for scraping one Quarkus application. Quarkus applications do not share a layout, so the release still ships no scrape target of its own. Replace the name, the metrics path, the namespace and the selector label, all `changeme`
- **stack** and **addons**: add `grafana/examples/` and `karma/examples/`, manifests to copy rather than reference. Neither directory carries a `kustomization.yaml`, so the release never renders them. `gapi-httproute.yaml` in each one exposes its application through a Gateway API gateway, on one hostname and every path. Replace four `changeme` values: the Gateway name, its namespace, its listener `sectionName`, and the hostname. `grafana/examples/grafana-ds-loki.yaml` repoints the Loki datasource of `apps/loki` at another namespace. `karma/examples/k8s-cm-karma-config.yaml` opens Karma on the active alerts of one receiver, through the `karma-config` ConfigMap the Deployment already reads
- **stack**: add the `grafana/azure-sso` component: Azure AD single sign-on for Grafana, read from Azure Key Vault. It declares the `ClusterSecretStore` named `akv-metrics-stack`, which the rest of the stack reads from without declaring it. It also adds an `ExternalSecret` that builds the `grafana-env` secret the instance already loads. Overlay `tenantId` and `vaultUrl`, both `changeme`. See `stack/grafana/azure-sso/README.md`
- **stack**: add the `grafana/single-pvc` component: a 2Gi `ReadWriteOnce` claim for the SQLite database, mounted at `/var/lib/grafana`, with the deployment strategy set to `Recreate`. The instance referenced a claim the release never created, so every consumer wrote its own. Overlay `storageClassName`, which is `changeme`. The alternative is an external PostgreSQL or MySQL database through the `GF_DATABASE_*` variables, which this release ships no component for yet. See `stack/grafana/single-pvc/README.md`
- **stack**: add three receiver components under `stack/alertmanager/`. `msteams-azurekv` and `msteams-awssm` route to Microsoft Teams, reading the webhook through the External Secrets Operator from Azure Key Vault or AWS Secrets Manager. `smtp` routes to mail. The two Teams components share one receiver, held in the `msteams` component, which neither is referenced without. Each config carries `app.kubernetes.io/part-of: metrics-stack`, so `alertmanagerConfigSelector` matches it. Overlay the `changeme` sentinels listed in `stack/alertmanager/README.md`

### Changed
- **stack**: `grafana/grafana-instance.yaml` no longer declares the volume or the volume mount. Storage now belongs to the `grafana/single-pvc` component, so an instance backed by an external database does not carry a volume it never uses
- **apps**: **BREAKING**: `coredns/` no longer ships a scrape target of its own. `prom-sm-coredns.yaml` moves into a new `coredns/kubeadm` component, joining `coredns/eks-auto-mode` and `coredns/ionos`. How CoreDNS runs depends on the platform, so the choice now belongs to the consumer. A consumer that keeps only `apps/coredns` in `resources:` scrapes nothing. Add `apps/coredns/kubeadm` to `components:` to restore the previous behavior
- **stack**: add the `prometheus/single-pvc` component: one replica, `retention: 7d`, and a 100Gi `ReadWriteOnce` volume claim template. Overlay `storageClassName`, which is `changeme`. The sentinel binds nothing, so a missing overlay leaves the pod `Pending` instead of landing the time series on the default class. Without the component the operator writes to an `emptyDir` and every restart loses the data. The alternatives, two replicas and remote write to a long term store, have no component yet. See `stack/prometheus/single-pvc/README.md`
- **stack**: set the config-reloader sizing of the Prometheus instance in `stack/prometheus/prom-instance.yaml`, so consumers no longer patch it. Its memory request equals its limit and it declares no CPU limit. The prometheus container itself stays unsized, because it tracks the series count of the cluster
- **stack**: set the sizing of the Alertmanager instance in `stack/alertmanager/prom-am-instance.yaml`, so consumers no longer patch it. Both containers carry requests and limits, with memory requests equal to their limits and no CPU limit. The instance also requests a 2Gi volume with `storageClassName: changeme`, which you must overlay. The sentinel binds nothing, so a missing overlay leaves the pod `Pending` instead of landing the notification log on the default class. See `stack/alertmanager/README.md`

## [0.0.21-alpha4] - 2026-09-16

### Added
- **apps**: add `coredns/eks-auto-mode`, a kustomize component that exposes CoreDNS metrics on EKS Auto Mode clusters, where DNS runs as a node-level system service instead of a Deployment. It patches the stack's `node-exporter` DaemonSet with a `kube-rbac-proxy` sidecar that republishes the node-local `127.0.0.1:9153` endpoint over TLS, adds a headless Service and a ServiceMonitor that reuses the `node-exporter` SA token, and labels the series `job="kube-dns"` so the existing CoreDNS PrometheusRule and dashboards match unmodified
- **apps**: add `external-secrets/grafana-db-external-secrets.yaml`, the official External Secrets Operator dashboard read from the upstream repository URL
- **apps**: add three ServiceMonitors to `external-secrets/` for the controller, the cert-controller and the webhook. They are deployed in `monitoring` and select the chart's metrics Services in the `external-secrets` namespace. Enable `metrics.service.enabled`, `certController.metrics.service.enabled` and `webhook.metrics.service.enabled` in the chart, and keep `serviceMonitor.enabled=false` to avoid duplicates

### Changed
- **apps**: expand `external-secrets/prom-rule-external-secrets.yaml` from 3 to 13 alerts in 3 groups. The new alerts cover the Ready condition of ClusterExternalSecret and PushSecret, the sync and provider API error ratios, and the absence of sync activity. They also cover slow reconciliation, controller-runtime reconciliation errors, work queue depth and webhook 5xx answers

## [0.0.21-alpha3] - 2026-09-04

### Added
- **apps**: add `metallb/` — ServiceMonitors for the MetalLB controller and speaker (HTTPS metrics on port 9120, plus the FRR sidecar on 9121), the two headless metrics Services they select in `metallb-system`, and the upstream chart's alerts rendered as a plain PrometheusRule. Keep `prometheus.serviceMonitor.enabled=false` in the MetalLB chart to avoid duplicates
- **apps**: add `cilium/generate-prometheus-rule.sh`, generating `prom-rule-cilium.yaml` from awesome-prometheus-alerts
- **apps**: document in the cilium README that `cilium_bpf_syscall_duration_seconds` is disabled by default in Cilium, leaving the agent dashboard's BPF row empty until it is opted into via `prometheus.metrics`, and that the kvstore row is empty by design under `identity-allocation-mode: crd`
- **apps**: correct the cilium README prerequisites — Hubble `labelsContext` is an option of the `httpV2` metric, not a separate list entry; drop `enableOpenMetrics`/`exemplars=true`, which do nothing unless `spec.exemplars` is set on the Prometheus CR; add the missing `hubble.relay.prometheus` and `envoy.prometheus` knobs, document that cilium-agent/cilium-operator need `metricsService: true` (or `serviceMonitor.enabled: true`) or their metrics Services are never created, and note that `cilium-envoy` (port 9964) has no ServiceMonitor in this component
### Changed
- **apps**: replace the 4 hand-written cilium alerts with the generated `cilium-awesome` group (31 alerts). The cilium-enterprise mixin is deliberately not included — it targets Isovalent's commercial build and every one of its alerts duplicates or weakens an awesome-prometheus-alerts one; see the component README
- **apps**: **breaking** — `apps/gateway-api/` is now a single kustomize *component*; the `overlay/` subdirectory is gone, its four files merged into the app directory. Move `apps/gateway-api` from `resources:` to `components:` and keep the stack's kube-state-metrics. The old `overlay/` was a self-contained replacement for `stack/kube-state-metrics/`, which no consumer referencing the whole `stack/` kustomization could use (it bundles kube-state-metrics with no way to swap one component out, and kustomize refuses to reference patch files from outside a kustomization root) — so the `gatewayapi_*` series were never produced and every Gateway API dashboard showed "No data". Because a component's `namespace:`/`labels:` transformers also rewrite the parent's resources, every resource in the component now carries `namespace: monitoring` and `app.kubernetes.io/name: gateway-api` in its own metadata, and `kustomize build manifests/apps/gateway-api/` no longer works standalone
- **stack**: bump vendored `grafana-operator` to v5.25.0 and `metrics-server` to v0.9.0; drop the now-unused `grafana-operator/v5.17.1`, `grafana-operator/v5.19.4` and `metrics-server/v0.7.2` version directories
- **stack**: bump the `kube-state-metrics` image tag to v2.20.0
### Removed
- **apps**: drop `goldpinger/` — the ServiceMonitor, dashboard and PrometheusRule for the Goldpinger pod-connectivity checker
### Fixed
- **apps**: correct upstream cilium selectors that matched no series — `cilium_policy_change_total{outcome="fail"}` (the label value is `failure`) and `endpoint` filters on `cilium_k8s_client_api_calls_total` (a ServiceMonitor port name, not a Cilium label)
- **readme**: remove the stale `goldpinger` row from the root components table left behind by its removal

## [0.0.21-alpha2] - 2026-08-04

### Added
- **apps**: add envoy proxy monitoring and expand gateway-api alerts
- **apps**: add blackbox-exporter, goldpinger, jetstream, trivy-operator and a dedicated gateway-api component with README documentation for every stack/app/addon component
### Removed
- **stack**: remove the deprecated prometheus-adapter component
