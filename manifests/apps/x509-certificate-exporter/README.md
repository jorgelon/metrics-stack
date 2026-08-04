# x509 Certificate Exporter Monitoring

Helm-generated manifests for x509-certificate-exporter, which monitors TLS certificate expiry.

## Components

| File / Directory          | Description                                          |
|---------------------------|------------------------------------------------------|
| `values.yaml`             | Helm values used to generate manifests               |
| `generate-manifests.sh`   | Script to regenerate manifests from Helm values      |
| `3.19.1/`                 | Generated manifests for version 3.19.1               |
| `custom/`                 | Custom overrides                                     |

## CloudNative-PG False Positives

CloudNative-PG automatically renews its own certificates. This causes false positive alerts from x509-certificate-exporter. Suppress them by patching the PrometheusRule to exclude CNPG certificates:

```yaml
- alert: CertificateRenewal
  expr: (x509_cert_not_after - time()) < (28 * 86400)
        and x509_cert_not_after{secret_name!="cnpg-webhook-cert",subject_CN!="streaming_replica"}
- alert: CertificateExpiration
  expr: (x509_cert_not_after - time()) < (14 * 86400)
        and x509_cert_not_after{secret_name!="cnpg-webhook-cert",subject_CN!="streaming_replica"}
```

## Dashboard Sources

| File | Source |
|------|--------|
| `custom/grafana-db-x509-certificate-exporter.yaml` | [Grafana.com dashboard 13922](https://grafana.com/grafana/dashboards/13922) |

## References

- [x509-certificate-exporter](https://github.com/enix/x509-certificate-exporter)
