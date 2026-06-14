# Codex Agent Notes

이 파일은 Codex 컨텍스트가 초기화됐을 때 가장 먼저 읽는다.

## 사용자 작업 원칙

- 작업 시작 시 저장소의 `*.md` 문서를 먼저 읽는다.
- 작업이 끝나면 실행한 작업을 정리한다.
- 가능하면 작업 종료 후 커밋, 푸시까지 진행한다.
- 작업 지시 외에도 이후 진행에 중요한 제약과 판단 근거를 이 파일에 남긴다.

## 현재 저장소 상태

- 현재 저장소는 문서 전용 상태가 아니라 Flutter 앱 구현본이다.
- 현재 작업 브랜치는 `feat/flutter-app-foundation`이다.
- 기준 문서:
  - `api-spec.md`
  - `docs/superpowers/specs/2026-06-12-flutter-app-design.md`
  - `docs/superpowers/plans/2026-06-12-flutter-app-foundation.md`

## 구현 완료 범위

- 인증:
  - 회원가입
  - 로그인
  - 세션 저장
  - 앱 시작 시 refresh + `GET /users/me`
  - 로그아웃
- 온보딩:
  - study profile
  - exam plan
  - subject scope
- 플랜 생성:
  - `POST /plan-generation-jobs`
  - `GET /plan-generation-jobs/{jobId}`
  - 진행 중 `jobId` 복구
- 메인 앱:
  - dashboard
  - today plan detail
  - today plan edit / toggle / complete
  - history
  - my page / study settings / notification settings / account settings

## 백엔드 연동 시 중요 계약 메모

- 앱은 mock 없이 실백엔드 연동 기준으로 작성됐다.
- `API_BASE_URL`은 필수다. 누락되면 앱 부트스트랩이 `StateError`로 종료된다.
- subject scope 저장 후 이를 다시 읽는 API가 현재 범위에 없다. 그래서 plan generation request는 subject scope 화면에서 들고 있는 메모리 입력값으로 즉시 만든다.
- plan generation request 매핑 가정:
  - `priority -> difficulty`
  - `priority == HIGH -> difficultSubjects`
  - `usualStudyHoursPerDay -> dailyMaxStudyHours`
- exam plan 저장 응답이 부분 필드만 돌려줄 수 있어서, 클라이언트는 기존 study profile 정보와 병합해 세션 스냅샷을 유지한다.
- `GET /users/me`에는 notification settings가 없다. 그래서 알림 설정 화면은 현재 서버 hydrate 없이 기본값으로 열리고 저장만 수행한다.
- 로그아웃 UX는 서버 응답보다 로컬 세션 정리를 우선한다.
- today plan edit 화면은 현재 `TodayPlan` route extra를 전제로 한다. 직접 deep link로 진입하면 fallback 화면이 나온다.

## 남은 리스크

- 실제 백엔드 응답이 `api-spec.md`와 다르면 DTO 파싱 수정이 필요할 수 있다.
- notification settings 조회 API가 생기기 전까지는 알림 설정 화면이 서버 현재값을 보여주지 못한다.
- subject scope 조회 API가 생기기 전까지는 subject scope 단계 재진입 복원력이 제한적이다.
- 현재 작업 경로가 `Desktop` 아래라서, iOS simulator 빌드 시 macOS File Provider xattr 때문에 기본 `build/` 출력 경로에서는 `resource fork, Finder information, or similar detritus not allowed` 에러가 날 수 있다.

## 2026-06-14 실행 검증 메모

- 현재 저장소 경로 `/Users/seongjun/Desktop/project/PlanIt-flutter`에서는 iOS simulator packaging이 File Provider xattr 때문에 실패한다.
- 동일 코드를 `/private/tmp/PlanIt-flutter-run`으로 복제한 뒤 아래 명령으로 재검증했다.
  - `flutter build ios --simulator --debug --dart-define=API_BASE_URL=http://localhost:8080`
  - `flutter run -d 6314C368-B770-4949-8A5A-EFC99DC3B498 --dart-define=API_BASE_URL=http://localhost:8080`
- 결과:
  - iOS simulator build 성공
  - iPhone 17 Pro simulator에서 앱 launch 성공
  - Dart VM Service attach 확인
- 이후 현재 워크스페이스 자체에서도 아래 방식으로 해결했다.
  - `build`를 `/private/tmp/PlanIt-flutter-build` symlink로 전환
  - stale 상태였던 `.dart_tool/flutter_build`를 비우고 다시 build
- 해결 후 현재 워크스페이스에서 확인한 명령:
  - `flutter build ios --simulator --debug --dart-define=API_BASE_URL=http://localhost:8080`
  - `flutter run -d 6314C368-B770-4949-8A5A-EFC99DC3B498 --dart-define=API_BASE_URL=http://localhost:8080`
