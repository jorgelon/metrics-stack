#!/bin/bash

set -euf -o pipefail

echo "Showing release tags"
curl -s "https://api.github.com/repos/kubernetes-sigs/metrics-server/tags" | jq -r ".[].name"
read -p "Tell me the release tag to be downloaded: " release

echo "Cleaning ${release} directory"
rm -rf ${release}
mkdir -p ${release}

curl -fSlL https://github.com/kubernetes-sigs/metrics-server/releases/download/${release}/high-availability-1.21+.yaml -o ${release}/metrics-server.yaml

echo "Creating kustomization file from the yaml files inside the $release directory"
cat <<EOF >${release}/kustomization.yaml
resources:
  - metrics-server.yaml
labels:
  - pairs:
      app.kubernetes.io/name: metrics-server
      app.kubernetes.io/component: apiservice
EOF
