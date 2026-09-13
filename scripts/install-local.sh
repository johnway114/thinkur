#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="/tmp/thinkur-local-build"
DEST_PATH="/Applications/thinkur.app"
BACKUP_PATH="/Applications/thinkur.app.bak"

echo "==> Generating Xcode project..."
cd "$PROJECT_DIR"
xcodegen generate

echo "==> Building thinkur Release (arm64)..."
xcodebuild -quiet -project thinkur.xcodeproj -scheme thinkur \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath "$BUILD_DIR" \
  ARCHS=arm64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_ALLOWED=NO build

BUILT_APP="$BUILD_DIR/Build/Products/Release/thinkur.app"

echo "==> Signing app locally (ad-hoc with audio input entitlements)..."
codesign --force --deep --sign - \
  --entitlements "$PROJECT_DIR/Sources/thinkur/Resources/thinkur.entitlements" \
  "$BUILT_APP"

echo "==> Stopping currently running thinkur..."
if pgrep -x "thinkur" >/dev/null 2>&1; then
    killall "thinkur" 2>/dev/null || true
    sleep 1
fi

if [ -d "$DEST_PATH" ]; then
    echo "==> Backing up current /Applications/thinkur.app to /Applications/thinkur.app.bak..."
    rm -rf "$BACKUP_PATH"
    cp -R "$DEST_PATH" "$BACKUP_PATH"
    rm -rf "$DEST_PATH"
fi

echo "==> Installing new build to /Applications/thinkur.app..."
ditto "$BUILT_APP" "$DEST_PATH"

echo "==> Launching updated thinkur..."
open "$DEST_PATH"

echo "==> Successfully installed and launched thinkur!"
