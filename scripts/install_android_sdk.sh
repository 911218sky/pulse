#!/usr/bin/env bash
# Install Android SDK command-line tools + packages without Android Studio.
# Usage:
#   ./scripts/install_android_sdk.sh           # full (includes emulator)
#   ./scripts/install_android_sdk.sh --minimal # build + adb only
set -euo pipefail

MINIMAL=0
for arg in "$@"; do
  case "$arg" in
    --minimal|-m) MINIMAL=1 ;;
    -h|--help)
      echo "Usage: $0 [--minimal]"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Android/Sdk}}"
CMD_TOOLS_ZIP="${TMPDIR:-/tmp}/cmdline-tools-linux.zip"
EXTRACT_ROOT="${TMPDIR:-/tmp}/cmdline-tools-linux-extract"
CMD_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"
SDKMANAGER="$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"

ensure_cmdline_tools() {
  if [[ -x "$SDKMANAGER" ]]; then
    echo "cmdline-tools already installed at $SDKMANAGER"
    return
  fi

  echo "Downloading cmdline-tools..."
  rm -f "$CMD_TOOLS_ZIP"
  rm -rf "$EXTRACT_ROOT"
  curl -L --retry 5 --retry-delay 3 --connect-timeout 30 -o "$CMD_TOOLS_ZIP" "$CMD_TOOLS_URL"

  zip_size=$(wc -c <"$CMD_TOOLS_ZIP" | tr -d ' ')
  echo "Downloaded zip size: $((zip_size / 1024 / 1024)) MB"
  if (( zip_size < 50 * 1024 * 1024 )); then
    echo "Downloaded zip looks too small ($zip_size bytes)" >&2
    exit 1
  fi

  echo "Extracting cmdline-tools..."
  mkdir -p "$EXTRACT_ROOT"
  unzip -q "$CMD_TOOLS_ZIP" -d "$EXTRACT_ROOT"

  SOURCE_DIR="$EXTRACT_ROOT/cmdline-tools"
  if [[ ! -f "$SOURCE_DIR/bin/sdkmanager" ]]; then
    echo "Expected sdkmanager at $SOURCE_DIR/bin/sdkmanager" >&2
    exit 1
  fi

  TARGET_DIR="$SDK_ROOT/cmdline-tools/latest"
  rm -rf "$TARGET_DIR"
  mkdir -p "$TARGET_DIR"
  cp -a "$SOURCE_DIR"/. "$TARGET_DIR"/

  if [[ ! -x "$SDKMANAGER" ]]; then
    echo "Install verification failed: $SDKMANAGER missing" >&2
    exit 1
  fi

  echo "cmdline-tools installed successfully"
}

mkdir -p "$SDK_ROOT"
ensure_cmdline_tools

export ANDROID_HOME="$SDK_ROOT"
export ANDROID_SDK_ROOT="$SDK_ROOT"
export PATH="$SDK_ROOT/cmdline-tools/latest/bin:$SDK_ROOT/platform-tools:$SDK_ROOT/emulator:$PATH"

echo "Accepting SDK licenses..."
yes | sdkmanager --sdk_root="$SDK_ROOT" --licenses >/dev/null || true

PACKAGES=(
  platform-tools
  "platforms;android-35"
  "platforms;android-36"
  "build-tools;35.0.0"
  "build-tools;28.0.3"
)

if [[ "$MINIMAL" -eq 0 ]]; then
  PACKAGES+=(
    emulator
    "system-images;android-35;google_apis;x86_64"
  )
fi

echo "Installing SDK packages: ${PACKAGES[*]}"
sdkmanager --sdk_root="$SDK_ROOT" "${PACKAGES[@]}"

echo "Installed SDK components:"
ls -1 "$SDK_ROOT"

echo "sdkmanager location: $SDKMANAGER"
echo "adb location: $SDK_ROOT/platform-tools/adb"
if [[ -x "$SDK_ROOT/platform-tools/adb" ]]; then
  "$SDK_ROOT/platform-tools/adb" version
fi

echo
echo "Add to your shell profile:"
echo "  export ANDROID_HOME=\"$SDK_ROOT\""
echo "  export ANDROID_SDK_ROOT=\"\$ANDROID_HOME\""
echo "  export PATH=\"\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH\""
