# PlanIt Flutter App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `api-spec.md` 기준으로 iOS/Android용 PlanIt Flutter 앱을 새로 구축하고, 인증부터 온보딩, 플랜 생성, 대시보드, 오늘 플랜, 히스토리, 마이페이지까지 실백엔드 연동으로 동작하게 만든다.

**Architecture:** Flutter 앱은 `feature-first + core` 구조로 구성한다. 공통 코어에서 네트워크, 세션, 저장소, 라우팅, 테마를 담당하고, 각 기능은 `data/domain/presentation` 경계로 분리한다. 인증 상태, 온보딩 완료 여부, 진행 중 플랜 생성 job 상태를 기준으로 라우팅을 제어한다.

**Tech Stack:** Flutter, Dart, go_router, flutter_riverpod, dio, flutter_secure_storage, shared_preferences, intl, json_serializable, flutter_test

---

### Task 1: Scaffold Flutter Project And Baseline

**Files:**
- Create: `pubspec.yaml`
- Create: `analysis_options.yaml`
- Create: `lib/main.dart`
- Create: `test/widget_test.dart`
- Modify: `.gitignore`
- Modify: `agent-notes.md`

- [ ] `flutter create . --platforms=ios,android`
- [ ] `flutter test`를 실행해 생성 직후 기본 테스트가 통과하는지 확인한다.
- [ ] `agent-notes.md`에 Flutter 스캐폴딩이 시작됐고 이후 기준 파일이 `docs/superpowers/specs/2026-06-12-flutter-app-design.md`와 이 계획 문서라는 점을 추가한다.
- [ ] 생성된 기본 카운터 앱 구조를 확인하고 이후 교체 대상 파일을 기록한다.
- [ ] `git add .`
- [ ] `git commit -m "chore: scaffold flutter application"`

### Task 2: Add Dependencies And App Foundation

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/app/bootstrap/app_bootstrap.dart`
- Create: `lib/app/router/app_router.dart`
- Create: `lib/app/router/main_shell.dart`
- Create: `lib/app/router/route_paths.dart`
- Create: `lib/app/theme/app_theme.dart`
- Create: `lib/core/error/app_exception.dart`
- Create: `lib/shared/widgets/app_loading_view.dart`
- Modify: `lib/main.dart`
- Test: `test/widget_test.dart`

- [ ] `go_router`, `flutter_riverpod`, `dio`, `flutter_secure_storage`, `shared_preferences`, `intl`, `json_annotation` 의존성을 추가한다.
- [ ] `build_runner`, `json_serializable`, `flutter_lints` dev dependency를 추가한다.
- [ ] `ProviderScope` 기반 앱 부트스트랩 엔트리와 기본 `MaterialApp.router` 구성을 만든다.
- [ ] 이후 API base URL을 `--dart-define`로 주입할 수 있도록 `ApiConfig`가 읽을 런타임 설정 구조를 먼저 정한다.
- [ ] 앱 전역 색상, 텍스트 스타일, 입력 필드, 버튼 기본 테마를 `app_theme.dart`에 정의한다.
- [ ] `Splash`, `Welcome`, `Login`, `Sign Up`, `Home`, `History`, `My Page`용 임시 placeholder route를 연결해 전체 라우팅 뼈대를 세운다.
- [ ] 기본 위젯 테스트를 앱 시작 시 `Splash`가 보이는지 검증하는 테스트로 교체한다.
- [ ] `flutter pub get`
- [ ] `flutter test`
- [ ] `git add pubspec.yaml lib test agent-notes.md`
- [ ] `git commit -m "feat: add app foundation and router shell"`

### Task 3: Build Core Session, Storage, And Network Layer

**Files:**
- Create: `lib/core/storage/secure_storage_service.dart`
- Create: `lib/core/storage/preferences_service.dart`
- Create: `lib/core/session/session_tokens.dart`
- Create: `lib/core/session/session_snapshot.dart`
- Create: `lib/core/session/session_repository.dart`
- Create: `lib/core/session/session_controller.dart`
- Create: `lib/core/network/api_config.dart`
- Create: `lib/core/network/api_client.dart`
- Create: `lib/core/network/api_response.dart`
- Create: `lib/core/network/auth_interceptor.dart`
- Create: `lib/core/network/refresh_coordinator.dart`
- Create: `lib/core/network/network_providers.dart`
- Create: `lib/shared/models/api_field_error.dart`
- Test: `test/core/session/session_controller_test.dart`
- Test: `test/core/network/auth_interceptor_test.dart`

- [ ] 토큰, 만료 시각, 진행 중 `jobId`를 저장/삭제하는 storage 계층을 만든다.
- [ ] 현재 세션 복구, 세션 저장, 세션 초기화를 담당하는 `sessionRepository`와 `sessionController`를 만든다.
- [ ] `api-spec.md`의 공통 성공/실패 응답 형식을 파싱하는 공통 응답 모델을 추가한다.
- [ ] `dio` 기반 `ApiClient`와 `Authorization` 자동 주입 인터셉터를 만든다.
- [ ] `401` 발생 시 refresh를 한 번만 수행하도록 `RefreshCoordinator`를 추가한다.
- [ ] 토큰 저장/복구 테스트와 refresh 중복 방지 테스트를 먼저 작성한다.
- [ ] 테스트 실패를 확인한 뒤 최소 구현으로 통과시킨다.
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter test test/core/session/session_controller_test.dart test/core/network/auth_interceptor_test.dart`
- [ ] `git add lib/core lib/shared test/core`
- [ ] `git commit -m "feat: add session storage and network core"`

