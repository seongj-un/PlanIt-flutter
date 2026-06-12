# Codex Agent Notes

이 파일은 Codex 컨텍스트가 초기화됐을 때 가장 먼저 읽는다.

## 사용자 작업 원칙

- 작업 시작 시 저장소의 `*.md` 문서를 먼저 읽는다.
- 작업이 끝나면 실행한 작업을 정리한다.
- 가능하면 작업 종료 후 커밋, 푸시까지 진행한다.
- 작업 지시 외에도 이후 진행에 중요한 제약과 판단 근거를 이 파일에 남긴다.

## 현재 저장소 상태

- 현재 `/Users/seongjun/Desktop/project/PlanIt-flutter`에는 구현 코드가 없고 문서와 IDE 설정만 있다.
- 현재 디렉터리는 Git 저장소다. 기본 브랜치는 `main`이다.
- 확인된 Markdown 문서:
  - `project.md`
  - `api-spec.md`
  - `docs/superpowers/specs/2026-06-09-plan-generation-jobs-mvp-design.md`
  - `docs/superpowers/plans/2026-06-09-plan-generation-jobs-mvp.md`
  - `docs/superpowers/specs/2026-06-11-plan-apis-batch-design.md`
  - `docs/superpowers/plans/2026-06-11-plan-apis-batch.md`
  - `docs/superpowers/specs/2026-06-12-flutter-app-design.md`

## 문서 기준 우선 구현 결론

- 백엔드는 이미 구현 완료 상태라는 사용자 설명이 있다.
- 이 저장소의 실제 작업 대상은 Flutter 프론트엔드 앱이다.
- 첫 구현 우선순위는 백엔드 job API 자체가 아니라, 그 API를 사용하는 전체 앱 골격과 인증/온보딩/플랜 생성 흐름이다.
- 근거:
  - `api-spec.md`가 Flutter 앱이 붙을 단일 계약이다.
  - 사용자 결정: mock-first 취소, 처음부터 실백엔드 연동.
  - 사용자 결정: 전체 화면 범위, 자동 로그인/refresh token 포함, iOS/Android 대상.

## 구현 전 확인 필요 사항

- Flutter 앱을 이 저장소에 새로 스캐폴딩해야 한다.
- 승인된 설계는 `docs/superpowers/specs/2026-06-12-flutter-app-design.md`를 기준으로 한다.
- 현재 구현 계획은 `docs/superpowers/plans/2026-06-12-flutter-app-foundation.md`를 기준으로 한다.
- 확정된 핵심 결정:
  - `feature-first + core` 아키텍처
  - 실백엔드 연동
  - `api-spec.md` 기준 DTO 설계
  - 자동 로그인 + refresh token
  - UI는 구조 유지, 시각은 재해석

## 구현 시작 순서 메모

- 1단계: Flutter 프로젝트 생성
- 2단계: `go_router`, `riverpod`, `dio`, secure storage 등 코어 세팅
- 3단계: 인증 플로우
- 4단계: 온보딩, 시험 계획/범위 입력
- 5단계: plan generation loading
- 6단계: dashboard, today plan, history, my page

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
- 그다음 `api-spec.md`와 `docs/superpowers/specs/2026-06-12-flutter-app-design.md` 확인
- 구현 전에는 현재 브랜치 상태와 Flutter SDK 사용 가능 여부 확인

## 2026-06-12 Task 4 인증 구현 메모

- auth 구현은 `lib/features/auth/**`와 공통 auth 입력/버튼 위젯, 그리고 `app_router.dart`의 auth route 교체까지만 다룬다.
- 로그인/회원가입 성공 시 현재 단계에서는 토큰 저장과 세션 반영만 보장하고, post-auth redirect 정교화는 Task 5에서 처리한다.
- 서버 `fieldErrors`는 controller 상태로 필드별 매핑해 각 입력창의 `errorText`로 렌더링한다.

## 2026-06-12 Task 5 세션 복구/라우터 가드 메모

- 이 단계부터 앱 시작 시 splash에서 세션 복구를 완료한 뒤 라우팅한다.
- 세션 복구는 저장된 토큰만 읽고 끝내지 않고, `GET /users/me` 성공까지 포함해야 한다.
- 라우팅 분기는 페이지 내부 네비게이션이 아니라 router redirect에서만 결정한다.
- `jobId`가 남아 있으면 온보딩 미완료 사용자에 한해 plan generation loading으로 우선 복귀시킨다.
