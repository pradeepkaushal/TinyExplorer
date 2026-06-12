#!/usr/bin/env bash
set -euo pipefail

DEVICE_ID="${DEVICE_ID:-379bec90569f21e1756a03dd5bead260d6a0475a}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT="$PROJECT_DIR/TinyExplorers.xcodeproj"
TARGET="TinyExplorers"
CONFIG="Debug"
BUILD_DIR="$PROJECT_DIR/build/${CONFIG}-iphoneos"
APP="$BUILD_DIR/${TARGET}.app"

command -v ios-deploy >/dev/null || { echo "ios-deploy missing. Install: brew install ios-deploy"; exit 1; }

echo "==> Checking device $DEVICE_ID"
xcrun xctrace list devices 2>&1 | grep -q "$DEVICE_ID" || {
  echo "Device not connected. Plug in iPad, unlock, and trust this Mac."; exit 1;
}

echo "==> Building $TARGET ($CONFIG) for iphoneos"
xcodebuild \
  -project "$PROJECT" \
  -target "$TARGET" \
  -configuration "$CONFIG" \
  -sdk iphoneos \
  -allowProvisioningUpdates \
  CONFIGURATION_BUILD_DIR="$BUILD_DIR" \
  clean build >/dev/null

echo "==> Installing $APP on device"
ios-deploy --bundle "$APP" --id "$DEVICE_ID" --no-wifi

echo "==> Done"
