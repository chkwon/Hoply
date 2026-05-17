# Changelog

All notable changes to Hoply are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The marketing version (e.g. `0.1.0`) tracks user-visible releases. The build
number (e.g. `(1)`) is monotonically incremented for every upload to App Store
Connect across all marketing versions.

## [Unreleased]

## [0.1.1] - 2026-05-17

### Internal
- Pipeline validation build. Exercises the Xcode Cloud workflow end-to-end with the version bump script and tag-triggered release. No user-visible changes from 0.1.0.

## [0.1.0] - 2026-05-16

### Added
- Initial App Store release: read-only HWP / HWPX document viewer.
- Open `.hwp` and `.hwpx` files via Files, Open-In, or the in-app document browser.
- Local rendering through a bundled `@rhwp/core` viewer inside `WKWebView`.
- Share original document or export as PDF.
- AirPrint support.
- Quick Look preview extension (`HoplyQuickLook`) for `.hwp` and `.hwpx` in Files and other system surfaces.

[Unreleased]: https://github.com/chkwon/Hoply/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/chkwon/Hoply/releases/tag/v0.1.1
[0.1.0]: https://github.com/chkwon/Hoply/releases/tag/v0.1.0
