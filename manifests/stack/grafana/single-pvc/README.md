# single-pvc

Gives Grafana a persistent volume, so one replica keeps its state across restarts.

## Why this is needed

Grafana keeps users, sessions, annotations and starred dashboards in a database. Grafana
OSS defaults to SQLite in a file under `/var/lib/grafana`. Without a volume that file
lives in the container and every restart loses it.

Dashboards and datasources do not depend on this. The Grafana Operator reconciles them
from `GrafanaDashboard` and `GrafanaDatasource` objects on every start.

## What it does

- Adds a 2Gi `ReadWriteOnce` claim named `grafana`.
- Mounts it at `/var/lib/grafana`.
- Sets the deployment strategy to `Recreate`.

`Recreate` is required, not a preference. The volume is `ReadWriteOnce`, so a rolling
update deadlocks: the new pod cannot mount the volume while the old one still holds it.
The cost is a short outage on every update.

## You must overlay the storage class

`k8s-pvc-grafana.yaml` uses `storageClassName: changeme`. No cluster has a storage class
by that name, so you must overlay it. Until you do, the claim stays unbound and the pod
stays `Pending`. This is deliberate. A missing overlay fails loudly, instead of putting
the database on whichever class happens to be the default.

```yaml
# overlays/k8s-pvc-grafana.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana
spec:
  storageClassName: ebs-csi-gp3
```

2Gi holds the database and the plugin directory on every cluster we run. If your cluster
needs more, patch the size in the same place.

## Usage

```yaml
resources:
  - <release>/stack
components:
  - <release>/stack/grafana/single-pvc
```

## The alternative

Grafana also reads its state from an external PostgreSQL or MySQL database, through the
`GF_DATABASE_*` variables. That removes the volume, the `Recreate` strategy and the single
replica limit. This release does not ship a component for it yet. To use it, set those
variables in the `grafana-env` secret and do not add this component.
