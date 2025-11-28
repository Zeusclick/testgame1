#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
cd "$PROJECT_DIR"

SCHEME="CosmicCatch"
DESTINATION="platform=iOS Simulator,name=iPhone 15"

xcodebuild \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -configuration Release \
  clean build | xcbeautify

xcodebuild \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  test | xcbeautify
