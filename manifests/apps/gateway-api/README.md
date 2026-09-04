# Gateway API Monitoring

Grafana dashboards and PrometheusRule alerts for Gateway API resources.
Implementation-agnostic — works with any Gateway API provider (Envoy Gateway,
Istio, Cilium, NGINX). For Envoy-specific traffic metrics see
[`../envoy-gateway/`](../envoy-gateway/).

Everything here describes **configuration and status**, never traffic. Gateway
API defines no metrics of its own — there is no spec'd `/metrics` endpoint. The
`gatewayapi_*` series exist only because this component configures
kube-state-metrics to convert the custom resources into gauges. Request rates,
latency and error codes come only from the implementation.

## How to include it

This directory is a **kustomize component**, not a plain kustomization. It goes
in `components:`, alongside — not instead of — the kube-state-metrics you
already deploy:

```yaml
resources:
  - ../../releases/edge/stack            # already brings stack/kube-state-metrics
components:
  - ../../releases/edge/apps/gateway-api
```

Listed under `resources:` instead, the build fails with `no resource matches
strategic merge patch "Deployment.v1.apps/kube-state-metrics.monitoring"`.

It has to be a component because it patches kube-state-metrics, which the
consumer brings in itself. A plain kustomization cannot patch a sibling's
resources; it would have to own `stack/kube-state-metrics` and be included
*instead of* it, which is impossible when the consumer references the whole
`stack/` kustomization. Reusing the patch files from the consumer's own root is
not an option either — kustomize rejects any file outside the kustomization root
with `security; file ... is not in or below ...`. Components are applied after
the parent has accumulated its resources, so the patches reach the ClusterRole
and Deployment wherever they came from.

Two consequences worth knowing:

- `kustomize build manifests/apps/gateway-api/` **cannot** be run standalone —
  there is no kube-state-metrics to patch. Render it from a root that includes
  the stack.
- The component sets no `namespace:` and no `labels:`. A component's namespace
  and label transformers rewrite the *parent's* resources too, which would drag
  `metrics-server` out of `kube-system`. Every resource here therefore carries
  `namespace: monitoring` and `app.kubernetes.io/name: gateway-api` in its own
  metadata — keep that up when adding files.

## Components

| File                                            | Description                                              |
|-------------------------------------------------|----------------------------------------------------------|
| `prom-rule-gateway-api.yaml`                    | PrometheusRule alerts                                    |
| `grafana-db-gateways.yaml`                      | Dashboard: Gateway API State / Gateways                  |
| `grafana-db-gatewayclasses.yaml`                | Dashboard: Gateway API State / GatewayClasses            |
| `grafana-db-httproutes.yaml`                    | Dashboard: Gateway API State / HTTPRoutes                |
| `grafana-db-grpcroutes.yaml`                    | Dashboard: Gateway API State / GRPCRoutes                |
| `grafana-db-tcproutes.yaml`                     | Dashboard: Gateway API State / TCPRoutes                 |
| `grafana-db-tlsroutes.yaml`                     | Dashboard: Gateway API State / TLSRoutes                 |
| `grafana-db-udproutes.yaml`                     | Dashboard: Gateway API State / UDPRoutes                 |
| `grafana-db-backendtlspolicies.yaml`            | Dashboard: Gateway API State / BackendTLSPolicies        |
| `k8s-cm-gateway-api-state-metrics.yaml`         | ConfigMap with the Custom Resource State config          |
| `k8s-cr-patch-kube-state-metrics.yaml`          | JSON 6902: appends Gateway API rules to the ClusterRole  |
| `k8s-deploy-patch-kube-state-metrics.yaml`      | Strategic merge: mounts the ConfigMap                    |
| `k8s-deploy-patch-args-kube-state-metrics.yaml` | JSON 6902: appends `--custom-resource-state-config-file` |

The mount is a strategic merge (merges `volumes`/`volumeMounts` by name) while
the flag is a JSON 6902 append. A strategic merge would replace the whole `args`
list and silently drop the base `--metric-labels-allowlist` flag.

Miss the `components:` entry and every dashboard here shows **No data** — the
`gatewayapi_*` series simply do not exist. Confirm the wiring rendered, from
your root:

```bash
kustomize build . | grep -e custom-resource-state-config-file -e gateway.networking.k8s.io
```

## Prerequisites

All 8 resources are pinned to **`v1`**, verified against the CRDs shipped in
Gateway API **v1.6.1**. This matters more than it looks:

- `GRPCRoute` and `BackendTLSPolicy` no longer serve `v1alpha2` at all.
- `TCPRoute`, `TLSRoute` and `UDPRoute` graduated to the standard channel in
  v1.6 and now serve `v1`; `v1alpha2` survives only in the experimental channel.
