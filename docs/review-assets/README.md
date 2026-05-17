# review-assets/

App Store 심사팀이 Hoply를 동작시키는 데 사용할 샘플 문서가 이 디렉터리에 들어간다.

## 필요한 파일

- `sample.hwp` — 한컴오피스 `.hwp` 파일. **사용자가 직접 추가해야 한다.** (Hancom 바이너리 포맷이라 자동 생성 불가)

## 권장 사양

- 가벼울 것: 100KB 이하 추천. 심사팀이 다운로드해서 바로 열어볼 수 있도록.
- 평범한 한국어 텍스트 + 약간의 서식(제목, 본문, 표 1개 정도). 비밀이나 개인정보가 들어 있지 않을 것.
- 직접 만든 새 문서 또는 공개 도메인 샘플을 사용한다. 저작권 문제가 있는 문서는 피한다.

## 공개 URL

이 폴더의 파일은 GitHub Pages에서 다음 경로로 노출된다.

```
https://www.chkwon.net/Hoply/review-assets/sample.hwp
```

이 URL은 `docs/app-store-listing.md`의 **App Review Information → Review Notes**에 포함되어 있으므로, 새 버전을 제출할 때마다 재업로드하지 않아도 같은 링크를 재사용할 수 있다.

## 작업 순서

1. 위 권장 사양에 맞는 `.hwp` 파일을 만들거나 준비한다.
2. 이 폴더로 복사한다: `cp /path/to/your.hwp docs/review-assets/sample.hwp`
3. 커밋하고 push: `git add docs/review-assets/sample.hwp && git commit -m "docs: add sample.hwp for App Review" && git push`
4. GitHub Pages 빌드가 끝난 뒤 `curl -sI https://www.chkwon.net/Hoply/review-assets/sample.hwp`가 `HTTP/2 200`을 반환하는지 확인한다.

`.hwpx` 샘플도 함께 두고 싶다면 같은 절차로 `sample.hwpx`를 추가해도 좋다(필수는 아님; `.hwp` 하나로 충분).
