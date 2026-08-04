# Karma

Karma is a multi-Alertmanager dashboard for browsing and filtering alerts.

## Components

| File                    | Description       |
|-------------------------|-------------------|
| `k8s-deploy-karma.yaml` | Karma Deployment  |
| `k8s-svc-karma.yaml`    | Karma Service     |

## Configuration

Expose Karma via Ingress or Gateway API. Karma automatically connects to the Alertmanager instance in the `monitoring` namespace.

## References

- [Karma](https://github.com/prymitive/karma)
