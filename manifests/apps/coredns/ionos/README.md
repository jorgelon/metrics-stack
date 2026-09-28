# ionos

Scrapes CoreDNS on IONOS Managed Kubernetes, through the pods.

## Why this is needed

IONOS Managed Kubernetes ships a `kube-dns` Service that does not declare the `metrics`
port. The Service exists and the CoreDNS pods serve metrics on port 9153, but the
`ServiceMonitor` of the `kubeadm` directory has nothing to scrape.

This directory goes straight to the pods instead. It patches nothing, so it is a plain
kustomization and you list it in `resources:`.

## What it does

Adds one `PodMonitor` named `coredns`. It selects pods in `kube-system` that carry the
label `app.kubernetes.io/name: coredns`, on the port named `tcp-9153`. It sets
`jobLabel: k8s-app`, so series come out as `job="kube-dns"`. The CoreDNS `PrometheusRule`
and dashboards of this release therefore match without any change.

## Requirements

- CoreDNS pods in `kube-system` labeled `app.kubernetes.io/name: coredns`, exposing a
  container port named `tcp-9153`. Confirm both with
  `kubectl get pods -n kube-system -l app.kubernetes.io/name=coredns -o yaml`.
- The `apps/coredns` directory in `resources:`, for the rules and dashboards.
- The Prometheus Operator CRDs.

## How to deploy

This directory is a plain kustomization, not a kustomize component. It renders into the
`monitoring` namespace. List it under `resources:`, next to the parent `apps/coredns`.
Read [DEPLOYING.md](../../../../DEPLOYING.md) for the full walkthrough.

```yaml
resources:
  - <release>/apps/coredns
  - <release>/apps/coredns/ionos
```

## Caveats

Use one of `kubeadm`, `eks-auto-mode` or `ionos`, never two. They all create a scrape
target named `coredns`.
