# Deploying the stack

How to build your own `kustomization.yaml` on top of a release of this repository. Read
the [README](README.md) first for what the stack contains. Below, `<release>` stands for
the path to the clone, such as `../../releases/edge`.

## The layout

Keep three things in your own source:

```text
my-cluster/
├── kustomization.yaml   # the only file that references the release
├── instance/            # copied example resources, with your values
└── overlays/            # copied example patches, with your values
```

## The root kustomization

Never set `namespace:` in it. Each directory of the release fixes its own namespace in its
own `kustomization.yaml`, and most render into `monitoring`. Two render elsewhere on
purpose. A root namespace breaks both.

| Directory | Resource | Namespace | Reason |
|---|---|---|---|
| [`stack/metrics-server`](manifests/stack/metrics-server/README.md) | all | `kube-system` | Official upstream manifest. Metrics Server is an API extension |
| [`apps/etcd`](manifests/apps/etcd/README.md) | `k8s-svc-etcd-metrics.yaml` | `kube-system` | Headless Service over the etcd pods, which run there |

Apply the labels at the root instead. The label `app.kubernetes.io/part-of: metrics-stack`
is the wiring label. Prometheus selects monitors and rules by it, and Grafana selects
dashboards and datasources by it. Without it the release renders and collects nothing.

## The three kinds of directory

A path of the release goes under `resources:`, under `components:`, or nowhere.

- A plain kustomization goes under `resources:`. Almost every directory is one. Being
  optional is not a reason for `components:`. You opt in by adding the path.
- A component goes under `components:`, because it patches a resource it does not own, and
  a plain kustomization cannot do that. Only `apps/gateway-api` and
  `apps/coredns/eks-auto-mode` are components. Listed under `resources:`, each one fails
  the build, for example with `no resource matches strategic merge patch
  "Deployment.v1.apps/kube-state-metrics.monitoring"`.
- An `examples/` directory goes in neither. It carries no `kustomization.yaml`, so the
  release never renders it. Reference it and the build fails with `must build at
  directory: not a valid directory`.

## What to copy where

An example holds a value only you know, written as the literal sentinel `changeme`. Copy
the file, replace every sentinel, then list your copy. A patch goes into `overlays/` and
under `patches:`. A full resource goes into `instance/` and under `resources:`. A patch
needs its target directory still in `resources:`.

| File to copy | Folder | Field | Replace |
|---|---|---|---|
| [`stack/examples/eso-css.yaml`](manifests/stack/README.md) | `instance/` | `resources:` | `tenantId`, `vaultUrl` |
| [`stack/prometheus/examples/prom-instance.yaml`](manifests/stack/prometheus/README.md) | `overlays/` | `patches:` | `storageClassName`, and the sizes |
| [`stack/alertmanager/examples/prom-am-instance.yaml`](manifests/stack/alertmanager/README.md) | `overlays/` | `patches:` | `storageClassName`, and the sizes |
| `stack/alertmanager/examples/prom-amc-smtp.yaml` | `instance/` | `resources:` | `from`, `to`, `smarthost` |
| `stack/alertmanager/examples/eso-ss.yaml` | `instance/` | `resources:` | `region` |
| `stack/alertmanager/examples/eso-es-msteams-webhook-url-awssm.yaml` | `instance/` | `resources:` | `remoteRef.key` |
| `stack/alertmanager/examples/eso-es-msteams-webhook-url-azurekv.yaml` | `instance/` | `resources:` | the vault key of your own tenant |
| [`stack/grafana/examples/k8s-pvc-grafana.yaml`](manifests/stack/grafana/README.md) | `instance/` | `resources:` | `storageClassName`. Required |
| `stack/grafana/examples/gapi-httproute.yaml` | `instance/` | `resources:` | gateway name, namespace, section, hostname |
| `stack/grafana/examples/grafana-ds-loki.yaml` | `overlays/` | `patches:` | the Loki service URL |
| `stack/grafana/examples/azure-auth/k8s-cm-grafana-env.yaml` | `instance/` | `resources:` | nothing |
| `stack/grafana/examples/eso-es-grafana-env-akv.yaml` | `instance/` | `resources:` | nothing. Create the vault secrets first |
| [`addons/karma/examples/k8s-cm-karma-config.yaml`](manifests/addons/karma/README.md) | `instance/` | `resources:` | the receiver name |
| `addons/karma/examples/gapi-httproute.yaml` | `instance/` | `resources:` | gateway name, namespace, section, hostname |
| [`apps/quarkus/examples/prom-sm-quarkus.yaml`](manifests/apps/quarkus/README.md) | `instance/` | `resources:` | name, metrics path, namespace, selector |

