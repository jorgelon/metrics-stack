# Grafana

Grafana instance managed by the Grafana Operator, with a Prometheus datasource pre-configured.

## Files

| File                        | Description                              |
|-----------------------------|------------------------------------------|
| `grafana-instance.yaml`     | Grafana CRD instance                     |
| `grafana-ds-prometheus.yaml`| Grafana datasource pointing to Prometheus|

The base declares no storage and no authentication. Add the directories below. They go in
different fields: `single-pvc` patches the Grafana instance, so it is a kustomize
component, and `azure-sso` patches nothing, so it is a plain kustomization.

## Add-ons

| Directory | Adds | Add under |
|---|---|---|
| [`single-pvc`](single-pvc/README.md) | A 2Gi volume for the SQLite database, mounted by one replica | `components:` |
| [`azure-sso`](azure-sso/README.md) | Azure AD single sign-on, read from Azure Key Vault | `resources:` |

```yaml
resources:
  - <release>/stack
  - <release>/stack/grafana/azure-sso
components:
  - <release>/stack/grafana/single-pvc
```

### single-pvc

Grafana OSS keeps users, sessions and annotations in SQLite under `/var/lib/grafana`.
Without a volume, every restart loses them. Dashboards and datasources survive either way,
because the Grafana Operator reconciles them from their own objects.

This component adds the claim, mounts it, and sets the deployment strategy to `Recreate`.
You must overlay `storageClassName`, which is `changeme`. Read its README.

Grafana also reads its state from an external PostgreSQL or MySQL database, through the
`GF_DATABASE_*` variables. That removes the volume and the single replica limit. This
release ships nothing for it yet.

### azure-sso

`azure-sso` fills the `grafana-env` secret that the instance already loads with `envFrom`.
It also declares the `akv-metrics-stack` store that the rest of the stack reads from. Its
README lists the sentinels and the vault contents.

Without it, Grafana starts with the local login form and the admin credentials the Grafana
Operator generates.

## Examples

[`examples/`](examples/README.md) holds manifests to copy into your own source. They are
examples, not components, so nothing references them:

| File | What it does |
|---|---|
| `gapi-httproute.yaml` | Exposes Grafana through a Gateway API gateway |
| `grafana-ds-loki.yaml` | Repoints the Loki datasource of `apps/loki` at another namespace |

The base creates no route, so Grafana is reachable only inside the cluster until you copy
the first one. Set `GF_SERVER_ROOT_URL` to the same hostname you put in it.

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
