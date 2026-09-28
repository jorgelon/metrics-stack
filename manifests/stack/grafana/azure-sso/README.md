# azure-sso

Single sign-on for Grafana against Azure AD, with the settings read from Azure Key Vault.

A plain kustomization, because it patches nothing. List it in `resources:`.

It sets no `namespace:`, because `eso-css.yaml` is a `ClusterSecretStore`. Kustomize does
not know that a custom resource is cluster-scoped, so a `namespace:` here writes a
namespace into it. `eso-es-grafana-env.yaml` carries `namespace: monitoring` in its own
metadata instead.

## What it does

Adds two objects:

- A `ClusterSecretStore` named `akv-metrics-stack`, scoped to the `monitoring` namespace.
  It authenticates as a service principal, reading its credentials from the
  `akv-eso-creds` secret in the `external-secrets` namespace.
- An `ExternalSecret` named `grafana-env`, which builds the secret that
  `grafana-instance.yaml` already loads with `envFrom`.

The `ExternalSecret` collects every vault secret whose name starts with `GF-`, and
rewrites each `-` into a `_`. An Azure Key Vault name cannot contain a `_`, so
`GF-AUTH-AZUREAD-CLIENT-ID` in the vault becomes `GF_AUTH_AZUREAD_CLIENT_ID` in the
secret. The template then fixes the settings that never change, and fills the rest from
the vault.

When you rotate a value, Grafana restarts and picks it up. The Grafana deployment carries
a Reloader annotation on `grafana-env`.

## Requirements

- The External Secrets Operator, and the `akv-eso-creds` secret in the `external-secrets`
  namespace. That secret ships with the External Secrets Operator release.
- An Azure Key Vault, and an app registration for Grafana.
- The Prometheus Operator CRDs and the External Secrets Operator CRDs.

## What you must overlay

`eso-css.yaml` carries two `changeme` sentinels: `tenantId` and the host part of
`vaultUrl`. Patch both in the consuming kustomization.

## Vault contents

Create these secrets in the vault. This directory supplies every other Azure AD setting.

| Vault secret | Becomes |
|---|---|
| `GF-AUTH-AZUREAD-ALLOWED-GROUPS` | the group object IDs allowed to sign in |
| `GF-AUTH-AZUREAD-ALLOWED-ORGANIZATIONS` | the tenant IDs allowed to sign in |
| `GF-AUTH-AZUREAD-AUTH-URL` | the authorize endpoint of the app registration |
| `GF-AUTH-AZUREAD-TOKEN-URL` | the token endpoint of the app registration |
| `GF-AUTH-AZUREAD-CLIENT-ID` | the application ID |
| `GF-AUTH-AZUREAD-CLIENT-SECRET` | the client secret |
| `GF-SERVER-ROOT-URL` | the public URL of this Grafana |

## Usage

```yaml
resources:
  - <release>/stack
  - <release>/stack/grafana/azure-sso
```

## Caveats

This is the only directory that creates the `akv-metrics-stack` store.
[`stack/alertmanager/msteams-azurekv`](../../alertmanager/msteams-azurekv/README.md) reads
from that store without creating it. If you use that one alone, declare the store
yourself.
