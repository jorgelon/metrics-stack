# Grafana

Grafana instance managed by the Grafana Operator, with a Prometheus datasource pre-configured.
It runs one replica and keeps its SQLite database on a claim named `grafana`, which you
create from `examples/k8s-pvc-grafana.yaml`.

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough. The `stack` path already brings this directory in. Reference it alone only
to deploy this part without the rest.

```yaml
resources:
  - <release>/stack/grafana
images:
  - name: docker.io/grafana/grafana
    newTag: 13.1.3
```

The `images:` entry is required. Read "The Grafana version" below.

## Files

| File                        | Description                              |
|-----------------------------|------------------------------------------|
| `grafana-instance.yaml`     | Grafana CRD instance, with the volume of the `grafana` claim |
| `grafana-ds-prometheus.yaml`| Grafana datasource pointing to Prometheus|
| `kustomizeconfig-images.yaml` | Makes `images:` change `spec.version` of the Grafana |

The base mounts a claim but does not create it. It declares no authentication and no
route. The claim, the authentication and the route need a value that this repository
cannot know, so each one is an example to copy.

## Examples

`examples/` holds manifests to copy into your own source. The directory carries no
`kustomization.yaml`, so the release never renders it. Copy a file, replace every
`changeme`, and list the copy in your own kustomization. A patch goes into your
`overlays/` folder, and a resource goes into your `instance/` folder.

| File | What it does | Copy into | List under |
|---|---|---|---|
| `k8s-pvc-grafana.yaml` | The 2Gi claim that the instance mounts. Required | `instance/` | `resources:` |
| `gapi-httproute.yaml` | Exposes Grafana through a Gateway API gateway | `instance/` | `resources:` |
| `grafana-ds-loki.yaml` | Repoints the Loki datasource of `apps/loki` | `overlays/` | `patches:` |
| `azure-auth/k8s-cm-grafana-env.yaml` | The Azure AD settings that hold no secret | `instance/` | `resources:` |
| `eso-es-grafana-env-akv.yaml` | Every `GF-` secret of the vault, for example the Azure AD keys | `instance/` | `resources:` |

