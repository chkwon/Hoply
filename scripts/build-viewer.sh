#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT/web-viewer"
npm run build

echo "Viewer bundle written to $ROOT/AppResources/ViewerBundle"

