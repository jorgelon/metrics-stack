# Gateway API Monitoring

Grafana dashboards and PrometheusRule alerts for Gateway API resources. Implementation-agnostic — works with any Gateway API provider (Envoy Gateway, Istio, etc.).

## Components

| File                             | Description                                    |
|----------------------------------|------------------------------------------------|
| `prom-rule-gateway-api.yaml`     | PrometheusRule alerts                          |
| `grafana-db-gatewayclasses.yaml` | Dashboard: Gateway API State / GatewayClasses  |
| `grafana-db-gateways.yaml`       | Dashboard: Gateway API State / Gateways        |
| `grafana-db-httproutes.yaml`     | Dashboard: Gateway API State / HTTPRoutes      |
| `grafana-db-grpcroutes.yaml`     | Dashboard: Gateway API State / GRPCRoutes      |
| `grafana-db-tcproutes.yaml`      | Dashboard: Gateway API State / TCPRoutes       |
| `grafana-db-tlsroutes.yaml`      | Dashboard: Gateway API State / TLSRoutes       |
| `grafana-db-udproutes.yaml`      | Dashboard: Gateway API State / UDPRoutes       |
| `grafana-db-policies.yaml`       | Dashboard: Gateway API State / Policies        |

## overlay/

The `overlay/` subdirectory contains the kube-state-metrics patches required to generate `gatewayapi_*` metrics:

| File                                   | Description                                             |
|----------------------------------------|---------------------------------------------------------|
| `k8s-cm-gateway-api-state-metrics.yaml`| ConfigMap with the full Custom Resource State config    |
| `k8s-cr-patch-kube-state-metrics.yaml` | JSON 6902 patch: appends Gateway API rules to ClusterRole |
| `k8s-deploy-patch-kube-state-metrics.yaml` | JSON 6902 patch: mounts ConfigMap + adds `--custom-resource-state-config-file` arg |

Wire the overlay into a parent Kustomize build that also includes `manifests/stack/kube-state-metrics/`.

## Prerequisites

The dashboards query `gatewayapi_*` metrics (e.g. `gatewayapi_gateway_info`, `gatewayapi_httproute_created`). These are **not** emitted natively — they come from kube-state-metrics via Custom Resource State Metrics. The `overlay/` directory provides everything needed to enable them.

Without the overlay applied to kube-state-metrics, all dashboards will show **No data**.

Verify after applying:

```promql
gatewayapi_gateway_info
gatewayapi_gatewayclass_info
gatewayapi_httproute_created
```

## Dashboard Sources

Dashboards were originally distributed via the [envoyproxy/gateway-addons-helm](https://github.com/envoyproxy/gateway/tree/main/charts/gateway-addons-helm) chart and are also available on Grafana.com. They are embedded as inline JSON here and adapted to use `gatewayapi_*` metrics from kube-state-metrics.

| File | Grafana.com |
|------|-------------|
| `grafana-db-gatewayclasses.yaml` | [19432](https://grafana.com/grafana/dashboards/19432) |
| `grafana-db-gateways.yaml` | [19433](https://grafana.com/grafana/dashboards/19433) |
| `grafana-db-httproutes.yaml` | [19434](https://grafana.com/grafana/dashboards/19434) |
| `grafana-db-grpcroutes.yaml`, `grafana-db-tcproutes.yaml`, `grafana-db-tlsroutes.yaml`, `grafana-db-udproutes.yaml`, `grafana-db-policies.yaml` | [19570](https://grafana.com/grafana/dashboards/19570) |

## References

- [gateway-api-state-metrics](https://github.com/Kuadrant/gateway-api-state-metrics)
- [kube-state-metrics Custom Resource State](https://github.com/kubernetes/kube-state-metrics/blob/main/docs/metrics/extend/customresourcestate-metrics.md)
- [Envoy Gateway Observability](https://gateway.envoyproxy.io/docs/tasks/observability/gateway-api-metrics/)
