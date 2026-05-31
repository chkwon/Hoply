# Development and Release

Hoply 개발, 빌드, 릴리스 절차를 모아둔 문서입니다. 사용자에게 보이는 변경 사항은 `CHANGELOG.md`에 함께 기록합니다.

## 빌드

```bash
npm install
npm run build:viewer
npm run ios:typecheck
npm run ios:build
```

실기기 실행이나 App Store 서명 준비는 `ios/Hoply.xcodeproj`를 Xcode에서 열어 진행합니다.

## 아이콘 재생성

앱 아이콘과 HWP / HWPX 문서 아이콘은 Pillow로 코드에서 생성합니다.

```bash
python3 -m venv scripts/.icon-venv
scripts/.icon-venv/bin/pip install pillow
npm run build:icons
```

## rhwp 업데이트

```bash
npm run update:rhwp -- 0.7.11
```

이 스크립트는 `@rhwp/core` 버전을 고정하고, 웹 뷰어를 다시 빌드한 뒤 결과물을 `AppResources/ViewerBundle`로 복사합니다.

실행 가능한 뷰어 코드는 전부 앱에 번들됩니다. App Store 빌드에서는 원격 서버로부터 WASM / JS를 핫업데이트하지 않습니다.

## 버전 관리

마케팅 버전(semver, 예: `0.1.0`)과 빌드 번호(모든 App Store Connect 업로드를 통틀어 단조 증가)는 두 곳에 있습니다: `ios/Hoply.xcodeproj/project.pbxproj`의 `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`, 그리고 `web-viewer/package.json`의 `version`. 두 `Info.plist`는 `$(MARKETING_VERSION)` / `$(CURRENT_PROJECT_VERSION)` 치환자로 값을 받으므로 직접 수정할 필요가 없습니다.

다음 명령으로 모든 위치를 한 번에 올립니다.

```bash
npm run release:bump 0.2.0          # 빌드 번호 자동 증가
npm run release:bump 0.2.0 7        # 빌드 번호 명시
```

사용자에게 보이는 변경 사항은 `CHANGELOG.md`에 해당 버전 항목으로 기록합니다.

## App Store 배포

릴리스별 절차입니다. 자세한 변경 내역은 `CHANGELOG.md`를 참고합니다.

1. `npm run release:bump <new-version>` 실행 후 `CHANGELOG.md` 갱신.
2. `npm run build:viewer && npm run ios:typecheck`로 번들 뷰어를 갱신하고 Swift 소스를 점검.
3. `git commit -am "release: vX.Y.Z (build N)" && git tag vX.Y.Z-N && git push --follow-tags`.
4. `ios/Hoply.xcodeproj`를 Xcode에서 열고, 스킴 **Hoply**, 대상 **Any iOS Device (arm64)** 선택 후 **Product -> Archive**.
5. Organizer에서 **Validate App**을 먼저 돌리고, 통과하면 **Distribute App -> App Store Connect -> Upload**.
6. App Store Connect에서 빌드를 TestFlight에 추가해 실기기로 스모크 테스트한 뒤, 해당 버전을 심사에 제출.

리포지터리 바깥에서 한 번 준비해야 하는 항목: App Store Connect 앱 레코드와 번들 ID 등록(`com.chkwon.Hoply`, `com.chkwon.Hoply.QuickLook`), 개인정보 처리방침 URL, 스크린샷, "What's New" 문구, 그리고 심사팀이 열어볼 수 있는 샘플 `.hwp` 문서.
