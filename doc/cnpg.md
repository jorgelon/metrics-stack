# CNPG

In order to avoid duplicate metrics, disable the podmonitor in your clusters

```yaml
spec:
  monitoring:
    enablePodMonitor: false
```
