# App Store Listing — Hoply 0.1.1+

App Store Connect 텍스트 필드 원본 모음. 기본은 한국어 로컬라이제이션이고, App Store 검색성을 위해 English (U.S.) 로컬라이제이션도 함께 관리한다. 각 항목은 그대로 복사·붙여넣기 할 수 있도록 코드 펜스로 감쌌다. 글자수/byte 제한은 항목마다 표기.

업데이트 절차: 본문 변경 시 이 파일을 먼저 고치고, 그 텍스트를 App Store Connect에 반영한다. 그래야 다음 릴리스 때 원본이 어디 있었는지 헷갈리지 않는다.

ASO 원칙:
- App Store 검색은 앱 이름, 부제, 키워드, 카테고리의 텍스트 관련성과 다운로드/평점/리뷰 같은 사용자 신호를 함께 본다.
- 키워드는 100 bytes 제한이며 쉼표 뒤 공백을 넣지 않는다.
- 앱 이름/부제/카테고리에 이미 들어간 단어는 키워드에 반복하지 않는다.
- Promotional Text는 검색 순위에 직접 반영되지 않으므로 전환용 문구로만 쓴다.

---

## Korean Localization

### App Name (30자)

홈 화면 아이콘 라벨은 `Info.plist`의 `CFBundleDisplayName="Hoply"`에서 오므로, 스토어 이름과 무관하게 기기 위에선 항상 "Hoply"로 보인다. 스토어 이름에는 기능 키워드를 함께 넣어 `Hoply` 단독 검색과 `HWP/HWPX` 목적 검색을 같이 노린다.

```
Hoply - HWP/HWPX 뷰어
```

### Subtitle (30자)

```
한글 문서 열람·PDF 공유
```

### Promotional Text (170자, 재심사 없이 수정 가능)

```
.hwp · .hwpx 문서를 기기 안에서 바로 열어보세요. 외부 서버 전송 없이 로컬에서 렌더링하고, 원본·PDF 공유와 인쇄까지 지원합니다. Files와 Quick Look에도 통합됩니다.
```

### Description (4,000자)

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

### Keywords (100 bytes, 쉼표 사이 공백 없음)

```
한글파일,파일열기,오프라인,인쇄,미리보기,아이패드,아이폰,리더
```

---

## English (U.S.) Localization

US App Store에는 같은 이름의 다른 앱이 있으므로, English (U.S.) 메타데이터는 브랜드 단독 검색보다 `HWP viewer`, `HWPX viewer`, `Korean document reader` 목적 검색에 맞춘다.

### App Name (30 chars)

```
Hoply - HWP/HWPX Viewer
```

### Subtitle (30 chars)

```
Private Korean docs reader
```

### Promotional Text (170 chars, editable without a new app submission)

```
Open .hwp and .hwpx files privately on iPhone and iPad. Hoply renders documents on-device, with PDF sharing, AirPrint, and Quick Look previews.
```

### Description (4,000 chars)

```
Open HWP and HWPX files on iPhone and iPad. Hoply is a private, read-only document viewer for Korean office documents, with PDF sharing, AirPrint, and Quick Look support.

Key features
• HWP / HWPX viewing: Open documents from Files or from another app's share menu.
• PDF sharing: Export a document as PDF through the standard iOS share sheet.
• AirPrint: Print documents directly with compatible printers.
• Quick Look previews: Preview .hwp and .hwpx files from Files and other system surfaces.
• Offline by design: Hoply performs no network requests of its own. Documents are rendered on the device.

Privacy-first design
• Read-only: Hoply focuses on viewing documents and does not edit or modify your original files.
• No tracking: No analytics, advertising, or tracking SDKs are included.
• No account: There is no sign-in, account, or user identifier.
• No data collection: See the privacy policy for details.

Technology
Hoply is built on @rhwp/core, an open-source HWP / HWPX rendering library. The parser and renderer are bundled with the app at build time. Hoply does not download executable code at runtime.

Compatibility
• iOS 16.0 or later
• iPhone and iPad
• Some complex office features, such as macros or advanced table formatting, may be unsupported or simplified.

Support
• Email: chkwon@gmail.com
• Bugs and feature requests: https://github.com/chkwon/Hoply/issues

Hoply is an independent product and is not affiliated with, endorsed by, or sponsored by Hancom Inc. "HWP", "HWPX", "Hancom", and related names may be trademarks of their respective owners.
```

