# Grafana

## Configure via environment variables

The grafana instance loads the grafana-env secret as environment variables, so it is possible to configure it that way

<https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#override-configuration-with-environment-variables>

## Restart when this changes

The grafana deployment is configured to be restarted if that grafana-env changes using stakater reloader.
