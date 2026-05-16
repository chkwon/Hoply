#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDKROOT_PATH="$(xcrun --sdk iphoneos --show-sdk-path)"

swiftc \
  -target arm64-apple-ios16.0 \
  -sdk "$SDKROOT_PATH" \
  -parse-as-library \
  -typecheck \
  "$ROOT"/ios/DocViewer/*.swift

swiftc \
  -target arm64-apple-ios16.0 \
  -sdk "$SDKROOT_PATH" \
  -parse-as-library \
  -typecheck \
  "$ROOT"/ios/DocViewerQuickLook/*.swift \
  "$ROOT"/ios/DocViewer/ViewerSchemeHandler.swift
