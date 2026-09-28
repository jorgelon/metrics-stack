# msteams

The shared Microsoft Teams receiver.

A plain kustomization, because it patches nothing.

## Do not reference this directory on its own

It declares a receiver that reads a secret named `msteams-webhook-url`, and it creates no
such secret. Reference one of the two backends instead. Each one pulls this directory in
through its own `resources:` list:

- [`msteams-awssm`](../msteams-awssm/README.md), for AWS Secrets Manager.
- [`msteams-azurekv`](../msteams-azurekv/README.md), for Azure Key Vault.

Use one backend, never both. They both create the `AlertmanagerConfig` named `teams`, so a
build that lists the two fails on the duplicate resource.

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

None. Both backends hold the values you must supply.

## References

- [AlertmanagerConfig CRD](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1alpha1.AlertmanagerConfig)
- [Alertmanager, Microsoft Teams receiver](https://prometheus.io/docs/alerting/latest/configuration/#msteams_config)
