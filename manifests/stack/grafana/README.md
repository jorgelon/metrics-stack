# Grafana

Grafana instance managed by the Grafana Operator, with a Prometheus datasource pre-configured.

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough. The `stack` path already brings this directory in. Reference it alone only
to deploy this part without the rest.

```yaml
resources:
  - <release>/stack/grafana
```

## Files

| File                        | Description                              |
|-----------------------------|------------------------------------------|
| `grafana-instance.yaml`     | Grafana CRD instance                     |
| `grafana-ds-prometheus.yaml`| Grafana datasource pointing to Prometheus|

The base declares no storage, no authentication and no route. Every one of those needs a
value that this repository cannot know, so each one is an example to copy.

## Examples

`examples/` holds manifests to copy into your own source. The directory carries no
`kustomization.yaml`, so the release never renders it. Copy a file, replace every
`changeme`, and list the copy in your own kustomization. A patch goes into your
`overlays/` folder, and a resource goes into your `instance/` folder.

| File | What it does | Copy into | List under |
|---|---|---|---|
| `gapi-httproute.yaml` | Exposes Grafana through a Gateway API gateway | `instance/` | `resources:` |
| `grafana-ds-loki.yaml` | Repoints the Loki datasource of `apps/loki` | `overlays/` | `patches:` |
| `k8s-pvc-grafana.yaml` | A 2Gi volume for the SQLite database | `instance/` | `resources:` |
| `grafana-instance.yaml` | Mounts that volume and sets the `Recreate` strategy | `overlays/` | `patches:` |
| `eso-css.yaml` | The Azure Key Vault store that the whole stack reads from | `instance/` | `resources:` |
| `eso-es-grafana-env.yaml` | Azure AD single sign-on, read from that vault | `instance/` | `resources:` |

```yaml
resources:
  - <release>/stack
  - instance/k8s-pvc-grafana.yaml
patches:
  - path: overlays/grafana-instance.yaml
```

### The route

The base creates no route, so Grafana is reachable inside the cluster only.
`gapi-httproute.yaml` sends every path of one hostname to the `grafana-k8s-service`
Service on port 3000. Replace the Gateway name, its namespace, its listener `sectionName`
and the hostname. You need the Gateway API CRDs and a controller for them. You also need a
`Gateway` with a listener that accepts your hostname, and DNS that points at that gateway.
Set `GF_SERVER_ROOT_URL` to the same hostname, or Grafana builds broken redirect URLs.

### The Loki datasource

`grafana-ds-loki.yaml` patches the `GrafanaDatasource` named `loki` that `apps/loki`
ships, which points at `loki.loki.svc.cluster.local`. Replace `changeme` with the
namespace of your own Loki. Keep `apps/loki` under `resources:`, because a patch with no
target fails the build.

### Storage

Grafana OSS keeps users, sessions and annotations in SQLite under `/var/lib/grafana`.
Without a volume, every restart loses them. Dashboards and datasources survive either way,
because the Grafana Operator reconciles them from their own objects.

Copy `k8s-pvc-grafana.yaml` and `grafana-instance.yaml` together. The first is a 2Gi
`ReadWriteOnce` claim named `grafana`. The second mounts it and sets the deployment
strategy to `Recreate`. Replace the `changeme` storage class in the claim, and keep
`stack` under `resources:`.

`Recreate` is required, not a preference. The volume is `ReadWriteOnce`, so a rolling
update deadlocks. The new pod cannot mount the volume while the old one still holds it.
The cost is a short outage on every update.

Grafana also reads its state from an external PostgreSQL or MySQL database, through the
`GF_DATABASE_*` variables. That removes the volume, the `Recreate` strategy and the single
replica limit. This release ships nothing for it yet. To use it, set those variables in
the `grafana-env` secret and copy neither file.

### Single sign-on

Copy `eso-css.yaml` and `eso-es-grafana-env.yaml` together. They fill the `grafana-env`
secret that the instance already loads with `envFrom`, and they turn on Azure AD single
sign-on. Without them, Grafana starts with the local login form and the admin credentials
that the Grafana Operator generates.

You need the External Secrets Operator with its CRDs, and the `akv-eso-creds` secret in
the `external-secrets` namespace. You also need an Azure Key Vault, and an app
registration for Grafana.

`eso-css.yaml` is a `ClusterSecretStore` named `akv-metrics-stack`, scoped to the
`monitoring` namespace. It authenticates as a service principal, reading its credentials
from `akv-eso-creds`. It is the only file of the release that declares that store, and
`stack/alertmanager/examples/eso-es-msteams-webhook-url-azurekv.yaml` reads from it, so
copy `eso-css.yaml` once and share it. Replace its `tenantId` and the host part of its
`vaultUrl`.

`eso-css.yaml` is cluster-scoped. Kustomize does not know the scope of a custom resource,
so a `namespace:` in the kustomization that lists it writes a namespace into the object.
Set no `namespace:` there. `eso-es-grafana-env.yaml` carries `namespace: monitoring` in
its own metadata instead.

`eso-es-grafana-env.yaml` collects every vault secret whose name starts with `GF-`. It
rewrites each `-` into a `_`, because an Azure Key Vault name cannot hold a `_`. So
`GF-AUTH-AZUREAD-CLIENT-ID` in the vault becomes `GF_AUTH_AZUREAD_CLIENT_ID` in the
secret. Create these secrets in the vault. The file supplies every other Azure AD setting.

| Vault secret | Becomes |
|---|---|
| `GF-AUTH-AZUREAD-ALLOWED-GROUPS` | the group object IDs allowed to sign in |
| `GF-AUTH-AZUREAD-ALLOWED-ORGANIZATIONS` | the tenant IDs allowed to sign in |
| `GF-AUTH-AZUREAD-AUTH-URL` | the authorize endpoint of the app registration |
| `GF-AUTH-AZUREAD-TOKEN-URL` | the token endpoint of the app registration |
| `GF-AUTH-AZUREAD-CLIENT-ID` | the application ID |
| `GF-AUTH-AZUREAD-CLIENT-SECRET` | the client secret |
| `GF-SERVER-ROOT-URL` | the public URL of this Grafana |

## Configuration via Environment Variables

The Grafana instance loads a Secret named `grafana-env` as environment variables. Use this to override any Grafana configuration option:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: grafana-env
  namespace: monitoring
stringData:
  GF_AUTH_ANONYMOUS_ENABLED: "true"
```

See the [Grafana environment variable docs](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#override-configuration-with-environment-variables) for available options.

## Automatic Restart on Config Change

When the `grafana-env` Secret changes, Grafana restarts and picks up the new configuration. The Grafana deployment carries the annotation that [Stakater Reloader](https://github.com/stakater/Reloader) watches, so Reloader must run in the cluster.

## Limitations

- Not configured for more than 1 replica (Grafana OSS limitation with SQLite).
- Use Day 2 overlays to add resource limits or persistent storage customizations.
