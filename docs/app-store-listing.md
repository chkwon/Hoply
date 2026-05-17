# App Store Listing — Hoply 0.1.0

App Store Connect 텍스트 필드 원본 모음. KR(Primary) + EN 두 가지 로컬라이제이션을 같이 둔다. 각 항목은 그대로 복사·붙여넣기 할 수 있도록 코드 펜스로 감쌌다. 글자수 제한은 항목마다 표기.

업데이트 절차: 본문 변경 시 이 파일을 먼저 고치고, 그 텍스트를 App Store Connect에 반영한다. 그래야 다음 릴리스 때 원본이 어디 있었는지 헷갈리지 않는다.

---

## App Name (30자 / 30 chars)

Same in both locales.

```
Hoply
```

---

## Subtitle (30자 / 30 chars)

**KR**
```
HWP · HWPX 문서 뷰어
```

**EN**
```
HWP / HWPX document viewer
```

---

## Promotional Text (170자 / 170 chars, 재심사 없이 수정 가능)

**KR**
```
.hwp · .hwpx 문서를 기기 안에서 바로 열어보세요. 외부 서버 전송 없이 로컬에서 렌더링하고, 원본·PDF 공유와 인쇄까지 지원합니다. Files와 Quick Look에도 통합됩니다.
```

**EN**
```
Open .hwp and .hwpx documents right on your device. Everything renders locally — no upload, no tracking — with original/PDF share and AirPrint. Integrated with Files and Quick Look.
```

---

## Description (4,000자 / 4,000 chars)

**KR**
```
Hoply는 한컴오피스(.hwp · .hwpx) 문서를 iOS 기기에서 빠르고 조용하게 열어볼 수 있는 개인용 뷰어 앱입니다. 모든 처리는 기기 안에서 이루어지며, 문서 내용은 어떤 외부 서버로도 전송되지 않습니다.

주요 기능
• .hwp · .hwpx 문서 렌더링: 파일 앱이나 다른 앱에서 "열기"로 받은 문서를 바로 표시합니다.
• PDF로 공유: 시스템 공유 시트를 통해 원본 또는 PDF로 변환된 문서를 다른 앱·메일·메시지로 보낼 수 있습니다.
• AirPrint 인쇄: 호환되는 프린터로 바로 인쇄할 수 있습니다.
• Quick Look 미리 보기: Files 등 시스템 곳곳에서 .hwp · .hwpx 파일을 미리 볼 수 있도록 Quick Look 확장 기능을 함께 제공합니다.
• 완전한 오프라인 동작: 앱 자체는 네트워크 통신을 하지 않습니다. 공유·인쇄처럼 사용자가 명시적으로 선택한 동작에서만 시스템 표준 기능이 동작합니다.

설계 원칙
• 읽기 전용: 문서 편집이나 수정 기능은 의도적으로 제공하지 않습니다. 뷰어로서 한 가지를 잘하는 데 집중합니다.
• 추적 없음: 분석·광고·추적 SDK가 포함되어 있지 않습니다.
• 데이터 미수집: 계정, 로그인, 사용자 식별자가 없습니다. 자세한 내용은 개인정보 처리방침을 참고하세요.

기반 기술
Hoply는 오픈소스 HWP / HWPX 렌더링 라이브러리인 @rhwp/core 위에 만들어졌습니다. 모든 파싱·렌더링 코드는 앱에 번들되어 함께 배포되며, 원격 서버로부터 코드를 내려받지 않습니다.

호환성
• iOS 16.0 이상
• iPhone, iPad 지원
• 일부 복잡한 한컴오피스 기능(매크로, 일부 고급 표 서식 등)은 표시되지 않거나 단순화되어 보일 수 있습니다.

문의
• 이메일: chkwon@gmail.com
• 버그 제보·기능 제안: https://github.com/chkwon/Hoply/issues

본 앱은 Hancom Inc.와 제휴·후원 관계가 없는 독립 제품입니다. "HWP", "HWPX", "Hancom" 등은 각 권리자의 상표입니다.
```

**EN**
```
Hoply is a personal viewer for Hancom Office (.hwp · .hwpx) documents on iOS. Everything happens on-device — document content is never sent to any external server.

Features
• Render .hwp · .hwpx documents handed off from the Files app or "Open In…"
• Share originals or PDFs via the system share sheet
• Print via AirPrint
• Quick Look preview extension so .hwp · .hwpx files preview wherever iOS shows them — Files, Mail, Messages, and more
• Fully offline: the app itself makes no network requests. Sharing and printing use Apple's standard system features and only when you choose them

Design principles
• Read-only by design — no editing, no save-as. The app does one thing and gets out of the way.
• No tracking — no analytics, advertising, or tracking SDKs.
• No data collection — no account, no sign-in, no identifiers. See the privacy policy for details.

Built on
Hoply is built on @rhwp/core, an open-source HWP / HWPX rendering library. All parsing and rendering code is bundled with the app; nothing is downloaded from a remote server at runtime.

Compatibility
• iOS 16.0 or later
• iPhone and iPad
• Some advanced Hancom Office features (e.g. macros, certain rich table styles) may not render fully and may be displayed in simplified form.

Contact
• Email: chkwon@gmail.com
• Bug reports and feature requests: https://github.com/chkwon/Hoply/issues

This app is an independent product and is not affiliated with, endorsed by, or sponsored by Hancom Inc. "HWP", "HWPX", and "Hancom" are trademarks of their respective owners.
```

---

## Keywords (100자 / 100 chars, 쉼표 사이 공백 없음)

**KR**
```
한컴,한글,HWP,HWPX,문서뷰어,한컴오피스,Hancom,오피스,파일,뷰어
```

