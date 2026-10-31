#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ARCH="${1:-$(uname -m)}"
case "$ARCH" in arm64|x86_64|universal) ;; *) echo 'Usage: bash scripts/build.sh [arm64|x86_64|universal]' >&2; exit 2;; esac
APP="$ROOT/build/InstagramDock.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$ROOT/build/module-cache"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp Resources/detector.js Resources/layout.js "$APP/Contents/Resources/"
cp LICENSE "$APP/Contents/Resources/LICENSE.txt"
# Generate the camera icon used in the original private app.
xcrun swiftc -swift-version 5 -module-cache-path "$ROOT/build/module-cache" scripts/icon.swift -o build/make-icon -framework Cocoa
mkdir -p build/AppIcon.iconset
build/make-icon build/icon-1024.png
for SIZE in 16 32 128 256 512; do
  sips -z "$SIZE" "$SIZE" build/icon-1024.png --out "build/AppIcon.iconset/icon_${SIZE}x${SIZE}.png" >/dev/null
  DOUBLE=$((SIZE * 2))
  sips -z "$DOUBLE" "$DOUBLE" build/icon-1024.png --out "build/AppIcon.iconset/icon_${SIZE}x${SIZE}@2x.png" >/dev/null
done
if ! iconutil -c icns build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"; then
  build/make-icon --pack build/AppIcon.iconset "$APP/Contents/Resources/AppIcon.icns"
fi
compile() {
  xcrun swiftc -swift-version 5 -target "$1-apple-macosx13.0" -module-cache-path "$ROOT/build/module-cache" Sources/main.swift Sources/AboutWindowController.swift -o "build/InstagramDock-$1" -framework Cocoa -framework WebKit
}
if [ "$ARCH" = universal ]; then
  compile arm64
  compile x86_64
  lipo -create build/InstagramDock-arm64 build/InstagramDock-x86_64 -output "$APP/Contents/MacOS/InstagramDock"
else
  compile "$ARCH"
  cp "build/InstagramDock-$ARCH" "$APP/Contents/MacOS/InstagramDock"
fi
codesign --force --sign - "$APP"
codesign --verify --strict "$APP"
echo "Built: $APP ($ARCH, ad hoc signed, not notarized)"
