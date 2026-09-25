# single-pvc

One Prometheus replica, keeping 7 days of data on its own volume.

## Why this is needed

The base declares no replicas, no retention and no storage. Without this component the
operator runs one replica writing to an `emptyDir`, with the default retention, and every
restart loses the data.

This is the simple shape: one replica, local disk, no high availability, no long term
storage and no remote write. It is what every cluster we run uses today.

## What it does

- Sets `replicas: 1`.
- Sets `retention: 7d`.
- Adds a 100Gi `ReadWriteOnce` volume claim template.

## You must overlay the storage class

The claim template uses `storageClassName: changeme`. No cluster has a storage class by
that name, so you must overlay it. Until you do, the claim stays unbound and the pod stays
`Pending`. This is deliberate. A missing overlay fails loudly, instead of putting the time
series on whichever class happens to be the default.

```yaml
# overlays/prom-instance.yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: k8s
spec:
  storage:
    volumeClaimTemplate:
      spec:
        storageClassName: ebs-csi-gp3
```

100Gi holds 7 days on the production clusters. If your cluster needs more or less, patch
the size in the same place. The operator does not resize an existing claim, so a later
change needs the StatefulSet deleted with `--cascade=orphan`, or a new claim.

Size the prometheus container in the same patch. It is not sized anywhere else, because it
tracks the number of series the cluster produces.

```yaml
spec:
  resources:
    requests:
      cpu: 200m
    limits:
      memory: 3Gi
```

## Usage

```yaml
resources:
  - <release>/stack
components:
  - <release>/stack/prometheus/single-pvc
```

## The alternatives

This release ships no component for them yet.

- Two replicas for high availability. The operator supports it, and each replica keeps its
  own copy on its own volume. Alertmanager already deduplicates the alerts.
- Remote write to a long term store, such as Thanos or Mimir. Local retention then drops to
  a few hours and the volume shrinks with it.
