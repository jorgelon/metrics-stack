# Karma

Karma is a multi-Alertmanager dashboard for browsing and filtering alerts.

## How to deploy

This directory is a plain kustomization. It renders into the `monitoring` namespace.
List it under `resources:`. Read [DEPLOYING.md](../../../DEPLOYING.md) for the full
walkthrough. It reads a ConfigMap that you build from the example.

```yaml
resources:
  - <release>/addons/karma
```

## Files

| File                    | Description       |
|-------------------------|-------------------|
| `k8s-deploy-karma.yaml` | Karma Deployment  |
| `k8s-svc-karma.yaml`    | Karma Service     |

## Examples

`examples/` holds manifests to copy into your own source. The directory carries no
`kustomization.yaml`, so the release never renders it. Copy each file into your
`instance/` folder and list the copy under `resources:`.

| File | What it does | Copy into | List under |
|---|---|---|---|
| `gapi-httproute.yaml` | Exposes Karma through a Gateway API gateway | `instance/` | `resources:` |
| `k8s-cm-karma-config.yaml` | Opens Karma on the active alerts that go to Microsoft Teams | `instance/` | `resources:` |

### The route

`gapi-httproute.yaml` sends every path of one hostname to the `karma` Service on port
8080. Replace four values:

| Field | Value |
|---|---|
| `parentRefs[0].name` | the name of your Gateway |
| `parentRefs[0].namespace` | the namespace of that Gateway |
| `parentRefs[0].sectionName` | the listener on that Gateway |
| `hostnames[0]` | the public hostname of Karma |

You need the Gateway API CRDs and a controller that implements them. You also need a
`Gateway` with a listener that accepts your hostname, and DNS that points at that gateway.

Karma has no authentication of its own. It shows every firing alert to anyone who reaches
it, and it can silence alerts. Put it behind a gateway that authenticates, or keep the
hostname on an internal listener.

### The configuration

`k8s-cm-karma-config.yaml` is a `ConfigMap` named `karma-config`. It holds the filters
that Karma applies at the moment someone opens the page. A viewer can still clear them.
The Karma Deployment already reads this ConfigMap with `envFrom`, marked optional, so the
copy under `resources:` is enough.

The example keeps the active alerts that reached the Microsoft Teams receiver:

```text
FILTERS_DEFAULT: "@state=active @receiver=monitoring/teams/teams"
```

`@state=active` hides the alerts that already resolved. `@receiver` keeps the alerts of
one receiver only, addressed as `<namespace>/<AlertmanagerConfig>/<receiver>`.

`monitoring/teams/teams` is the receiver that `stack/alertmanager/msteams` creates. If you
copied `stack/alertmanager/examples/prom-amc-smtp.yaml` instead, the value is
`monitoring/smtp/smtp`. If no receiver matches, Karma opens on an empty page and shows no
error.

## Configuration

Karma connects to the Alertmanager instance in the `monitoring` namespace on its own. The
base creates no route, so copy the example above, or write your own Ingress.

## References

- [Karma](https://github.com/prymitive/karma)
