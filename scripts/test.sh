#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p build/module-cache
xcrun swiftc -swift-version 5 -module-cache-path "$ROOT/build/module-cache" Tests/test_detector.swift -o build/test-detector -framework JavaScriptCore
build/test-detector Resources/detector.js