### Task 4: Implement Auth Domain And Screens

**Files:**
- Create: `lib/features/auth/data/datasource/auth_remote_data_source.dart`
- Create: `lib/features/auth/data/dto/login_request_dto.dart`
- Create: `lib/features/auth/data/dto/signup_request_dto.dart`
- Create: `lib/features/auth/data/dto/auth_response_dto.dart`
- Create: `lib/features/auth/data/repository/auth_repository_impl.dart`
- Create: `lib/features/auth/domain/model/auth_user.dart`
- Create: `lib/features/auth/domain/repository/auth_repository.dart`
- Create: `lib/features/auth/presentation/controllers/login_controller.dart`
- Create: `lib/features/auth/presentation/controllers/signup_controller.dart`
- Create: `lib/features/auth/presentation/pages/welcome_page.dart`
- Create: `lib/features/auth/presentation/pages/login_page.dart`
- Create: `lib/features/auth/presentation/pages/signup_page.dart`
- Create: `lib/shared/widgets/app_text_field.dart`
- Create: `lib/shared/widgets/primary_button.dart`
- Test: `test/features/auth/login_controller_test.dart`
- Test: `test/features/auth/login_page_test.dart`
- Test: `test/features/auth/signup_page_test.dart`

- [ ] 로그인/회원가입 요청, 응답 DTO를 `api-spec.md`에 맞춰 작성한다.
- [ ] 로그인/회원가입 성공 시 토큰 저장과 사용자 상태 반영까지 처리하는 repository를 구현한다.
- [ ] 로그인, 회원가입 폼 검증과 제출 상태를 관리하는 controller를 만든다.
- [ ] `Welcome`, `Login`, `Sign Up` 화면을 공통 입력/버튼 컴포넌트로 구현한다.
- [ ] 서버 `fieldErrors`가 있으면 필드 하단에 노출되도록 매핑한다.
- [ ] 로그인 controller 테스트와 폼 위젯 테스트를 먼저 작성한다.
- [ ] 최소 구현으로 테스트를 통과시키고 라우터에 auth 페이지를 연결한다.
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter test test/features/auth`
- [ ] `git add lib/features/auth lib/shared/widgets test/features/auth`
- [ ] `git commit -m "feat: implement authentication flow"`

### Task 5: Add Current User Fetch And Route Guards

**Files:**
- Create: `lib/features/my_page/data/datasource/user_remote_data_source.dart`
- Create: `lib/features/my_page/data/dto/user_profile_dto.dart`
- Create: `lib/features/my_page/data/repository/user_repository_impl.dart`
- Create: `lib/features/my_page/domain/model/user_profile.dart`
- Create: `lib/features/my_page/domain/repository/user_repository.dart`
- Create: `lib/app/router/app_redirect_logic.dart`
- Modify: `lib/app/router/app_router.dart`
- Modify: `lib/core/session/session_controller.dart`
- Test: `test/app/router/app_redirect_logic_test.dart`

- [ ] `GET /users/me` 응답 모델과 사용자 프로필 repository를 추가한다.
- [ ] 앱 시작 시 refresh 후 사용자 정보를 읽고 세션 상태를 완성하도록 연결한다.
- [ ] `onboardingCompleted`, 세션 존재 여부, 진행 중 `jobId`에 따라 라우팅을 분기하는 redirect 로직을 추가한다.
- [ ] 자동 로그인 성공, 자동 로그인 실패, 온보딩 미완료 분기를 테스트로 먼저 고정한다.
- [ ] 최소 구현으로 redirect 테스트를 통과시킨다.
- [ ] `flutter test test/app/router/app_redirect_logic_test.dart`
- [ ] `git add lib/app/router lib/features/my_page/data lib/features/my_page/domain lib/core/session test/app/router`
- [ ] `git commit -m "feat: add session restore and route guards"`

### Task 6: Implement Study Profile And Exam Plan Onboarding

**Files:**
- Create: `lib/features/onboarding/data/datasource/study_profile_remote_data_source.dart`
- Create: `lib/features/onboarding/data/dto/study_profile_request_dto.dart`
- Create: `lib/features/onboarding/data/repository/study_profile_repository_impl.dart`
- Create: `lib/features/onboarding/domain/model/study_profile_input.dart`
- Create: `lib/features/onboarding/domain/repository/study_profile_repository.dart`
- Create: `lib/features/onboarding/presentation/controllers/study_profile_controller.dart`
- Create: `lib/features/onboarding/presentation/pages/study_profile_page.dart`
- Create: `lib/features/exam_plan/data/datasource/exam_plan_remote_data_source.dart`
- Create: `lib/features/exam_plan/data/dto/exam_plan_request_dto.dart`
- Create: `lib/features/exam_plan/data/dto/subject_scope_request_dto.dart`
- Create: `lib/features/exam_plan/data/repository/exam_plan_repository_impl.dart`
- Create: `lib/features/exam_plan/domain/model/exam_plan_input.dart`
- Create: `lib/features/exam_plan/domain/model/subject_scope_input.dart`
- Create: `lib/features/exam_plan/domain/repository/exam_plan_repository.dart`
- Create: `lib/features/exam_plan/presentation/controllers/exam_plan_controller.dart`
- Create: `lib/features/exam_plan/presentation/pages/exam_plan_page.dart`
- Create: `lib/features/exam_plan/presentation/pages/subject_scope_page.dart`
- Test: `test/features/onboarding/study_profile_controller_test.dart`
- Test: `test/features/onboarding/study_profile_page_test.dart`
- Test: `test/features/exam_plan/exam_plan_page_test.dart`

- [ ] 사용자 기본 정보 입력 폼과 `PUT /users/me/study-profile` 연동을 만든다.
- [ ] 시험 계획 입력과 시험 범위 입력 폼, `PUT /exam-plans/active`, `PUT /exam-plans/active/scopes` 연동을 만든다.
- [ ] 단계별 저장 성공 시 다음 화면으로 이동하고, 재진입 시 서버 데이터를 다시 불러오도록 controller를 구성한다.
- [ ] 각 단계의 필수 입력과 제출 성공/실패를 테스트로 먼저 고정한다.
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter test test/features/onboarding test/features/exam_plan`
- [ ] `git add lib/features/onboarding lib/features/exam_plan test/features/onboarding test/features/exam_plan`
- [ ] `git commit -m "feat: implement onboarding and exam plan flow"`

