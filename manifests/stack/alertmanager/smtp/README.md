# smtp

Mail alerting, for sites that do not use Microsoft Teams.

A plain kustomization, because it patches nothing. List it in `resources:`.

## Files

| File | Description |
|------|-------------|
| `prom-amc-smtp.yaml` | AlertmanagerConfig named `smtp`, with the email receiver |

## What it does

Routes every alert of severity `critical`, `warning` or `info` to one mail address. The
config carries the label `app.kubernetes.io/part-of: metrics-stack`, which
`alertmanagerConfigSelector` in `prom-am-instance.yaml` matches. It also carries the
ArgoCD sync wave `-2`.

## Requirements

- A smart host that accepts mail from the cluster.

## Sentinels

Four values in `prom-amc-smtp.yaml` are `changeme`. Overlay all four:

| Value | Meaning |
|-------|---------|
| `from` | the sender address |
| `to` | the recipient address |
| `smarthost` | the mail relay, as `host:port` |
| subject prefix | the environment name, so a reader can tell a staging alert from a live one |

## Usage

```yaml
resources:
  - <release>/stack
  - <release>/stack/alertmanager/smtp
```

## References

- [AlertmanagerConfig CRD](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1alpha1.AlertmanagerConfig)
- [Alertmanager, email receiver](https://prometheus.io/docs/alerting/latest/configuration/#email_config)