**EN**
```
HWP,HWPX,Hancom,Korean,document,viewer,office,reader,file,quicklook
```

---

## What's New in This Version — 0.1.0 (4,000자 / 4,000 chars)

**KR**
```
첫 App Store 릴리스입니다.
• .hwp · .hwpx 문서를 기기에서 로컬로 렌더링합니다.
• 파일 앱과 "다른 앱에서 열기"에서 바로 열 수 있습니다.
• 원본·PDF 공유와 AirPrint 인쇄를 지원합니다.
• Quick Look 확장으로 Files 등에서 미리 보기가 가능합니다.
```

**EN**
```
Initial App Store release.
• Renders .hwp · .hwpx documents locally on-device.
• Opens from the Files app and "Open In…".
• Supports original/PDF share and AirPrint printing.
• Includes a Quick Look preview extension for .hwp · .hwpx files.
```

---

## URLs

| Field           | Value                                            |
|-----------------|--------------------------------------------------|
| Support URL     | `https://github.com/chkwon/Hoply/issues`         |
| Marketing URL   | `https://www.chkwon.net/Hoply/`                |
| Privacy Policy (KR primary) | `https://www.chkwon.net/Hoply/privacy-policy.html` |
| Privacy Policy (EN locale)  | `https://www.chkwon.net/Hoply/privacy-policy.en.html` |

---

## App Information

| Field                   | Value                              |
|-------------------------|------------------------------------|
| Bundle ID               | `com.chkwon.Hoply`                 |
| Primary Language        | Korean                             |
| Primary Category        | Productivity                       |
| Secondary Category      | (leave blank)                      |
| Content Rights          | "Does not contain, show, or access third-party content" |
| Age Rating              | 4+                                 |

Age rating questionnaire — choose "None" / "No" for every category (no violence, no sexual content, no profanity, no realistic violence, no drugs, no gambling, no unrestricted web access, no user-generated content).

---

## Pricing and Availability

- Price: **Free** (price tier 0).
- Availability: all territories (or limit to South Korea + your preferred storefronts).
- Pre-orders: off.

---

## App Privacy (Data collection questionnaire)

Top-level answer: **"No, we do not collect data from this app."**

This matches `ios/Hoply/PrivacyInfo.xcprivacy` (`NSPrivacyCollectedDataTypes = []`, `NSPrivacyTracking = false`).

---

## App Review Information

| Field            | Value                                              |
|------------------|----------------------------------------------------|
| First name       | Changhyun                                          |
| Last name        | Kwon                                               |
| Phone number     | (your number — App Store Connect requires one)     |
| Email            | `chkwon@gmail.com`                                 |
| Sign-in required | **No** (toggle off)                                |
| Demo account     | N/A                                                |

**Review Notes** (paste verbatim — bilingual; reviewers read English):

```
Hoply is a read-only HWP / HWPX document viewer. It performs no network requests of its own, stores no user data, and requires no sign-in.

To exercise the app:
1. Download the sample documents (both formats are supported):
   - HWP:  https://www.chkwon.net/Hoply/review-assets/sample.hwp
   - HWPX: https://www.chkwon.net/Hoply/review-assets/sample.hwpx
2. Open each in Files, then either:
   a) Tap to preview via Quick Look (uses the bundled HoplyQuickLook extension), or
   b) Long-press → "Share" → choose Hoply, or open with Hoply from "Open In…"
3. Inside Hoply, the document renders locally. The toolbar exposes Share (original / PDF) and Print (AirPrint).

Both samples are also attached to this review submission as a backup.

The app is built on the open-source @rhwp/core renderer
(https://github.com/edwardkim/rhwp), bundled at build time — no code is
downloaded at runtime.
```

**Attachment**: upload both `docs/review-assets/sample.hwp` and `docs/review-assets/sample.hwpx` directly via the App Review Information file uploader, as a fallback in case the GitHub Pages URL is unreachable during review.

---

## Export Compliance

Standard questionnaire answers, matching `ITSAppUsesNonExemptEncryption=false` in both `Info.plist` files:

| Question                                                                                          | Answer |
|---------------------------------------------------------------------------------------------------|--------|
| Does your app use encryption?                                                                     | **No** (the only crypto is HTTPS via Apple's stack, which is exempt) |

If App Store Connect routes you through the longer questionnaire, the equivalent answers are:
- Uses encryption: Yes
- Algorithms: only standard encryption (HTTPS / TLS) provided by the operating system
- Available outside the U.S. and Canada: Yes
- Qualifies for exemption: Yes

Either path lands on "no annual self-classification report required."

---

## Screenshots

Required for first submission (2026 storefront):

| Device class     | Pixel size      | Required        |
|------------------|-----------------|-----------------|
| iPhone 6.9"      | 1290 × 2796     | **Required**    |
| iPad 13"         | 2064 × 2752     | **Required**    |
| iPhone 6.5"      | 1242 × 2688     | Optional fallback |
| iPad 12.9"       | 2048 × 2732     | Optional fallback |

Suggested shot list (3–5 per device):

1. Document list (the in-app file browser) with a couple of sample files visible.
2. Rendered document — a Korean `.hwp` opened, scrolled to a page with some formatting.
3. Toolbar / share sheet open, showing "PDF로 공유 · Share as PDF".
4. Print preview (AirPrint sheet).
5. Files app showing the Quick Look preview by the `HoplyQuickLook` extension.

Capture via Simulator: `Xcode → Open Developer Tool → Simulator`, pick the matching device, run Hoply, then `File → Save Screen` (or `⌘S`) inside Simulator. The resulting PNG is already at the correct pixel size.
