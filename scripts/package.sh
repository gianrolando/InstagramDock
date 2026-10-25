#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ARCH="${1:-universal}"
bash scripts/test.sh
bash scripts/build.sh "$ARCH"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)
STAGE=$(mktemp -d "$ROOT/build/release.XXXXXX")
trap 'rm -rf "$STAGE"' EXIT
cp -R build/InstagramDock.app "$STAGE/"
cp LICENSE "$STAGE/LICENSE.txt"
cp docs/INSTALLATION.txt "$STAGE/README.txt"
mkdir -p dist
ZIP="InstagramDock-${VERSION}-macOS-${ARCH}.zip"
(cd "$STAGE" && COPYFILE_DISABLE=1 /usr/bin/zip -q -r "$STAGE/$ZIP" InstagramDock.app LICENSE.txt README.txt)
mv "$STAGE/$ZIP" "$ROOT/dist/$ZIP"
(cd dist && shasum -a 256 "$ZIP" > "$ZIP.sha256")
echo "Release: dist/$ZIP"
