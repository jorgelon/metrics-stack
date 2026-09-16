# coredns-node-metrics

Exposes CoreDNS metrics on **EKS Auto Mode** clusters.

## Why this is needed

Auto Mode does not run the usual CoreDNS Deployment. DNS is served by CoreDNS running as a
system service on each node, so there is no `kube-dns` Service, no CoreDNS pods, and nothing
for the stack's stock `ServiceMonitor` to select. See
[CoreDNS considerations](https://docs.aws.amazon.com/eks/latest/userguide/auto-networking.html#coredns-considerations).

The node-level CoreDNS still serves the standard Prometheus endpoint, but it binds
**`127.0.0.1:9153` only** — unreachable from the Prometheus pod. The EKS metrics API
(`metrics.eks.amazonaws.com`) does not help either: it only exposes `etcd`, `kcm` and `ksh`.

## What it does

The metrics-stack `node-exporter` DaemonSet already runs `hostNetwork: true` on every node, so
its containers share the node's loopback. This component:

1. Patches that DaemonSet with a second `kube-rbac-proxy` container that republishes
   `http://127.0.0.1:9153/` on the node IP over TLS (`hostPort: 9153`), mirroring how
   node-exporter itself is exposed on 9100.
2. Adds a headless Service `coredns-node` over the node-exporter pods on that port.
3. Adds a `ServiceMonitor` that scrapes it, reusing the `node-exporter-sa-token` Bearer
   credential — the `node-exporter` ClusterRole already grants `get` on the `/metrics`
   nonResourceURL.

The Service carries `k8s-app: kube-dns` and the ServiceMonitor uses `jobLabel: k8s-app`, so
series come out as `job="kube-dns"` and the stack's existing CoreDNS PrometheusRule and Grafana
dashboards (`metrics-stack/*/apps/coredns`) match without modification. A `nodename` relabel
distinguishes the per-node instances.

## Requirements

- The metrics-stack `node-exporter` DaemonSet and its SA token secret, in namespace `monitoring`
  (the component hardcodes that namespace).
- Prometheus Operator CRDs.

## Usage

Referenced from the parent `kustomize-stack/kustomization.yaml`:

```yaml
components:
  - coredns-node-metrics
```

## Caveats

- The stock `servicemonitor-coredns` (targeting `kube-system`) stays in the render and finds zero
  targets. It is inert; drop it with a `patches` delete at the parent if the noise matters.
- The `coredns_forward` alert group never fires: `coredns_forward_request_duration_seconds`,
  `coredns_forward_responses_total` and `coredns_forward_healthcheck_failures_total` are not
  exposed by the Auto Mode CoreDNS build.
- Only applies to Auto Mode nodes. On a mixed cluster the traditional CoreDNS Deployment must be
  retained for non-Auto Mode nodes, and is scraped by the stock ServiceMonitor instead.
