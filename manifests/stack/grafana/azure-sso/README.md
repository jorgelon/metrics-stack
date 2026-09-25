# azure-sso

Single sign-on for Grafana against Azure AD, with the settings read from Azure Key Vault.

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

Create these secrets in the vault. The component supplies every other Azure AD setting.

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
components:
  - <release>/stack/grafana/azure-sso
```

## Caveats

This is the only component that creates the `akv-metrics-stack` store. The Alertmanager
component `stack/alertmanager/msteams-azurekv` reads from that store without creating it.
If you use that component alone, declare the store yourself.
