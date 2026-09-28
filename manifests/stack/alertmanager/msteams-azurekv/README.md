# msteams-azurekv

The Microsoft Teams receiver, with the webhook URL read from Azure Key Vault.

A plain kustomization, because it patches nothing. List it in `resources:`.

## Files

| File | Description |
|------|-------------|
| `eso-es-msteams-webhook-url.yaml` | ExternalSecret that builds the secret `msteams-webhook-url` |

It also pulls in [`../msteams`](../msteams/README.md), the shared receiver.

## Requirements

- The External Secrets Operator, with its CRDs.
- The Prometheus Operator CRDs, for the `AlertmanagerConfig` of `../msteams`.
- A `ClusterSecretStore` named `akv-metrics-stack`. This directory does not create it.
  [`stack/grafana/azure-sso`](../../grafana/azure-sso/README.md) creates one with that
  name. If you do not use Azure single sign-on, create the store yourself.
- A Key Vault secret named `secret/msteams-webhook-url` that holds the webhook URL.

## Sentinels

None. The store name and the Key Vault key are fixed.

## Usage

```yaml
resources:
  - <release>/stack
  - <release>/stack/alertmanager/msteams-azurekv
```

## Caveats

Use this directory or [`msteams-awssm`](../msteams-awssm/README.md), never both. Both pull
in `../msteams`, so a build that lists the two fails on the duplicate `AlertmanagerConfig`
named `teams`.

## References

- [External Secrets, Azure Key Vault provider](https://external-secrets.io/latest/provider/azure-key-vault/)
- [AlertmanagerConfig CRD](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1alpha1.AlertmanagerConfig)
