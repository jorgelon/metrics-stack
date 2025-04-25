#!/bin/bash

set -euf -o pipefail

echo "Showing release tags"
curl -s "https://api.github.com/repos/kubernetes-sigs/prometheus-adapter/tags" | jq -r ".[].name"
read -p "Tell me the release tag to be downloaded: " release

echo "Cleaning ${release} directory"
rm -rf ${release} ${release}-tmp

echo "Cloning ${release}"
git clone --branch ${release} --depth 1 https://github.com/kubernetes-sigs/prometheus-adapter.git ${release}-tmp
mv ${release}-tmp/deploy/manifests ${release}

echo "Cleaning up"
rm -rf ${release}-tmp

echo "Creating kustomization file from the yaml files inside the $release directory"
cat <<EOF >${release}/kustomization.yaml
labels:
  - pairs:
      app.kubernetes.io/name: prometheus-adapter
      app.kubernetes.io/component: apiservice
resources:
EOF

find ${release}/ -type f -name "*.yaml" -not -name "kustomization.yaml" -printf "- %f\n" | sort >>${release}/kustomization.yaml
