# Alertmanager

Alertmanager instance managed by the Prometheus Operator.

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough. The `stack` path already brings this directory in. Reference it alone only
to deploy this part without the rest.

```yaml
resources:
  - <release>/stack/alertmanager
```

## Files

| File                       | Description                            |
|----------------------------|----------------------------------------|
| `prom-am-instance.yaml`    | Alertmanager CRD instance              |
| `k8s-sa-alertmanager.yaml` | ServiceAccount                         |

## Receivers

The instance ships with no routing. It needs at least one `AlertmanagerConfig` in the
`monitoring` namespace, carrying the label `app.kubernetes.io/part-of: metrics-stack`, which
is what `alertmanagerConfigSelector` in `prom-am-instance.yaml` matches.

One directory here ships such a config and needs no value from you.

| Directory | Sends to | Add under |
|---|---|---|
| [`msteams`](msteams/README.md) | Microsoft Teams | `resources:` |

```yaml
resources:
  - <release>/stack
  - <release>/stack/alertmanager/msteams
```

`msteams` reads the webhook URL from a secret named `msteams-webhook-url`, which it does
not create. Copy one of the two ExternalSecret examples below to build it.

## Examples

`examples/` holds manifests to copy into your own source. The directory carries no
`kustomization.yaml`, so the release never renders it. Copy a file, replace every
`changeme`, and list the copy in your own kustomization. A patch goes into your
`overlays/` folder, and a resource goes into your `instance/` folder.

| File | What it does | Copy into | List under |
|---|---|---|---|
| `prom-am-instance.yaml` | A 2Gi volume, and both containers sized | `overlays/` | `patches:` |
| `prom-amc-smtp.yaml` | Routes every alert to one mail address | `instance/` | `resources:` |
| `eso-ss.yaml` | Reads the Teams webhook URL from AWS Secrets Manager | `instance/` | `resources:` |
| `eso-es-msteams-webhook-url-awssm.yaml` | Builds the Teams webhook secret, from AWS | `instance/` | `resources:` |
| `eso-es-msteams-webhook-url-azurekv.yaml` | Builds the Teams webhook secret, from Azure | `instance/` | `resources:` |

### Storage and sizing

`prom-am-instance.yaml` of this directory declares no storage and no container size. The
operator then writes the notification log and the silences to an `emptyDir`, so every
restart loses both and a resolved alert fires again. The example patch adds a 2Gi
`ReadWriteOnce` claim and sizes both containers. Each memory request equals its limit, so
the pod lands in the Guaranteed QoS class for memory.

Replace `storageClassName: changeme` with a storage class of your cluster. Keep `stack`
under `resources:`, because a patch with no target fails the build. The operator does not
resize an existing claim, so a later change needs a new claim.

```yaml
resources:
  - <release>/stack
patches:
  - path: overlays/prom-am-instance.yaml
```

### The mail receiver

`prom-amc-smtp.yaml` sends every alert of severity `critical`, `warning` or `info` to one
mail address, for a site that does not use Microsoft Teams. It needs a smart host that
accepts mail from the cluster. Replace four values: `from`, `to`, `smarthost`, and the
subject prefix that names the environment.

### The Teams webhook secret

The receiver itself is the `msteams` directory above. Copy one ExternalSecret, never both,
because they build the same secret named `msteams-webhook-url`. Both need the External
Secrets Operator with its CRDs.

`eso-ss.yaml` and `eso-es-msteams-webhook-url-awssm.yaml` go together. Replace the region
in the store and the secret name in the ExternalSecret. The store uses the default AWS
provider chain, so the external-secrets pod needs an IAM role that reads that secret. The
secret holds the webhook URL under the property `msteams-webhook-url`.

`eso-es-msteams-webhook-url-azurekv.yaml` creates no store. It reads the
`ClusterSecretStore` named `akv-metrics-stack`, which `grafana/examples/eso-css.yaml`
declares. Copy that file too, unless the store already exists. The Key Vault holds a
secret named `secret/msteams-webhook-url`.

## ArgoCD Sync Wave

Deploy at wave `-1`, after Prometheus Operator (wave -5) and Prometheus (wave -3).

See [manifests/apps/argocd/README.md](../../apps/argocd/README.md) for full wave recommendations.

## References

- [Prometheus Operator, Alertmanager](https://prometheus-operator.dev/docs/operator/alertmanager/)
- [AlertmanagerConfig CRD](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1alpha1.AlertmanagerConfig)
- [Alertmanager, email receiver](https://prometheus.io/docs/alerting/latest/configuration/#email_config)
- [External Secrets, AWS Secrets Manager provider](https://external-secrets.io/latest/provider/aws-secrets-manager/)
- [External Secrets, Azure Key Vault provider](https://external-secrets.io/latest/provider/azure-key-vault/)