### Task 7: Implement Plan Generation Request And Polling

**Files:**
- Create: `lib/features/plan_generation/data/datasource/plan_generation_remote_data_source.dart`
- Create: `lib/features/plan_generation/data/dto/plan_generation_request_dto.dart`
- Create: `lib/features/plan_generation/data/dto/plan_generation_status_dto.dart`
- Create: `lib/features/plan_generation/data/repository/plan_generation_repository_impl.dart`
- Create: `lib/features/plan_generation/domain/model/plan_generation_input.dart`
- Create: `lib/features/plan_generation/domain/model/plan_generation_status.dart`
- Create: `lib/features/plan_generation/domain/repository/plan_generation_repository.dart`
- Create: `lib/features/plan_generation/presentation/controllers/plan_generation_controller.dart`
- Create: `lib/features/plan_generation/presentation/pages/plan_generation_loading_page.dart`
- Test: `test/features/plan_generation/plan_generation_controller_test.dart`
- Test: `test/features/plan_generation/plan_generation_loading_page_test.dart`

- [ ] `POST /plan-generation-jobs`, `GET /plan-generation-jobs/{jobId}` DTO와 repository를 만든다.
- [ ] 진행 중 `jobId` 저장, polling 시작/종료, 완료/실패 상태 전이를 controller에 구현한다.
- [ ] 완료 시 `jobId`를 지우고 `Home`으로 보내며, 실패 시 입력 화면으로 되돌린다.
- [ ] 앱 재시작 후 진행 중 `jobId`가 있으면 polling을 복구하는 로직을 테스트로 먼저 고정한다.
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter test test/features/plan_generation`
- [ ] `git add lib/features/plan_generation test/features/plan_generation`
- [ ] `git commit -m "feat: add plan generation loading flow"`

### Task 8: Build Main Shell, Dashboard, And Today Plan Read

**Files:**
- Create: `lib/shared/widgets/app_scaffold.dart`
- Create: `lib/shared/widgets/section_card.dart`
- Create: `lib/shared/widgets/progress_summary_card.dart`
- Create: `lib/features/dashboard/data/datasource/dashboard_remote_data_source.dart`
- Create: `lib/features/dashboard/data/dto/dashboard_dto.dart`
- Create: `lib/features/dashboard/data/repository/dashboard_repository_impl.dart`
- Create: `lib/features/dashboard/domain/model/dashboard_summary.dart`
- Create: `lib/features/dashboard/domain/repository/dashboard_repository.dart`
- Create: `lib/features/dashboard/presentation/controllers/dashboard_controller.dart`
- Create: `lib/features/dashboard/presentation/pages/home_page.dart`
- Create: `lib/features/today_plan/data/datasource/today_plan_remote_data_source.dart`
- Create: `lib/features/today_plan/data/dto/today_plan_dto.dart`
- Create: `lib/features/today_plan/data/dto/today_plan_progress_dto.dart`
- Create: `lib/features/today_plan/data/repository/today_plan_repository_impl.dart`
- Create: `lib/features/today_plan/domain/model/today_plan.dart`
- Create: `lib/features/today_plan/domain/model/today_plan_progress.dart`
- Create: `lib/features/today_plan/domain/repository/today_plan_repository.dart`
- Create: `lib/features/today_plan/presentation/controllers/today_plan_controller.dart`
- Create: `lib/features/today_plan/presentation/pages/today_plan_detail_page.dart`
- Create: `lib/shared/widgets/plan_item_tile.dart`
- Test: `test/features/dashboard/home_page_test.dart`
- Test: `test/features/today_plan/today_plan_controller_test.dart`

- [ ] 하단 탭 셸과 `Home`, `History`, `My Page` 기본 구조를 만든다.
- [ ] `GET /dashboard`, `GET /plans/today`, `GET /plans/today/progress` 연동을 추가한다.
- [ ] 대시보드 요약, 오늘 플랜 목록, 진행도, 새싹/출석 정보를 `Home`과 `Today Plan Detail`에서 읽어오도록 구현한다.
- [ ] 읽기 전용 today plan 표시와 대시보드 렌더링 테스트를 먼저 작성한다.
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter test test/features/dashboard test/features/today_plan/today_plan_controller_test.dart`
- [ ] `git add lib/features/dashboard lib/features/today_plan lib/shared/widgets test/features/dashboard test/features/today_plan`
- [ ] `git commit -m "feat: add dashboard and today plan detail"`

