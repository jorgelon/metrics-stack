#!/bin/bash
set -euf -o pipefail

echo "Showing release tags"
curl -s "https://api.github.com/repos/prometheus-operator/prometheus-operator/tags" | jq -r ".[].name"
read -p "Tell me the release tag to be downloaded: " release

echo "(Re)creating ${release} folder"
rm -rf ${release}
mkdir ${release}

echo "Creating ${release} manifests"
curl -fSsL https://github.com/prometheus-operator/prometheus-operator/releases/download/${release}/bundle.yaml -o ${release}/bundle.yaml

cat <<EOF >${release}/kustomization.yaml
namespace: monitoring 
resources:
  - bundle.yaml
commonAnnotations:
  argocd.argoproj.io/sync-wave: "-5"
EOF
