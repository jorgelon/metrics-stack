#!/usr/bin/env bash
set -euf -o pipefail

# Build and run kubernetes-mixin build in a container
# This avoids installing jsonnet tools on your local machine

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="kubernetes-mixin-builder"

# Detect container runtime (prefer docker, fallback to podman)
if command -v docker >/dev/null 2>&1; then
    CONTAINER_CMD="docker"
elif command -v podman >/dev/null 2>&1; then
    CONTAINER_CMD="podman"
else
    echo "Error: Neither docker nor podman found. Please install one of them."
    exit 1
fi

echo "Using container runtime: ${CONTAINER_CMD}"
echo "Building container image..."
${CONTAINER_CMD} build -t "${IMAGE_NAME}" "${SCRIPT_DIR}"

echo ""
echo "Running build in container..."
echo "The container will prompt you for the version to build."
echo ""

# Run container with current directory mounted and as current user
${CONTAINER_CMD} run --rm -it \
  --user "$(id -u):$(id -g)" \
  -v "${SCRIPT_DIR}:/workspace" \
  "${IMAGE_NAME}" \
  /build_from_source.sh

echo ""
echo "✅ Build complete!"
echo "Generated files are in ${SCRIPT_DIR}/releases/"
