#!/bin/bash
set -euf -o pipefail

# Download node-exporter alerts from monitoring-mixins
ALERTS_URL="https://raw.githubusercontent.com/monitoring-mixins/website/refs/heads/master/assets/node-exporter/alerts.yaml"
OUTPUT_FILE="prom-rule-node-exporter.yaml"

echo "Downloading node-exporter alerts..."

# Generate PrometheusRule manifest
cat > "$OUTPUT_FILE" <<'EOF'
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: node-exporter
  namespace: monitoring
spec:
EOF

# Download and append the groups section with proper indentation
curl -fsSL "$ALERTS_URL" | sed 's/^/  /' >> "$OUTPUT_FILE"

echo "PrometheusRule written to $OUTPUT_FILE"
