# msteams-awssm

The Microsoft Teams receiver, with the webhook URL read from AWS Secrets Manager.

A plain kustomization, because it patches nothing. List it in `resources:`.

## Files

| File | Description |
|------|-------------|
| `eso-ss.yaml` | SecretStore named `aws-secretsmanager` |
| `eso-es-msteams-webhook-url.yaml` | ExternalSecret that builds the secret `msteams-webhook-url` |

It also pulls in [`../msteams`](../msteams/README.md), the shared receiver.

## Requirements

- The External Secrets Operator, with its CRDs.
- The Prometheus Operator CRDs, for the `AlertmanagerConfig` of `../msteams`.
- An AWS Secrets Manager secret that holds the Teams webhook URL under the property
  `msteams-webhook-url`.
- Credentials for the `SecretStore`. The store uses the default AWS provider chain, so the
  external-secrets pod needs an IAM role with read access to that secret.

## Sentinels

| File | Value | Meaning |
|------|-------|---------|
| `eso-ss.yaml` | `region` | the AWS region of the secret |
| `eso-es-msteams-webhook-url.yaml` | `key` | the name of the secret in Secrets Manager |

## Usage

```yaml
resources:
  - <release>/stack
  - <release>/stack/alertmanager/msteams-awssm
```

## Caveats

Use this directory or [`msteams-azurekv`](../msteams-azurekv/README.md), never both. Both
pull in `../msteams`, so a build that lists the two fails on the duplicate
`AlertmanagerConfig` named `teams`.

## References

- [External Secrets, AWS Secrets Manager provider](https://external-secrets.io/latest/provider/aws-secrets-manager/)
- [AlertmanagerConfig CRD](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1alpha1.AlertmanagerConfig)
