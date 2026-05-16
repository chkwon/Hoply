#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <@rhwp/core-version>" >&2
  exit 2
fi

VERSION="$1"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT/web-viewer"
npm install "@rhwp/core@$VERSION" --save-exact
npm install
npm run build

echo "Updated @rhwp/core to $VERSION and rebuilt the iOS viewer bundle."

