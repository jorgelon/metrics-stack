#!/bin/bash

set -e

HELM_REPO_URL="https://charts.enix.io"
HELM_REPO_NAME="enix"
CHART_NAME="x509-certificate-exporter"

echo "Fetching X.509 Certificate Exporter releases from $HELM_REPO_URL..."

helm repo add "$HELM_REPO_NAME" "$HELM_REPO_URL" --force-update >/dev/null 2>&1
helm repo update >/dev/null 2>&1

echo "Available versions for $CHART_NAME:"
echo
helm search repo "$HELM_REPO_NAME/$CHART_NAME" --versions | head -n 15

echo
read -r -p "Enter the version you want to use: " version

if [[ -z "$version" ]]; then
    echo "No version specified. Aborting."
    exit 1
fi
echo "Cleaning"

rm -rf "$version" "$version"-temp
mkdir "$version"-temp

# Check if values.yaml exists in the current directory
if [[ ! -f "values.yaml" ]]; then
    echo "Error: values.yaml file not found in the current directory."
    exit 1
fi

echo "Generating YAML files using helm template..."
helm template "$CHART_NAME" "$HELM_REPO_NAME/$CHART_NAME" --version "$version" --namespace monitoring -f values.yaml --output-dir "$version"-temp
echo "Moving generated files to $version directory..."
mv "$version"-temp/"$CHART_NAME"/templates "$version"

echo "Adding dashboard"
cat << EOF > "$version"/grafana-db-x509-certificate-exporter.yaml
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: x509-certificate-exporter
spec:
  instanceSelector:
    matchLabels:
      app.kubernetes.io/part-of: metrics-stack
  grafanaCom:
    id: 13922
EOF

echo "Adding a kustomization.yaml file inside $version using kustomize" 
cd "$version"
kustomize create --autodetect .
echo "Checking"
kustomize build .

echo "Cleaning up temporary files..."
cd ..
rm -rf "$version"-temp