### Task 9: Add Today Plan Edit, Toggle, And Complete

**Files:**
- Create: `lib/features/today_plan/data/dto/update_today_plan_request_dto.dart`
- Create: `lib/features/today_plan/data/dto/toggle_plan_item_request_dto.dart`
- Create: `lib/features/today_plan/presentation/controllers/today_plan_edit_controller.dart`
- Create: `lib/features/today_plan/presentation/pages/today_plan_edit_page.dart`
- Create: `lib/features/today_plan/presentation/widgets/today_plan_form_item.dart`
- Test: `test/features/today_plan/today_plan_edit_controller_test.dart`
- Test: `test/features/today_plan/today_plan_edit_page_test.dart`

- [ ] `PUT /plans/today`, `PATCH /plans/today/items/{planItemId}`, `POST /plans/today/complete` 요청 DTO와 repository 메서드를 추가한다.
- [ ] 오늘 플랜 항목 추가/수정/삭제 UI와 저장 동작을 구현한다.
- [ ] 체크 토글은 optimistic update 후 실패 시 롤백하도록 구현한다.
- [ ] 완료 처리 `409`는 명시 메시지로 노출되게 구현한다.
- [ ] 수정/토글/완료 처리 테스트를 먼저 작성한다.
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter test test/features/today_plan`
- [ ] `git add lib/features/today_plan test/features/today_plan`
- [ ] `git commit -m "feat: implement today plan editing and completion"`

### Task 10: Implement History Screens

**Files:**
- Create: `lib/features/history/data/datasource/history_remote_data_source.dart`
- Create: `lib/features/history/data/dto/history_month_dto.dart`
- Create: `lib/features/history/data/dto/history_day_detail_dto.dart`
- Create: `lib/features/history/data/repository/history_repository_impl.dart`
- Create: `lib/features/history/domain/model/history_month.dart`
- Create: `lib/features/history/domain/model/history_day_detail.dart`
- Create: `lib/features/history/domain/repository/history_repository.dart`
- Create: `lib/features/history/presentation/controllers/history_controller.dart`
- Create: `lib/features/history/presentation/pages/history_page.dart`
- Create: `lib/features/history/presentation/pages/history_detail_page.dart`
- Test: `test/features/history/history_controller_test.dart`
- Test: `test/features/history/history_page_test.dart`

- [ ] `GET /plans/history`, `GET /plans/history/{date}` DTO와 repository를 추가한다.
- [ ] 월별 기록 화면과 날짜 상세 화면을 구현한다.
- [ ] 월 전환과 날짜 선택 상태를 controller에서 관리한다.
- [ ] 월별 목록/상세 이동 테스트를 먼저 작성한다.
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter test test/features/history`
- [ ] `git add lib/features/history test/features/history`
- [ ] `git commit -m "feat: implement history screens"`