- 결론: 앱 코드는 실행 가능 상태고, 현재 워크스페이스도 local build output을 `/private/tmp`로 빼면 정상 실행된다.
- 복구 팁:
  - `flutter clean`으로 `build` symlink가 사라지면 다시 `build -> /private/tmp/PlanIt-flutter-build`를 만들어야 한다.
  - symlink를 바꾼 직후 `native_assets` 관련 실패가 나면 `.dart_tool/flutter_build`를 비우고 다시 빌드한다.

## 2026-06-12 Flutter 스캐폴딩 메모

- Flutter 스캐폴딩을 시작했다.
- 이번 작업의 기준 문서는 `docs/superpowers/specs/2026-06-12-flutter-app-design.md`와 `docs/superpowers/plans/2026-06-12-flutter-app-foundation.md`다.
- 생성 직후 기본 템플릿은 카운터 앱이며, `lib/main.dart`와 `test/widget_test.dart`는 의도적으로 남겨 둔 임시 스캐폴드 기준 파일이다.
- `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`는 Flutter 기본 스캐폴드 상태를 기준으로 이후 Task 2에서 확장한다.

## 2026-06-12 Task 2 앱 파운데이션 메모

- Task 2에서는 앱 부트스트랩, 라우터 셸, 테마, 공통 로딩 뷰, 공통 예외 타입까지 최소 골격을 세운다.
- 현재 런타임 설정은 `--dart-define=API_BASE_URL=...`를 `AppRuntimeConfig`와 `ApiConfig`로 읽는 구조를 먼저 둔다.
- 이 단계의 라우트는 모두 placeholder이며 실제 인증/세션 분기 로직은 아직 넣지 않는다.
- 시작 검증 테스트는 `Splash` placeholder와 `"Preparing your study plan..."` 문구 노출 여부를 기준으로 한다.
- 다음 작업자가 컨텍스트를 복구할 때는 `lib/app/bootstrap/app_bootstrap.dart`, `lib/app/router/app_router.dart`, `lib/app/theme/app_theme.dart`부터 읽으면 현재 앱 진입 구조를 빠르게 파악할 수 있다.

## 다음 턴 시작 체크

- 컨텍스트 복구 시 `codex-notes.md`를 먼저 읽고, 그다음 이 파일을 읽는다.
- 그다음 `README.md`, `api-spec.md`, `docs/superpowers/specs/2026-06-12-flutter-app-design.md` 확인
- 작업 전에는 현재 브랜치 상태, `flutter analyze`, `flutter test` 기준 상태를 확인
- 핵심 진입 파일:
  - `lib/app/bootstrap/app_bootstrap.dart`
  - `lib/app/router/app_router.dart`
  - `lib/core/session/session_controller.dart`
  - `lib/features/plan_generation/presentation/pages/plan_generation_loading_page.dart`
  - `lib/features/dashboard/presentation/pages/home_page.dart`
  - `lib/features/history/presentation/pages/history_page.dart`
  - `lib/features/my_page/presentation/pages/my_page.dart`

## 2026-06-12 Task 4 인증 구현 메모

- auth 구현은 `lib/features/auth/**`와 공통 auth 입력/버튼 위젯, 그리고 `app_router.dart`의 auth route 교체까지만 다룬다.
- 로그인/회원가입 성공 시 현재 단계에서는 토큰 저장과 세션 반영만 보장하고, post-auth redirect 정교화는 Task 5에서 처리한다.
- 서버 `fieldErrors`는 controller 상태로 필드별 매핑해 각 입력창의 `errorText`로 렌더링한다.

## 2026-06-12 Task 5 세션 복구/라우터 가드 메모

- 이 단계부터 앱 시작 시 splash에서 세션 복구를 완료한 뒤 라우팅한다.
- 세션 복구는 저장된 토큰만 읽고 끝내지 않고, `GET /users/me` 성공까지 포함해야 한다.
- 라우팅 분기는 페이지 내부 네비게이션이 아니라 router redirect에서만 결정한다.
- `jobId`가 남아 있으면 온보딩 미완료 사용자에 한해 plan generation loading으로 우선 복귀시킨다.

## 2026-06-12 최종 구현 메모

- 계획 문서의 Task 1-12 범위는 모두 구현됐다.
- 최종 검증 기준 명령:
  - `flutter analyze`
  - `flutter test`
- 문서 업데이트 대상:
  - `README.md`
  - `agent-notes.md`
  - `codex-notes.md`
  - `docs/superpowers/specs/2026-06-12-flutter-app-design.md`