Two files need care. `grafana-ds-loki.yaml` patches a datasource that `apps/loki` brings
in, so keep `apps/loki` under `resources:`. `eso-css.yaml` is cluster-scoped, so its
kustomization must set no `namespace:`.

## The catalog

Every path below renders complete and needs no overlay to work.

### stack

Start with the single path `stack` under `resources:`. It pulls in the two operators,
Prometheus, Alertmanager, Grafana, kube-state-metrics, node-exporter and metrics-server.
To deploy one part alone, reference that child directly. The `metrics-server` child
renders into `kube-system`, and every other child into `monitoring`.

Copy `stack/grafana/examples/k8s-pvc-grafana.yaml` and list it under `resources:`. The
Grafana instance mounts that claim, and without it the Grafana pod stays `Pending`.

Add an `images:` entry for `docker.io/grafana/grafana` with a Grafana tag. The release
sets the tag to `changeme`, so without the entry the Grafana pod stays in
`ImagePullBackOff`. Read [the Grafana README](manifests/stack/grafana/README.md).

Add `stack/alertmanager/msteams` under `resources:` to route alerts. It is the one
shipped receiver, and it reads a webhook Secret that you supply.

### apps

Add one path per monitored application. All render into `monitoring` and all go under
`resources:`, except where the table says otherwise.

| Directory | Field | Notes |
|---|---|---|
| `apps/core` | `resources:` | Node and volume rules. Deploy it on every cluster |
| `apps/kubernetes` | `resources:` | Control plane rules and dashboards |
| `apps/coredns` | `resources:` | Rules and dashboards. Ships no scrape target |
| `apps/coredns/kubeadm` | `resources:` | The kubeadm scrape target |
| `apps/coredns/ionos` | `resources:` | The IONOS scrape target |
| `apps/coredns/eks-auto-mode` | `components:` | The EKS Auto Mode scrape target. Patches node-exporter |
| `apps/gateway-api` | `components:` | Patches the kube-state-metrics ClusterRole and Deployment |
| `apps/etcd` | `resources:` | One Service renders into `kube-system` |
| `apps/metallb` | `resources:` | Two Services render into `metallb-system` |
| `apps/quarkus` | `resources:` | Dashboard only. Write the scrape target from the example |
| `apps/argocd`, `apps/cilium`, `apps/cloudnative-pg`, `apps/envoy-gateway`, `apps/external-secrets`, `apps/infisical`, `apps/karpenter`, `apps/keycloak`, `apps/kured`, `apps/loki`, `apps/x509-certificate-exporter` | `resources:` | One path each |

Add exactly one CoreDNS scrape target, always next to the parent `apps/coredns`. Two
targets produce the same job name twice. Read the README of each app before you add it,
because several need a change on the application first, such as a metrics port.

### addons

`addons/karma` is an alert dashboard. It renders into `monitoring` and goes under
`resources:`. Copy its ConfigMap example to point it at your receiver.

## A worked example

A kubeadm cluster with storage, Teams alerts through Azure Key Vault, and Karma:

```yaml
resources:
  - <release>/stack
  - <release>/stack/alertmanager/msteams
  - <release>/apps/core
  - <release>/apps/kubernetes
  - <release>/apps/coredns
  - <release>/apps/coredns/kubeadm
  - <release>/addons/karma
  - instance/k8s-pvc-grafana.yaml
  - instance/eso-es-msteams-webhook-url-azurekv.yaml
  - instance/k8s-cm-karma-config.yaml
patches:
  - path: overlays/prom-instance.yaml
  - path: overlays/prom-am-instance.yaml
images:
  - name: docker.io/grafana/grafana
    newTag: 13.1.3
labels:
  - pairs:
      app.kubernetes.io/part-of: metrics-stack
      app.kubernetes.io/managed-by: kustomize
      app.kubernetes.io/instance: MY-CLUSTER
      app.kubernetes.io/version: PUT-THE-TAG-HERE
```

## Render before you commit

Deployment is GitOps through ArgoCD, so the build is your only test:

```bash
kustomize build my-cluster/
kustomize build my-cluster/ | kubeconform -strict -summary \
  -schema-location default \
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'
```

Read the output once. Make sure that `metrics-server` carries `namespace: kube-system`
and that every other object carries the wiring label.
