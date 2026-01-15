#!/usr/bin/env bash
set -euf -o pipefail

# This script builds kubernetes-mixin from source with single-cluster configuration
# (removes cluster label requirement)

GITHUB_ORG="kubernetes-monitoring"
GITHUB_REPO="kubernetes-mixin"
BUILD_DIR="build"

# Check required tools
command -v jb >/dev/null 2>&1 || { echo "Error: jb (jsonnet-bundler) is required. Install with: go install -a github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest"; exit 1; }
command -v jsonnet >/dev/null 2>&1 || { echo "Error: jsonnet is required. Install with: go install github.com/google/go-jsonnet/cmd/jsonnet@latest"; exit 1; }
command -v yq >/dev/null 2>&1 || { echo "Error: yq is required. Install with: go install github.com/mikefarah/yq/v4@latest"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq is required. Install via apt: apt install jq"; exit 1; }
command -v kustomize >/dev/null 2>&1 || { echo "Error: kustomize is required. Install via apt: apt install kustomize"; exit 1; }

echo "Showing available tags"
curl -Ls "https://api.github.com/repos/${GITHUB_ORG}/${GITHUB_REPO}/tags" | jq -r ".[].name"
read -p "Tell me the release tag to be built: " release

VERSION="${release#version-}"  # Remove 'version-' prefix if present
RELEASE_DIR="releases/version-${VERSION}"

echo "Creating build directory"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Downloading kubernetes-mixin source (${release})"
curl -fSsL "https://github.com/${GITHUB_ORG}/${GITHUB_REPO}/archive/refs/tags/${release}.tar.gz" | tar xz --strip-components=1

echo "Creating jsonnetfile.json"
cat > jsonnetfile.json <<'EOF'
{
  "version": 1,
  "dependencies": [
    {
      "source": {
        "git": {
          "remote": "https://github.com/kubernetes-monitoring/kubernetes-mixin.git",
          "subdir": ""
        }
      },
      "version": "master"
    },
    {
      "source": {
        "git": {
          "remote": "https://github.com/grafana/grafonnet-lib.git",
          "subdir": "grafonnet"
        }
      },
      "version": "master"
    }
  ],
  "legacyImports": true
}
EOF

echo "Installing jsonnet dependencies"
jb install

echo "Creating multi-cluster mixin configuration with k8s_cluster label"
cat > mixin.jsonnet <<'EOF'
local mixin = import 'mixin.libsonnet';

mixin {
  _config+:: {
    // Use k8s_cluster instead of cluster to avoid conflicts with CNPG
    clusterLabel: 'k8s_cluster',

    // Keep multi-cluster features enabled
    showMultiCluster: false,
  }
}
EOF

echo "Creating alerts.jsonnet"
cat > alerts.jsonnet <<'EOF'
local mixin = import 'mixin.jsonnet';

mixin.prometheusAlerts
EOF

echo "Creating rules.jsonnet"
cat > rules.jsonnet <<'EOF'
local mixin = import 'mixin.jsonnet';

mixin.prometheusRules
EOF

echo "Creating dashboards.jsonnet"
cat > dashboards.jsonnet <<'EOF'
local mixin = import 'mixin.jsonnet';

{
  [name]: mixin.grafanaDashboards[name]
  for name in std.objectFields(mixin.grafanaDashboards)
}
EOF

echo "Generating Prometheus alerts"
jsonnet -J vendor alerts.jsonnet -o prometheus_alerts.json
yq eval -P prometheus_alerts.json > prometheus_alerts.yaml
rm prometheus_alerts.json

echo "Generating Prometheus rules"
jsonnet -J vendor rules.jsonnet -o prometheus_rules.json
yq eval -P prometheus_rules.json > prometheus_rules.yaml
rm prometheus_rules.json

echo "Generating Grafana dashboards"
mkdir -p dashboards_out
jsonnet -J vendor -m dashboards_out dashboards.jsonnet

cd ..

echo "Creating release directory"
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

echo "Copying generated files"
cp "$BUILD_DIR/prometheus_alerts.yaml" "$RELEASE_DIR/"
cp "$BUILD_DIR/prometheus_rules.yaml" "$RELEASE_DIR/"
cp -r "$BUILD_DIR/dashboards_out" "$RELEASE_DIR/"

echo "Generating Grafana dashboard manifests"
DASHBOARDS_DIR="${RELEASE_DIR}/dashboards_out"
OUTPUT_DIR="${RELEASE_DIR}/dashboards"

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

echo "Generating PrometheusRule manifests"
PROMETHEUS_RULES_FILE="${RELEASE_DIR}/prometheus_rules.yaml"
PROMETHEUS_ALERTS_FILE="${RELEASE_DIR}/prometheus_alerts.yaml"
PROM_RULE_RECORDING_OUTPUT="${RELEASE_DIR}/prom-rule-recording.yaml"
PROM_RULE_OUTPUT="${RELEASE_DIR}/prom-rule.yaml"

# Generate recording rules
if [ -f "$PROMETHEUS_RULES_FILE" ]; then
  cat > "$PROM_RULE_RECORDING_OUTPUT" <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kubernetes-mixin-recording
spec:
$(yq -P '.' "$PROMETHEUS_RULES_FILE" | sed 's/^/  /')
EOF
  echo "Created prom-rule-recording.yaml"
else
  echo "Warning: Prometheus rules file not found: $PROMETHEUS_RULES_FILE"
fi

# Generate alert rules
if [ -f "$PROMETHEUS_ALERTS_FILE" ]; then
  cat > "$PROM_RULE_OUTPUT" <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kubernetes-mixin
spec:
$(yq -P '.' "$PROMETHEUS_ALERTS_FILE" | sed 's/^/  /')
EOF
  echo "Created prom-rule.yaml"
else
  echo "Warning: Prometheus alerts file not found: $PROMETHEUS_ALERTS_FILE"
fi

echo "Creating kustomization.yaml in release directory"
cd "$RELEASE_DIR"
cat > kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - prom-rule.yaml
  - prom-rule-recording.yaml
  - dashboards
EOF
cd - > /dev/null
echo "Created kustomization.yaml in ${RELEASE_DIR}"

echo "Testing kustomize build"
kustomize build "$RELEASE_DIR" > /dev/null
echo "Kustomize build successful"

echo "Cleaning up"
rm -rf "${RELEASE_DIR}/dashboards_out"
rm -rf "$BUILD_DIR"
echo "Cleanup complete"

echo ""
echo "✅ Build complete!"
echo "Version: ${VERSION}"
echo "Output directory: ${RELEASE_DIR}"
echo ""
echo "Update the 'chosen' symlink with:"
echo "  cd releases && ln -sfn version-${VERSION} chosen"
echo ""
echo "Test with:"
echo "  kustomize build ${RELEASE_DIR}"
