# Envoy Gateway Monitoring

## Overview

ServiceMonitor for the Envoy Gateway control plane.

## Components

| File                         | Description                                        |
|------------------------------|----------------------------------------------------|
| `prom-sm-envoy-gateway.yaml` | ServiceMonitor for the envoy-gateway control plane |

## Metrics

The ServiceMonitor scrapes the envoy-gateway control plane in the
`envoy-gateway-system` namespace (labels `app.kubernetes.io/name: eg`,
`control-plane: envoy-gateway`, port `metrics`/19001).

Available metrics include `controller_runtime_*`, `xds_*`, `watchable_*`,
`resource_apply_*`, `status_update_*` and Go runtime metrics.

## See Also

- Gateway API dashboards and alerts: `../gateway-api/`
- [Envoy Gateway Observability](https://gateway.envoyproxy.io/docs/tasks/observability/gateway-api-metrics/)

## Pending dashboards

- <https://github.com/envoyproxy/gateway/tree/main/charts/gateway-addons-helm/dashboards>
