# MetalLB Monitoring

ServiceMonitors and PrometheusRule alerts for [MetalLB](https://metallb.io/), the bare-metal load-balancer implementation for Kubernetes.

MetalLB serves its metrics over HTTPS on port `9120` for both the controller and the speaker, and on port `9121` for the FRR sidecar when the speaker runs in FRR mode. The upstream chart only creates the headless metrics Services when `prometheus.serviceMonitor.enabled=true`, so this component ships its own copies of them and keeps the ServiceMonitors here — a stock MetalLB install needs no monitoring-related values.

## Components

| File                                      | Description                                                    |
|-------------------------------------------|----------------------------------------------------------------|
| `k8s-svc-metallb-controller-metrics.yaml` | Headless Service exposing the controller metrics port          |
| `k8s-svc-metallb-speaker-metrics.yaml`    | Headless Service exposing the speaker (and FRR) metrics ports  |
| `prom-sm-metallb-controller.yaml`         | ServiceMonitor for the controller                              |
| `prom-sm-metallb-speaker.yaml`            | ServiceMonitor for the speaker (metrics + FRR metrics)         |
| `prom-rule-metallb.yaml`                  | PrometheusRule alerts                                          |

## Namespaces

The two Services live in `metallb-system` (they must sit next to the pods they select); the ServiceMonitors and the PrometheusRule live in `monitoring`.

## Prerequisites

- MetalLB installed in the `metallb-system` namespace, with its pods carrying the standard chart labels `app.kubernetes.io/name: metallb` and `app.kubernetes.io/component: controller|speaker`. Installations from the plain `metallb-native.yaml` manifest use different labels — adjust the Service selectors accordingly.
- Leave `prometheus.serviceMonitor.enabled` and `prometheus.podMonitor.enabled` at their default `false` in the MetalLB chart, otherwise the chart creates duplicate Services and monitors.
- Metrics are served with a self-signed certificate, so both ServiceMonitors set `insecureSkipVerify: true` and authenticate with the Prometheus service account token. The `prometheus` ClusterRole in `manifests/stack/prometheus/` already grants the required `get/list/watch` on services, endpoints and pods, so the chart's `prometheus.rbacPrometheus` Role is not needed.
- The FRR endpoint (`frrmetricshttps`) only produces targets when the speaker runs in FRR mode (`speaker.frr.enabled=true`). It is harmless otherwise.

## Alerts

`MetalLBStaleConfig`, `MetalLBConfigNotLoaded`, `MetalLBAddressPoolExhausted`, `MetalLBAddressPoolUsage{75,85,95}Percent` and `MetalLBBGPSessionDown` — rendered from the upstream chart template with its default values (no excluded pools, all alert groups enabled).

## References

- [MetalLB documentation](https://metallb.io/)
- [Upstream `prometheusrules.yaml` template](https://github.com/metallb/metallb/blob/main/charts/metallb/templates/prometheusrules.yaml)
- [Upstream `servicemonitor.yaml` template](https://github.com/metallb/metallb/blob/main/charts/metallb/templates/servicemonitor.yaml)
- [MetalLB chart values](https://github.com/metallb/metallb/blob/main/charts/metallb/values.yaml)
