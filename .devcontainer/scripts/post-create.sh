#!/usr/bin/env bash
set -euo pipefail

echo "[devcontainer] Running post-create script"

# If there are project-level setup scripts, run them (non-fatal)
if [ -f "scripts/create-issues.sh" ]; then
  echo "[devcontainer] Running workspace scripts/create-issues.sh"
  bash "scripts/create-issues.sh" || true
fi

echo "[devcontainer] Post-create complete"
#!/usr/bin/env bash
set -euo pipefail

echo "Running DevContainer post-create: ensure Gradle wrapper exists"

if [ -f ./gradlew ]; then
  echo "Gradle wrapper already present."
  ./gradlew --version || true
  exit 0
fi

if command -v gradle >/dev/null 2>&1; then
  echo "Found system 'gradle' — generating wrapper..."
  gradle wrapper
  chmod +x gradlew || true
  exit 0
fi

echo "Gradle not found. Installing via SDKMAN and generating wrapper..."
export SDKMAN_DIR="$HOME/.sdkman"
if [ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
  curl -s "https://get.sdkman.io" | bash
fi
# shellcheck source=/dev/null
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install gradle || true
gradle wrapper || true
chmod +x gradlew || true

echo "Gradle wrapper ensured."

exit 0
