# Hoply

Hoply is a personal iOS HWP / HWPX document viewer built around `@rhwp/core`.

The app is intentionally read-only. It opens `.hwp` and `.hwpx` documents from Files / Open In, renders them locally in a bundled `WKWebView`, and supports original/PDF sharing plus printing.

## Build

```bash
npm install
npm run build:viewer
npm run ios:typecheck
npm run ios:build
```

## Regenerating icons

The app icon and HWP / HWPX document icons are generated procedurally with Pillow:

```bash
python3 -m venv scripts/.icon-venv
scripts/.icon-venv/bin/pip install pillow
npm run build:icons
```

Open `ios/Hoply.xcodeproj` in Xcode to run on a device or prepare App Store signing.

## Updating rhwp

```bash
npm run update:rhwp -- 0.7.11
```

The update script pins `@rhwp/core`, rebuilds the web viewer, and copies the generated assets into `AppResources/ViewerBundle`.

All executable viewer code is bundled into the app. Do not hot-update WASM/JS from a remote server for App Store builds.