- `Gateway`, `GatewayClass` and `HTTPRoute` still serve `v1beta1`, but it is
  deprecated.

This config therefore needs **Gateway API v1.6+** for the four newer resources.
On older installs those GVKs will not resolve.

An unserved GVK fails **silently**: kube-state-metrics logs
`Custom resource client does not exist` and returns an empty store. It does not
crash, so core cluster metrics are unaffected — you simply get empty dashboards
with no other signal. Verify explicitly after applying:

```promql
gatewayapi_gateway_info
gatewayapi_gatewayclass_info
count by (__name__) ({__name__=~"gatewayapi_.+"})
```

## Alerts

| Alert | Severity | Trigger |
|-------|----------|---------|
| `UnhealthyGateway` | critical | `Accepted` or `Programmed` not True for 10m |
| `GatewayNotReconciled` | critical | Gateway has no `Accepted` condition at all for 15m |
| `UnhealthyGatewayClass` | critical | GatewayClass not `Accepted` for 10m |
| `InsecureHTTPListener` | warning | listener uses plain HTTP |
| `GatewayListenerNoAttachedRoutes` | warning | listener has 0 attached routes for 30m |

`GatewayNotReconciled` exists because `UnhealthyGateway` uses `== 0`, which
requires the condition to be present. A Gateway whose `gatewayClassName` matches
no controller is never reconciled and so has no conditions at all, making it
invisible to the other rule.

`InsecureHTTPListener` matches the very common port-80 HTTP→HTTPS redirect
listener, so it is `warning` rather than `critical` and supports an opt-out: add
the Kubernetes label `allow_insecure_listener=true` to a Gateway to exempt it.
The rule excludes it via `gatewayapi_gateway_labels`, which copies Kubernetes
labels through with **no** `label_` prefix (unlike native `kube_*_labels`).

### Known limitation: no route condition metrics

`gatewayapi_*route_status_parent_info` is an `Info` metric carrying only the
parent's identity — no `type` label, no condition value. Route conditions live at
`status.parents[].conditions[]`, a list nested inside a list, which Custom
Resource State cannot flatten into a single metric. **There is therefore no way
to alert on `Accepted=False` or `ResolvedRefs=False` for a Route here**, despite
that being a common failure mode (missing backend Service, or a cross-namespace
`backendRef` with no `ReferenceGrant`). Catch those on the implementation side
instead — for Envoy Gateway, `EnvoyClusterNoHealthyUpstream` covers it.

## Dashboard Sources

Dashboards originate from the
[Kuadrant gateway-api-state-metrics](https://github.com/Kuadrant/gateway-api-state-metrics)
project, distributed via the
[envoyproxy/gateway-addons-helm](https://github.com/envoyproxy/gateway/tree/main/charts/gateway-addons-helm)
chart and published on Grafana.com. They are embedded as inline JSON and adapted
to the `gatewayapi_*` metrics this overlay produces.

| File | Grafana.com |
|------|-------------|
| `grafana-db-gatewayclasses.yaml` | [19432](https://grafana.com/grafana/dashboards/19432) |
| `grafana-db-gateways.yaml` | [19433](https://grafana.com/grafana/dashboards/19433) |
| `grafana-db-httproutes.yaml` | [19434](https://grafana.com/grafana/dashboards/19434) |
| `grafana-db-grpcroutes.yaml`, `grafana-db-tcproutes.yaml`, `grafana-db-tlsroutes.yaml`, `grafana-db-udproutes.yaml` | [19570](https://grafana.com/grafana/dashboards/19570) |
| `grafana-db-backendtlspolicies.yaml` | none — written for this repo |

The upstream "Policies" dashboard (`grafana-db-policies.yaml`) was removed: 12 of
its 14 queries targeted **Kuadrant** CRDs (`AuthPolicy`, `DNSPolicy`,
`RateLimitPolicy`, `TLSPolicy`) which are not Gateway API and are not deployed by
this repo, leaving it permanently empty.
`grafana-db-backendtlspolicies.yaml` replaces it and covers the one policy type
this overlay produces metrics for.

## References

- [gateway-api-state-metrics](https://github.com/Kuadrant/gateway-api-state-metrics)
- [kube-state-metrics Custom Resource State](https://github.com/kubernetes/kube-state-metrics/blob/main/docs/metrics/extend/customresourcestate-metrics.md)
- [Envoy Gateway: Gateway API Metrics](https://gateway.envoyproxy.io/docs/tasks/observability/gateway-api-metrics/)