```yaml
resources:
  - <release>/stack
  - instance/k8s-pvc-grafana.yaml
  - instance/gapi-httproute.yaml
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
Dashboards and datasources survive a restart either way, because the Grafana Operator
reconciles them from their own objects.

The instance mounts the claim named `grafana` at that path. The release does not create
the claim, so copy `k8s-pvc-grafana.yaml` and replace its `changeme` storage class. If
you forget the copy, the Grafana pod stays `Pending`. The sentinel binds nothing, so a
forgotten replacement also leaves the pod `Pending`.

The instance sets the deployment strategy to `Recreate`. The volume is `ReadWriteOnce`,
so a rolling update deadlocks. The new pod cannot mount the volume while the old one
still holds it. The cost is a short outage on every update.

Do not patch the `Grafana` instance with a strategic merge patch that lists
`containers`. Kustomize has no schema for the custom resource, so it replaces the whole
list and drops the `envFrom` that loads `grafana-env`.

### Single sign-on

Copy three files and list all three under `resources:`. Together they turn on Azure AD
single sign-on. Without them, Grafana starts with the local login form and the admin
credentials that the Grafana Operator generates.

- `azure-auth/k8s-cm-grafana-env.yaml` is a ConfigMap named `grafana-env`. It holds the
  Azure AD settings that hold no secret and never change between clusters, such as the
  scopes and PKCE.
- `eso-es-grafana-env-akv.yaml` is an ExternalSecret that builds the Secret named
  `grafana-env` from every `GF-` secret of the vault.
- `stack/examples/eso-css.yaml` is the vault store that the whole stack shares. Read
  [the stack README](../README.md) for it.

You need the External Secrets Operator with its CRDs, and the `akv-eso-creds` secret in
the `external-secrets` namespace. You also need an Azure Key Vault, and an app
registration for Grafana.

The instance loads the ConfigMap and the Secret with `envFrom`. The Secret comes last, so
a key in both takes the value of the Secret. The ConfigMap and the ExternalSecret carry
`namespace: monitoring` in their own metadata, because the kustomization that lists the
cluster-scoped store can set no `namespace:`.

The ExternalSecret finds the vault secrets by the regular expression `^GF-(.*)$`. An
Azure Key Vault name cannot hold a `_`, so the ExternalSecret rewrites each `-` into a
`_`. So `GF-AUTH-AZUREAD-CLIENT-ID` in the vault becomes `GF_AUTH_AZUREAD_CLIENT_ID` in
the Secret. A new `GF-` vault secret reaches Grafana on the next refresh, with no change
to the file.

### Azure Key Vault secrets for Azure AD

Create these seven secrets in the vault before you deploy. The ConfigMap supplies every
other Azure AD setting. If one of them is missing, Grafana starts, but the Azure AD
login fails.

| Vault secret | Becomes | Value |
|---|---|---|
| `GF-AUTH-AZUREAD-CLIENT-ID` | `GF_AUTH_AZUREAD_CLIENT_ID` | the application ID of the app registration |
| `GF-AUTH-AZUREAD-CLIENT-SECRET` | `GF_AUTH_AZUREAD_CLIENT_SECRET` | a client secret of the app registration |
| `GF-AUTH-AZUREAD-AUTH-URL` | `GF_AUTH_AZUREAD_AUTH_URL` | `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/authorize` |
| `GF-AUTH-AZUREAD-TOKEN-URL` | `GF_AUTH_AZUREAD_TOKEN_URL` | `https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token` |
| `GF-AUTH-AZUREAD-ALLOWED-ORGANIZATIONS` | `GF_AUTH_AZUREAD_ALLOWED_ORGANIZATIONS` | the tenant IDs allowed to sign in |
| `GF-AUTH-AZUREAD-ALLOWED-GROUPS` | `GF_AUTH_AZUREAD_ALLOWED_GROUPS` | the group object IDs allowed to sign in |
| `GF-SERVER-ROOT-URL` | `GF_SERVER_ROOT_URL` | the public URL of this Grafana, the same hostname as the route |

Register `<GF_SERVER_ROOT_URL>/login/azuread` as a redirect URI of the app registration.
Read the [Grafana Azure AD guide](https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/azuread/)
for the app registration and the role mapping.

## The Grafana version

You must choose the Grafana version. The `images:` field of `kustomization.yaml` in this
directory sets the tag of `spec.version` in `grafana-instance.yaml` to the sentinel
`changeme`. Add an `images:` entry with a tag from
[Docker Hub](https://hub.docker.com/r/grafana/grafana/tags) to your own kustomization:

```yaml
images:
  - name: docker.io/grafana/grafana
    newTag: 13.1.3
```

If you forget the entry, the Grafana pod stays in `ImagePullBackOff`, because `changeme`
is no valid tag.

The Grafana Operator writes its own default into an empty `spec.version` once and never
changes it again, also after an operator upgrade. So this directory never leaves the field
empty. By default `images:` changes container images only. `kustomizeconfig-images.yaml`
adds `spec.version` of the Grafana to those fields, and `kustomization.yaml` lists it under
`configurations:`. Your kustomization inherits that configuration.

When you upgrade the Grafana Operator, compare your version with the default of the new
release on the [versioning page](https://grafana.github.io/grafana-operator/docs/versioning/).
Read the Grafana release notes before a major upgrade, because Grafana 12 removed Angular
panels.

## Configuration via Environment Variables

The Grafana instance loads a ConfigMap and a Secret, both named `grafana-env` and both optional, as environment variables. Put sensitive values in the Secret and the rest in the ConfigMap. Use them to override any Grafana configuration option:

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

When a Secret or a ConfigMap that the Grafana pod reads changes, Grafana restarts and picks up the new configuration. The `grafana-env` Secret is one of them. The Grafana deployment carries two annotations that [Stakater Reloader](https://github.com/stakater/Reloader) watches, so Reloader must run in the cluster.

`reloader.stakater.com/auto: "true"` tells Reloader to watch every Secret and ConfigMap that the pod reads. `reloader.stakater.com/rollout-strategy: "restart"` makes Reloader delete the pod instead of editing the pod template. The Grafana Operator owns the Deployment and reverts edits to it.

## Limitations

- Not configured for more than 1 replica (Grafana OSS limitation with SQLite).
- Use Day 2 overlays to add resource limits.
- To use an external PostgreSQL or MySQL database through the `GF_DATABASE_*` variables, remove the volume and the `Recreate` strategy with a JSON 6902 patch.
