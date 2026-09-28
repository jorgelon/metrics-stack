# kubeadm

Scrapes CoreDNS on a kubeadm cluster, through the `kube-dns` Service.

## Why this is needed

A kubeadm cluster runs CoreDNS as a Deployment in `kube-system`, behind a `kube-dns`
Service that declares a port named `metrics`. This is the standard layout, so this is the
directory most clusters use.

## What it does

Adds one `ServiceMonitor` named `coredns`. It selects the `kube-dns` Service in
`kube-system` by the labels `k8s-app: kube-dns` and `kubernetes.io/name: CoreDNS`, and
scrapes the port named `metrics`. It authenticates with the `prometheus-sa-token` bearer
credential. `jobLabel: k8s-app` keeps the series as `job="kube-dns"`.

## Requirements

- A `kube-dns` Service in `kube-system` with a port named `metrics`. Confirm with
  `kubectl get svc -n kube-system kube-dns -o yaml`.
- The `apps/coredns` directory in `resources:`, for the rules and dashboards.
- The Prometheus Operator CRDs.

## How to deploy

This directory is a plain kustomization, not a kustomize component. It renders into the
`monitoring` namespace. List it under `resources:`, next to the parent `apps/coredns`.
Read [DEPLOYING.md](../../../../DEPLOYING.md) for the full walkthrough.

```yaml
resources:
  - <release>/apps/coredns
  - <release>/apps/coredns/kubeadm
```

## Caveats

Use one of `kubeadm`, `eks-auto-mode` or `ionos`, never two. They all create a scrape
target named `coredns`. `eks-auto-mode` is a kustomize component, so it goes in
`components:` instead.
