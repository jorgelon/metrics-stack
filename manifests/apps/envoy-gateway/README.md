# Envoy Gateway Monitoring

## Overview

Monitoring for Envoy Gateway as a Gateway API implementation, covering both the
**control plane** (the `envoy-gateway` controller that translates Gateway API
resources into xDS) and the **data plane** (the Envoy proxy pods that serve
traffic).

Gateway API *resource state* (Gateways, HTTPRoutes, listener status) is
implementation-agnostic and lives in [`../gateway-api/`](../gateway-api/). This
directory covers the Envoy-specific traffic and runtime metrics.

## Components

| File                                   | Description                                        |
|----------------------------------------|----------------------------------------------------|
| `prom-sm-envoy-gateway.yaml`           | ServiceMonitor for the envoy-gateway control plane |
| `prom-pm-envoy-proxy.yaml`             | PodMonitor for the Envoy proxy data plane          |
| `prom-rule-envoy-gateway.yaml`         | PrometheusRule alerts (control plane + data plane) |
| `grafana-db-envoy-gateway-global.yaml` | Dashboard: Envoy Gateway Global (control plane)    |
| `grafana-db-envoy-proxy-global.yaml`   | Dashboard: Envoy Global (data plane)               |
| `grafana-db-envoy-clusters.yaml`       | Dashboard: Envoy Clusters (upstreams)              |

## How the metrics are produced

Three distinct producers, which is why three separate scrape paths exist:

| Metrics | Prefix | Produced by | Exposed on |
|---------|--------|-------------|------------|
| Gateway API resource state | `gatewayapi_*` | kube-state-metrics Custom Resource State, reading the CRs from the API server | kube-state-metrics `/metrics` |
| Control plane runtime | `controller_runtime_*`, `xds_*`, `watchable_*`, `status_update_*` | the envoy-gateway controller | Service `envoy-gateway-metrics-service`, port `metrics` (19001) |
| Data plane traffic | `envoy_*` | each Envoy proxy's own stats subsystem | proxy pod port `metrics` (19001), path `/stats/prometheus` |

Nothing generates the `gatewayapi_*` series natively — see
[`../gateway-api/`](../gateway-api/) for the kube-state-metrics overlay that
enables them.

### Control plane

The ServiceMonitor selects the `envoy-gateway-system` namespace by labels
`app.kubernetes.io/name: eg` and `control-plane: envoy-gateway`. Available
metrics include `controller_runtime_*`, `xds_*`, `watchable_*`,
`resource_apply_*`, `status_update_*` and Go runtime metrics.

### Data plane

Envoy Gateway provisions one Deployment of Envoy proxies per Gateway (or per
merged GatewayClass). When the Prometheus telemetry sink is enabled — which is
the **default** — the proxy container gets a port named `metrics` on 19001
serving Envoy's own `/stats/prometheus` endpoint.

The PodMonitor matches on pod labels rather than namespace, because the proxy
Deployment lands in `envoy-gateway-system` by default but in the Gateway's own
namespace under namespaced deployment mode:

- `app.kubernetes.io/name: envoy`
- `app.kubernetes.io/component: proxy`
- `app.kubernetes.io/managed-by: envoy-gateway`

The proxy's LoadBalancer Service only exposes the Gateway listener ports, not
19001 — hence a PodMonitor rather than a ServiceMonitor.

Relabelings promote `gateway.envoyproxy.io/owning-gateway-name` and
`...-owning-gateway-namespace` to `gateway_name` / `gateway_namespace`, and pin
`job` to `envoy-proxy` (the control plane pins `job` to `envoy-gateway`) so the
alert expressions have a stable selector instead of depending on the scraped
Service name.

Key data plane metrics:

- `envoy_http_downstream_rq_xx{envoy_response_code_class="5"}` — client-facing response codes per listener
- `envoy_cluster_upstream_rq_xx` — upstream response codes per cluster
- `envoy_cluster_membership_healthy` / `_total` — upstream endpoint health
- `envoy_cluster_upstream_cx_connect_fail` — upstream connection failures
- `envoy_control_plane_connected_state` — whether the proxy still has an xDS connection
- `envoy_server_live`, `envoy_server_memory_allocated`, `envoy_server_uptime`

## Prerequisites

The Prometheus sink is on by default. Confirm it has not been disabled on the
`EnvoyProxy` resource referenced by your GatewayClass:

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
spec:
  telemetry:
    metrics:
      prometheus:
        disable: false   # default
```

Verify both planes are being scraped:

```promql
count by (job) (up{job=~"envoy-gateway|envoy-proxy"})
envoy_server_live
```

## Alerts

| Alert | Severity | Trigger |
|-------|----------|---------|
| `EnvoyGatewayControlPlaneDown` | critical | control plane target down 10m |
| `EnvoyGatewayReconcileErrors` | warning | controller-runtime reconcile errors 15m |
| `EnvoyGatewayCertWatcherErrors` | warning | cannot read serving certificate |
| `EnvoyProxyDown` | critical | proxy target down 10m |
| `EnvoyProxyNotLive` | critical | `envoy_server_live == 0` |
| `EnvoyProxyXdsDisconnected` | critical | proxy lost xDS connection 10m |
| `EnvoyClusterNoHealthyUpstream` | critical | 0 healthy members, non-empty membership |
| `EnvoyClusterDegraded` | warning | <60% members healthy 15m |
| `EnvoyListenerHigh5xxRate` | warning | >5% downstream 5xx 10m |
| `EnvoyClusterHigh5xxRate` | warning | >5% upstream 5xx 10m |
| `EnvoyClusterUpstreamConnectFailures` | warning | >0.1 connect failures/s 10m |

`EnvoyProxyXdsDisconnected` catches a failure mode the Gateway API status
conditions do not: a disconnected proxy keeps serving its last known
configuration, so Gateways stay `Accepted`/`Programmed` while route changes are
silently dropped.

## Dashboard Sources

All three dashboards are referenced by `url` from the upstream
[envoyproxy/gateway gateway-addons-helm chart](https://github.com/envoyproxy/gateway/tree/main/charts/gateway-addons-helm/dashboards)
(`main` branch), matching the pattern used by `../cilium/`.

| File | Upstream dashboard |
|------|--------------------|
| `grafana-db-envoy-gateway-global.yaml` | `envoy-gateway-global.json` — "Envoy Gateway Global" |
| `grafana-db-envoy-proxy-global.yaml` | `envoy-proxy-global.json` — "Envoy Global" |
| `grafana-db-envoy-clusters.yaml` | `envoy-clusters.json` — "Envoy Clusters" |

Not included: `global-ratelimit.json`, which requires the optional Envoy Gateway
rate limit service (`envoy-ratelimit`) to be deployed.

## See Also

- Gateway API state dashboards and alerts: [`../gateway-api/`](../gateway-api/)
- [Envoy Gateway: Gateway API Metrics](https://gateway.envoyproxy.io/docs/tasks/observability/gateway-api-metrics/)
- [Envoy Gateway: Proxy Metrics](https://gateway.envoyproxy.io/docs/tasks/observability/proxy-metric/)
- [Envoy: statistics overview](https://www.envoyproxy.io/docs/envoy/latest/operations/stats_overview)
