#!/bin/bash


# This script downloads the specified release of the kubernetes-mixin from GitHub,
# unzips it, and places it in the appropriate directory for further use.
# Then generates prometheus alerts, rules and dashboards ready to be used by prometheus operator and grafana operator.

set -euf -o pipefail

GITHUB_ORG="kubernetes-monitoring"
GITHUB_REPO="kubernetes-mixin"

echo "Showing release tags"
curl -Ls "https://api.github.com/repos/${GITHUB_ORG}/${GITHUB_REPO}/tags" | jq -r ".[].name"
read -p "Tell me the release tag to be downloaded: " release


echo "Creating download directory"
rm -rf releases/${release}
mkdir -p releases/${release}

curl -fSsL https://github.com/kubernetes-monitoring/kubernetes-mixin/releases/download/$release/kubernetes-mixin-$release.zip -o releases/${release}/kubernetes-mixin-version-$release.zip

echo "Unzipping downloaded file"
unzip -q releases/${release}/kubernetes-mixin-version-$release.zip -d releases/${release}

echo "Generating Grafana dashboard manifests"
DASHBOARDS_DIR="releases/${release}/dashboards_out"
OUTPUT_DIR="releases/${release}/dashboards"

mkdir -p "$OUTPUT_DIR"

if [ -d "$DASHBOARDS_DIR" ]; then
  find "$DASHBOARDS_DIR" -maxdepth 1 -name "*.json" -type f | while read -r dashboard_json; do
    # Extract filename without path and extension
    dashboard_name=$(basename "$dashboard_json" .json)

    # Skip Windows dashboards
    if [[ "$dashboard_name" == *"windows"* ]]; then
      echo "Skipping Windows dashboard: $dashboard_name"
      continue
    fi

    # Read JSON content and escape for YAML
    dashboard_content=$(cat "$dashboard_json" | jq -c .)

    # Create Grafana dashboard manifest
    cat > "${OUTPUT_DIR}/grafana-db-${dashboard_name}.yaml" <<EOF
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: ${dashboard_name}
spec:
  instanceSelector:
    matchLabels:
      app.kubernetes.io/part-of: metrics-stack
  folder: kubernetes-mixin
  json: |
$(echo "$dashboard_content" | jq . | sed 's/^/    /')
EOF

    echo "Created grafana-db-${dashboard_name}.yaml"
  done

  echo "Creating kustomization.yaml in dashboards directory"
  cd "$OUTPUT_DIR"
  kustomize create --autodetect
  cd - > /dev/null
else
  echo "Warning: Dashboards directory not found: $DASHBOARDS_DIR"
fi

echo "Generating PrometheusRule manifest"
PROMETHEUS_RULES_FILE="releases/${release}/prometheus_rules.yaml"
PROM_RULE_OUTPUT="releases/${release}/prom-rule.yaml"

if [ -f "$PROMETHEUS_RULES_FILE" ]; then
  # Use yq to normalize the YAML and remove quotes
  cat > "$PROM_RULE_OUTPUT" <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kubernetes-mixin
spec:
$(yq -P '.' "$PROMETHEUS_RULES_FILE" | sed 's/^/  /')
EOF
  echo "Created prom-rule.yaml"
else
  echo "Warning: Prometheus rules file not found: $PROMETHEUS_RULES_FILE"
fi

echo "Creating kustomization.yaml in release directory"
RELEASE_DIR="releases/${release}"
cd "$RELEASE_DIR"
cat > kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - prom-rule.yaml
  - dashboards
EOF
cd - > /dev/null
echo "Created kustomization.yaml in ${RELEASE_DIR}"

echo "Testing kustomize build"
kustomize build "$RELEASE_DIR" > /dev/null
echo "Kustomize build successful"

echo "Cleaning up temporary files"
rm -rf "${RELEASE_DIR}/kubernetes-mixin-version-${release}.zip"
rm -rf "${RELEASE_DIR}/dashboards_out"
echo "Cleanup complete"