### Task 11: Implement My Page And Settings Screens

**Files:**
- Create: `lib/features/my_page/data/dto/study_settings_request_dto.dart`
- Create: `lib/features/my_page/data/dto/notification_settings_request_dto.dart`
- Create: `lib/features/my_page/data/dto/account_settings_request_dto.dart`
- Create: `lib/features/my_page/presentation/controllers/my_page_controller.dart`
- Create: `lib/features/my_page/presentation/pages/my_page.dart`
- Create: `lib/features/my_page/presentation/pages/study_settings_page.dart`
- Create: `lib/features/my_page/presentation/pages/notification_settings_page.dart`
- Create: `lib/features/my_page/presentation/pages/account_settings_page.dart`
- Test: `test/features/my_page/my_page_controller_test.dart`
- Test: `test/features/my_page/my_page_page_test.dart`

- [ ] `GET /users/me`, `PATCH /users/me/study-settings`, `PATCH /users/me/notification-settings`, `PATCH /users/me/account`, `POST /auth/logout`을 화면에 연결한다.
- [ ] 프로필 요약, 공부 설정, 알림 설정, 계정 설정, 로그아웃 UI를 구현한다.
- [ ] 로그아웃 시 서버 호출과 무관하게 세션 정리 후 `Welcome`으로 이동하도록 처리한다.
- [ ] 설정 저장과 로그아웃 동작 테스트를 먼저 작성한다.
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter test test/features/my_page`
- [ ] `git add lib/features/my_page test/features/my_page`
- [ ] `git commit -m "feat: implement my page and settings"`

### Task 12: Polish, Verification, And Documentation

**Files:**
- Modify: `README.md`
- Modify: `agent-notes.md`
- Modify: `docs/superpowers/specs/2026-06-12-flutter-app-design.md`
- Test: `test/`

- [ ] API base URL 설정 방법과 필수 실행 환경을 `README.md`에 문서화한다.
- [ ] `agent-notes.md`에 구현 완료 범위, 남은 리스크, 백엔드 연동 시 확인이 필요한 계약 차이를 기록한다.
- [ ] 디자인 스펙 문서에 구현 결과와 달라진 점이 있으면 반영한다.
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] 가능하면 에뮬레이터 또는 시뮬레이터에서 수동 점검을 진행한다.
- [ ] `git add README.md agent-notes.md docs/superpowers/specs/2026-06-12-flutter-app-design.md`
- [ ] `git commit -m "chore: verify and document flutter app"`
