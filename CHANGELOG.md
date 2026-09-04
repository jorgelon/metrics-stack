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
