# msteams

The shared Microsoft Teams receiver.

A plain kustomization, because it patches nothing. List it in `resources:`.

```yaml
resources:
  - <release>/stack
  - <release>/stack/alertmanager/msteams
```

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../../DEPLOYING.md) for the full
walkthrough. The `stack` path does not bring it in. Add it yourself to route alerts.

```yaml
resources:
  - <release>/stack/alertmanager/msteams
```

## You must supply the secret

It declares a receiver that reads a secret named `msteams-webhook-url`, and it creates no
such secret. Copy one of the two ExternalSecret examples from
[`../examples`](../README.md#the-teams-webhook-secret) to build it:

- `eso-es-msteams-webhook-url-awssm.yaml`, with `eso-ss.yaml`, for AWS Secrets Manager.
- `eso-es-msteams-webhook-url-azurekv.yaml`, for Azure Key Vault.

Copy one, never both. They build the same secret.

## Files

| File | Description |
|------|-------------|
| `prom-amc-teams.yaml` | AlertmanagerConfig named `teams`, with the Teams receiver |

## What it does

Routes every alert of severity `critical`, `warning` or `info` to one Microsoft Teams
webhook. The webhook URL comes from the key `msteams-webhook-url` of the secret
`msteams-webhook-url`, in the `monitoring` namespace.

The config carries the label `app.kubernetes.io/part-of: metrics-stack`, which
`alertmanagerConfigSelector` in `prom-am-instance.yaml` matches. It also carries the
ArgoCD sync wave `-2`.

## Sentinels

None. The two ExternalSecret examples hold the values you must supply.

## References

- [AlertmanagerConfig CRD](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1alpha1.AlertmanagerConfig)
- [Alertmanager, Microsoft Teams receiver](https://prometheus.io/docs/alerting/latest/configuration/#msteams_config)
