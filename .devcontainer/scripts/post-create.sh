#!/usr/bin/env bash
set -euo pipefail

echo "[devcontainer] Running post-create script"

# Ensure Gradle wrapper exists
if [ -f ./gradlew ]; then
  echo "[devcontainer] Gradle wrapper present."
  chmod +x gradlew || true
  ./gradlew --version || true
else
  echo "[devcontainer] WARNING: gradlew not found. Use Gradle Wrapper to build."
fi

# Run optional workspace setup scripts (non-fatal)
if [ -f "scripts/create-issues.sh" ]; then
  echo "[devcontainer] Running workspace scripts/create-issues.sh"
  bash "scripts/create-issues.sh" || true
fi

echo "[devcontainer] Post-create complete"
