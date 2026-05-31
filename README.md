<p align="center">
  <img src="ios/Hoply/Assets.xcassets/AppIcon.appiconset/Icon-1024.png" alt="Hoply logo" width="120">
</p>

<h1 align="center">Hoply</h1>

<p align="center">
  iPhone과 iPad에서 HWP / HWPX 문서를 여는 읽기 전용 뷰어
</p>

<p align="center">
  <a href="https://apps.apple.com/us/app/hoply/id6770157807"><strong>App Store에서 Hoply 받기</strong></a>
</p>

Hoply는 한컴오피스 문서 형식인 `.hwp`와 `.hwpx` 파일을 iOS 기기에서 빠르게 열어볼 수 있는 문서 뷰어입니다. 파일 앱이나 다른 앱의 공유 메뉴로 문서를 열고, 필요한 경우 원본이나 PDF로 다시 공유하거나 AirPrint로 인쇄할 수 있습니다.

## 주요 기능

- `.hwp` / `.hwpx` 문서 열람
- 파일 앱과 "다른 앱에서 열기" 지원
- Files 등에서 바로 미리 볼 수 있는 Quick Look 확장
- 원본 문서 공유와 PDF 공유
- AirPrint 인쇄
- iPhone / iPad 지원

## 조용한 문서 뷰어

Hoply는 읽기 전용 앱입니다. 문서를 편집하거나 원본 파일을 수정하지 않고, 문서를 보는 일에만 집중합니다.

문서는 기기 안에서 렌더링됩니다. 앱 자체는 계정, 로그인, 분석, 광고 SDK를 사용하지 않으며, 문서 내용을 외부 서버로 전송하지 않습니다. 공유나 인쇄처럼 사용자가 직접 선택한 동작은 iOS의 표준 시스템 기능을 통해 처리됩니다.

## 지원과 문의

- 버그 제보와 기능 제안: [GitHub Issues](https://github.com/chkwon/Hoply/issues)
- 개인정보 처리방침: [한국어](https://www.chkwon.net/Hoply/privacy-policy.html) / [English](https://www.chkwon.net/Hoply/privacy-policy.en.html)
- 문의: [chkwon@gmail.com](mailto:chkwon@gmail.com)

## 기반 기술

Hoply는 오픈소스 HWP / HWPX 렌더링 라이브러리인 [`@rhwp/core`](https://github.com/edwardkim/rhwp)를 앱 안에 번들해 사용합니다. App Store 빌드에서는 원격 서버로부터 실행 코드를 내려받지 않습니다.

"Hoply"라는 이름은 [HOP](https://github.com/golbin/hop)에 대한 오마주입니다. 이 앱의 코드는 HOP에서 가져오지 않았고, HOP에 의존하지도 않습니다.

본 앱은 Hancom Inc.와 제휴하거나 후원받은 제품이 아닙니다. "HWP", "HWPX", "Hancom" 등은 각 권리자의 상표입니다.

## 개발자 문서

빌드, 아이콘 재생성, 버전 관리, App Store 배포 절차는 [Development and Release](docs/development-and-release.md)를 참고하세요.
