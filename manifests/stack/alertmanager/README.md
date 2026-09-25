# Alertmanager

Alertmanager instance managed by the Prometheus Operator.

## Files

| File                       | Description                            |
|----------------------------|----------------------------------------|
| `prom-am-instance.yaml`    | Alertmanager CRD instance              |
| `k8s-sa-alertmanager.yaml` | ServiceAccount                         |

## Receiver components

The instance ships with no routing. Each component below adds one `AlertmanagerConfig`
that routes every alert of severity `critical`, `warning` or `info` to one receiver. Add
the one that matches where your alerts go.

| Component | Sends to | Secret backend |
|---|---|---|
| `msteams-azurekv` | Microsoft Teams | Azure Key Vault |
| `msteams-awssm` | Microsoft Teams | AWS Secrets Manager |
| `smtp` | Mail | none |

```yaml
resources:
  - <release>/stack
components:
  - <release>/stack/alertmanager/msteams-azurekv
```

Each config carries the label `app.kubernetes.io/part-of: metrics-stack`, which is what
`alertmanagerConfigSelector` in `prom-am-instance.yaml` matches.

### Microsoft Teams

The two `msteams-*` components share one receiver, which lives in the `msteams`
component. Each backend pulls it in through its own `components:` list, so you reference
a backend, never `msteams` on its own. On its own it declares a receiver whose secret
nothing creates.

Both read the webhook into a secret named `msteams-webhook-url` through the External
Secrets Operator, and they differ only in the store:

- `msteams-azurekv` reads the key `secret/msteams-webhook-url` from a `ClusterSecretStore`
  named `akv-metrics-stack`. You create that store.
- `msteams-awssm` creates its own `SecretStore` named `aws-secretsmanager`. Overlay
  `region` in `eso-ss.yaml`, and the secret `key` in `eso-es-msteams-webhook-url.yaml`.
  Both are `changeme`.

Use one of them, never both. They create the same `AlertmanagerConfig` named `teams`.

### Mail

`smtp` adds an `AlertmanagerConfig` named `smtp` with an email receiver. Overlay `from`,
`to`, `smarthost` and the subject prefix. All four are `changeme`. Set the prefix to the
environment name, so a reader can tell a staging alert from a live one.

## Storage: you must overlay the storage class

`prom-am-instance.yaml` requests a 2Gi volume with `storageClassName: changeme`. No
cluster has a storage class by that name, so you must overlay it. Until you do, the claim
stays unbound and the Alertmanager pod stays `Pending`. This is deliberate. A missing
overlay fails loudly, instead of putting the notification log on whichever class happens
to be the default.

Patch it in the consuming kustomization:

```yaml
# overlays/prom-am-instance.yaml
apiVersion: monitoring.coreos.com/v1
kind: Alertmanager
metadata:
  name: k8s-alertmanager
spec:
  storage:
    volumeClaimTemplate:
      spec:
        storageClassName: ebs-csi-gp3
```

The 2Gi request holds the notification log and the silences on every cluster we run. If
your cluster needs more, patch the size in the same place.

The Alertmanager container and its config-reloader also carry their requests and limits
here. Memory requests equal their limits, and neither container declares a CPU limit.

## Configuration

Alertmanager has no built-in routing config. Create an `AlertmanagerConfig` resource in the `monitoring` namespace to route alerts to your preferred receivers, such as PagerDuty, Slack or email.

## ArgoCD Sync Wave

Deploy at wave `-1`, after Prometheus Operator (wave -5) and Prometheus (wave -3).

See [manifests/apps/argocd/README.md](../../apps/argocd/README.md) for full wave recommendations.

## References

- [Prometheus Operator, Alertmanager](https://prometheus-operator.dev/docs/operator/alertmanager/)
- [AlertmanagerConfig CRD](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1alpha1.AlertmanagerConfig)
