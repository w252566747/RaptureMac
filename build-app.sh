#!/bin/zsh
set -euo pipefail
cd "$(dirname "$0")"
BUILD_DIR=".build/RaptureMac.app/Contents"
rm -rf .build
mkdir -p "$BUILD_DIR/MacOS" "$BUILD_DIR/Resources"
CLANG_MODULE_CACHE_PATH="$PWD/.module-cache" swiftc -O -framework AppKit -framework CoreGraphics -framework ScreenCaptureKit Sources/main.swift -o "$BUILD_DIR/MacOS/RaptureMac"
cp Resources/Info.plist "$BUILD_DIR/Info.plist"
cp Resources/RaptureMac.icns "$BUILD_DIR/Resources/RaptureMac.icns"
printf 'APPL????' > "$BUILD_DIR/PkgInfo"
xattr -cr .build/RaptureMac.app
codesign --force --sign - .build/RaptureMac.app
echo "Built: $(pwd)/.build/RaptureMac.app"
