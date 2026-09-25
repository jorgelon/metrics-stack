# examples

Manifests to copy into your own source. This directory is not a Kustomize component and
carries no `kustomization.yaml`. Nothing here is rendered by the release.

| File | What it does |
|---|---|
| `gapi-httproute.yaml` | Exposes Karma through a Gateway API gateway |
| `k8s-cm-karma-config.yaml` | Opens Karma on the active alerts that go to Microsoft Teams |

## gapi-httproute.yaml

One `HTTPRoute` that sends every path of one hostname to the `karma` Service on port 8080.
Copy the file, replace four values, and list the copy under `resources:`.

| Field | Value |
|---|---|
| `parentRefs[0].name` | the name of your Gateway |
| `parentRefs[0].namespace` | the namespace of that Gateway |
| `parentRefs[0].sectionName` | the listener on that Gateway |
| `hostnames[0]` | the public hostname of Karma |

You need the Gateway API CRDs and a controller that implements them. You also need a
`Gateway` with a listener that accepts your hostname, and DNS pointing at that gateway.

Karma has no authentication of its own. It shows every firing alert to anyone who reaches
it, and it can silence alerts. Put it behind a gateway that authenticates, or keep the
hostname on an internal listener.

## k8s-cm-karma-config.yaml

A `ConfigMap` named `karma-config`. It holds the filters Karma applies at the moment
someone opens the page. A viewer can still clear them. The karma Deployment already reads
this ConfigMap with `envFrom`, marked optional, so adding the copy under `resources:` is
enough.

The example keeps the active alerts that reached the Microsoft Teams receiver:

```text
FILTERS_DEFAULT: "@state=active @receiver=monitoring/teams/teams"
```

`@state=active` hides the alerts that already resolved. `@receiver` keeps only the alerts
that reached one receiver, addressed as `<namespace>/<AlertmanagerConfig>/<receiver>`.

`monitoring/teams/teams` is the receiver that the release components
`stack/alertmanager/msteams-azurekv` and `msteams-awssm` create. If you use the `smtp`
component instead, the value is `monitoring/smtp/smtp`. If no receiver matches, Karma
opens on an empty page and shows no error.
