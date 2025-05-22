# Notes about applications

## CNPG

- In order to avoid duplicate metrics, disable the podmonitor in your clusters

```yaml
spec:
  monitoring:
    enablePodMonitor: false
```

- It assumes the operator is deployed in the cnpg-system namespace

- The default rules are located here

<https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/refs/heads/main/docs/src/samples/monitoring/prometheusrule.yaml>

## Quarkus

This stack does not create a service monitor or pod monitor because I can't standardize that. Create them outside this repo.
