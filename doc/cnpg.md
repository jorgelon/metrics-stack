# CNPG

In order to avoid duplicate metrics, disable the podmonitor in your clusters

```yaml
spec:
  monitoring:
    enablePodMonitor: false
```

It assumes the operator is deployed in the cnpg-system namespace
