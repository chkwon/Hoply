#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   scripts/bump-version.sh <marketing-version> [build-number]
#
# Examples:
#   scripts/bump-version.sh 0.2.0          # auto-increment build number
#   scripts/bump-version.sh 0.2.0 7        # set build number explicitly
#
# Updates the marketing version (semver) and build number in every
# location they live so they cannot drift:
#   - ios/Hoply.xcodeproj/project.pbxproj  (MARKETING_VERSION x4, CURRENT_PROJECT_VERSION x4)
#   - web-viewer/package.json              ("version" field)
#
# The two Info.plist files inherit from $(MARKETING_VERSION) and
# $(CURRENT_PROJECT_VERSION) at build time, so they need no rewrite.

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 <marketing-version> [build-number]" >&2
  exit 2
fi

MARKETING="$1"
BUILD="${2:-}"

if ! [[ "$MARKETING" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: marketing version '$MARKETING' must be X.Y.Z (semver)." >&2
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PBXPROJ="$ROOT/ios/Hoply.xcodeproj/project.pbxproj"
WEB_PKG="$ROOT/web-viewer/package.json"

if [ ! -f "$PBXPROJ" ]; then
  echo "Error: $PBXPROJ not found." >&2
  exit 1
fi

CURRENT_MARKETING="$(grep -m1 -E 'MARKETING_VERSION = [^;]+;' "$PBXPROJ" | sed -E 's/.*MARKETING_VERSION = ([^;]+);.*/\1/')"
CURRENT_BUILD="$(grep -m1 -E 'CURRENT_PROJECT_VERSION = [^;]+;' "$PBXPROJ" | sed -E 's/.*CURRENT_PROJECT_VERSION = ([^;]+);.*/\1/')"

if [ -z "$BUILD" ]; then
  if ! [[ "$CURRENT_BUILD" =~ ^[0-9]+$ ]]; then
    echo "Error: cannot auto-increment; current CURRENT_PROJECT_VERSION '$CURRENT_BUILD' is not numeric." >&2
    exit 1
  fi
  BUILD=$((CURRENT_BUILD + 1))
fi

if ! [[ "$BUILD" =~ ^[0-9]+$ ]]; then
  echo "Error: build number '$BUILD' must be a positive integer." >&2
  exit 2
fi

echo "Bumping:"
echo "  MARKETING_VERSION       $CURRENT_MARKETING -> $MARKETING"
echo "  CURRENT_PROJECT_VERSION $CURRENT_BUILD -> $BUILD"
echo

# macOS sed requires '' as the empty backup-suffix argument.
sed -i '' -E "s/(MARKETING_VERSION = )[^;]+;/\1${MARKETING};/g" "$PBXPROJ"
sed -i '' -E "s/(CURRENT_PROJECT_VERSION = )[^;]+;/\1${BUILD};/g" "$PBXPROJ"

MARKETING_HITS="$(grep -c "MARKETING_VERSION = ${MARKETING};" "$PBXPROJ" || true)"
BUILD_HITS="$(grep -c "CURRENT_PROJECT_VERSION = ${BUILD};" "$PBXPROJ" || true)"

if [ "$MARKETING_HITS" -ne 4 ] || [ "$BUILD_HITS" -ne 4 ]; then
  echo "Error: expected 4 MARKETING_VERSION and 4 CURRENT_PROJECT_VERSION rewrites, got" \
       "$MARKETING_HITS / $BUILD_HITS. The pbxproj layout may have changed; aborting." >&2
  exit 1
fi

if [ -f "$WEB_PKG" ]; then
  (cd "$ROOT/web-viewer" && npm version "$MARKETING" --no-git-tag-version --allow-same-version >/dev/null)
fi

TAG="v${MARKETING}-${BUILD}"
echo "Updated $PBXPROJ (8 lines) and $WEB_PKG."
echo
echo "Next steps:"
echo "  1. Update CHANGELOG.md with the entry for ${MARKETING} (build ${BUILD})."
echo "  2. Rebuild bundled viewer:  npm run build:viewer && npm run ios:typecheck"
echo "  3. Commit:                  git commit -am 'release: v${MARKETING} (build ${BUILD})'"
echo "  4. Tag:                     git tag ${TAG}"
echo "  5. Archive in Xcode and upload to App Store Connect."