### Keywords (100 bytes, comma-separated with no spaces)

```
hangul,office,file,offline,print,preview,pdf,iphone,ipad
```

---

## What's New in This Version — 0.1.0 (4,000자)

```
첫 App Store 릴리스입니다.
• .hwp · .hwpx 문서를 기기에서 로컬로 렌더링합니다.
• 파일 앱과 "다른 앱에서 열기"에서 바로 열 수 있습니다.
• 원본·PDF 공유와 AirPrint 인쇄를 지원합니다.
• Quick Look 확장으로 Files 등에서 미리 보기가 가능합니다.
```

---

## URLs

ASC에 입력하는 URL은 위 세 가지(Support / Marketing / Privacy Policy). EN privacy URL은 ASC에 입력하지 않고 비한국어 방문자 호의용으로 웹사이트에만 둔다.

| Field           | Value                                            |
|-----------------|--------------------------------------------------|
| Support URL     | `https://github.com/chkwon/Hoply/issues`         |
| Marketing URL   | `https://www.chkwon.net/Hoply/`                  |
| Privacy Policy  | `https://www.chkwon.net/Hoply/privacy-policy.html` |
| (웹사이트 보존용, ASC 미사용) | `https://www.chkwon.net/Hoply/privacy-policy.en.html` |

---

## App Information

| Field                   | Value                              |
|-------------------------|------------------------------------|
| Bundle ID               | `com.chkwon.Hoply`                 |
| Primary Language        | Korean                             |
| Primary Category        | Productivity                       |
| Secondary Category      | Utilities                          |
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

**Review Notes** (paste verbatim — App Review 담당자는 영어로 읽으므로 노트는 영어로 유지):

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

## App Store Tags

US App Store의 App Tags는 App Store Connect 메타데이터와 Apple의 분류에 기반해 생성된다. App Store Connect → App Information → App Store Tags에서 관련 없는 태그를 제거하고, 문서/뷰어/파일/생산성 계열 태그가 있으면 유지한다. 모든 태그를 끄면 발견 가능성에 불리할 수 있으므로 관련 태그만 선별한다.

---

## Screenshots

Required for first submission (2026 storefront):

| Device class     | Pixel size      | Required        |
|------------------|-----------------|-----------------|
| iPhone 6.9"      | 1290 × 2796     | **Required**    |
| iPad 13"         | 2064 × 2752     | **Required**    |
| iPhone 6.5"      | 1242 × 2688     | Optional fallback |
| iPad 12.9"       | 2048 × 2732     | Optional fallback |

ASO-oriented shot list (first three are most important in search results):

1. "Open HWP/HWPX files" — document list or Files handoff with `.hwp` / `.hwpx` examples.
2. "Private, offline viewing" — rendered Korean document, visually emphasizing local viewing.
3. "Share as PDF or print" — toolbar / share sheet showing PDF sharing and AirPrint.
4. Files app showing the Quick Look preview by the `HoplyQuickLook` extension.
5. Optional: iPad layout with a formatted document page.

Capture via Simulator: `Xcode → Open Developer Tool → Simulator`, pick the matching device, run Hoply, then `File → Save Screen` (or `⌘S`) inside Simulator. The resulting PNG is already at the correct pixel size.

---

## Search QA

After metadata changes are live, check App Store search and App Analytics weekly for:

- `Hoply`
- `Hoply HWP`
- `HWP viewer`
- `HWPX viewer`
- `한글 뷰어`
- `HWP 뷰어`

Track search impressions, product page views from search, conversion rate, rating count, and review quality. If brand search remains crowded in the US, run a small exact-match Apple Search Ads campaign for `Hoply`.
