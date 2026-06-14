# Codex Context Notes

If context is reset, read this file first, then `agent-notes.md`.

## Current Source Of Truth

- Design spec: `docs/superpowers/specs/2026-06-12-flutter-app-design.md`
- Implementation plan: `docs/superpowers/plans/2026-06-12-flutter-app-foundation.md`

## Current App State

- Flutter app foundation and all planned feature areas are implemented on `feat/flutter-app-foundation`.
- Package name: `planit_flutter`
- Runtime requires `--dart-define=API_BASE_URL=<base-url>`.
- Fresh verification target for completion is:
  - `flutter analyze`
  - `flutter test`

## 2026-06-12 Task 3 Core Session / Network Notes

- Core session state now lives in `lib/core/session/` with `SessionTokens`, `SessionSnapshot`, `SessionRepository`, and `SessionController`.
- Platform storage is kept behind abstractions in `lib/core/storage/`:
  - `SecureStorageService` stores `accessToken`, `refreshToken`, `expiresAt`
  - `PreferencesService` stores the in-progress `jobId`
- Core infra providers are now synchronous after bootstrap resolves `SharedPreferences` once and overrides `sharedPreferencesInstanceProvider`.
- `sessionControllerProvider` is a reactive `StateNotifierProvider<SessionController, SessionSnapshot>`, and imperative access should go through `sessionControllerProvider.notifier` or `sessionControllerNotifierProvider`.
- Common API envelope parsing is in `lib/core/network/api_response.dart`, including `fieldErrors` mapping to `ApiFieldError`.
- `AuthInterceptor` injects `Authorization` headers and retries one failed request after refresh.
- Refresh failure or malformed refresh payloads now surface as explicit app exceptions instead of raw cast errors or collapsed unauthorized responses.
- Concurrent `401` refreshes are deduplicated by `RefreshCoordinator`, so later auth/onboarding repositories should share the same core `Dio` instance instead of creating their own.
- Regression tests added:
  - `test/core/session/session_controller_test.dart`
  - `test/core/network/auth_interceptor_test.dart`
  - `test/core/network/network_providers_test.dart`

## 2026-06-12 Task 4 Auth Flow Notes

- Scope for this task is limited to `lib/features/auth/**`, `lib/shared/widgets/app_text_field.dart`, `lib/shared/widgets/primary_button.dart`, auth widget tests, and minimal route wiring in `lib/app/router/app_router.dart`.
- `api-spec.md` auth contract:
  - `POST /auth/login` request: `email`, `password`
  - `POST /auth/signup` request: `name`, `email`, `password`
  - success response embeds `user` and `tokens`
- Session persistence should reuse the existing `SessionController`/`SessionRepository`; do not add route guards or `GET /users/me` in this task.
- Placeholder auth routes in `app_router.dart` should be replaced with real pages, but post-auth navigation should stay minimal until Task 5 introduces redirect logic.

## 2026-06-12 Task 5 Session Restore And Router Guard Notes

- Current route policy is router-driven via `lib/app/router/app_redirect_logic.dart`; auth pages should not push protected routes directly.
- `SessionSnapshot` now needs to carry restore status and current user state, not just tokens and `jobId`.
- Automatic session restoration should resolve from splash by reading persisted tokens, calling `GET /users/me`, and clearing local session on failure.
- Redirect priority should stay:
  1. splash while restore is unresolved
  2. welcome for unauthenticated users
  3. plan generation loading when `jobId` exists for an onboarding-incomplete user
  4. study profile onboarding when authenticated but incomplete
  5. main shell for authenticated + onboarding complete

## 2026-06-12 Task 6 Onboarding Form Notes

- Scope owner for this task is limited to `lib/features/onboarding/**`, `lib/features/exam_plan/**`, related tests, and minimal route integration only if the placeholders must be replaced.
- Existing redirect logic already allows `/study-profile`, `/exam-plan`, and `/subject-scope` for onboarding-incomplete users; keep that policy unchanged.
- `PUT /users/me/study-profile` payload is explicit in `api-spec.md` and should update `SessionSnapshot.userProfile` with the returned server state so re-entry shows current values.
- `PUT /exam-plans/active` and `PUT /exam-plans/active/scopes` are contract-light in `api-spec.md`; Task 6 should use a minimal client payload:
  - exam plan: `targetExamType`, `targetExamLabel`, `examDate`
  - subject scopes: list of subjects with `subjectName`, `examRange`, `preferredMethodNote`, `priority`
- Re-entry behavior should prefer current server-backed state where practical in Task 6 scope:
  - study profile and exam plan can hydrate from `SessionSnapshot.userProfile`
  - subject scope has no existing read API in scope, so keep it local-to-form for this task and document the assumption

## 2026-06-12 Task 7 Plan Generation Notes

- `plan generation` now starts from the subject scope step by passing a `PlanGenerationInput` route extra into `/plan-generation-loading`; this keeps the subject list in memory long enough to call `POST /plan-generation-jobs` without inventing a read API.
- Request mapping assumptions remain:
  - `SubjectScopeInput.priority -> subjects[].difficulty`
  - `priority == HIGH -> difficultSubjects`
  - `usualStudyHoursPerDay -> dailyMaxStudyHours`
- `PlanGenerationLoadingPage` owns both job creation and resume polling:
  - if `SessionSnapshot.activeJobId` exists, it skips creation and resumes `GET /plan-generation-jobs/{jobId}`
  - otherwise it creates the job from `initialInput`, stores `jobId`, then polls
- Completion path refreshes `GET /users/me` before routing to `Home`, because redirect logic still depends on `userProfile.onboardingCompleted`.
- Added `SessionController.clearActiveJobId()` because the loading flow needs to clear only the in-progress job without destroying tokens or the rest of the session.
- Exam plan session persistence now merges partial exam-plan responses with existing study profile fields so later steps still have `preferredStudyMethod` and `usualStudyHoursPerDay`.

## 2026-06-12 Task 8 Dashboard / Today Plan Read Notes

- `/home` is no longer a placeholder. It now loads:
  - `GET /dashboard` via `DashboardController`
  - `GET /plans/today` and `GET /plans/today/progress` via `TodayPlanController`
- `TodayPlanController` is the shared read source for both:
  - `HomePage` preview
  - `TodayPlanDetailPage`
- Added route `RoutePaths.todayPlanDetail = /home/today-plan`, nested under the home branch in the shell router.
- Current `today_plan` repository is read-only. Task 9 will extend the same feature with:
  - bulk update
  - item toggle
  - completion
- Shared widgets added for the main app surface:
  - `AppScaffold`
  - `SectionCard`
  - `ProgressSummaryCard`
  - `PlanItemTile`

## 2026-06-12 Task 9 Today Plan Edit Notes

- `today_plan` repository now also covers write operations:
  - bulk update
  - item toggle
  - completion
- Route added: `RoutePaths.todayPlanEdit = /home/today-plan/edit`
- `TodayPlanDetailPage` now owns:
  - checkbox toggle dispatch
  - completion button dispatch
  - success/error snackbars from `TodayPlanController`
- `TodayPlanController.toggleItem(...)` applies optimistic UI updates first, then reconciles with server counts and rolls back on failure.
- `TodayPlanEditPage` is route-extra driven from the detail page using the current `TodayPlan`; if the route is opened without that context it shows a fallback error state.

## 2026-06-12 Task 10 History Notes

- Added `history` feature for:
  - `GET /plans/history?month=yyyy-MM`
  - `GET /plans/history/{date}`
- `HistoryController` owns:
  - initial current-month load
  - previous/next month navigation
  - selected date detail fetch
- Router now mounts:
  - `/history`
  - `/history/:date`
- `historyInitialMonthProvider` exists so tests can override the default month without time-coupled assertions.

## 2026-06-12 Task 11 My Page Notes

- Added `MyPageController` and pages for:
  - profile summary
  - study settings
  - notification settings
  - account settings
  - logout
- `UserRepository` now also handles:
  - `PATCH /users/me/study-settings`
  - `PATCH /users/me/notification-settings`
  - `PATCH /users/me/account`
  - `POST /auth/logout`
- Important behavior:
  - logout clears the local session even if the network request fails
  - notification settings are not hydrated from `GET /users/me`, so the page uses local defaults on first open

## 2026-06-12 Task 12 Completion Notes

- Final docs to read first on context restore:
  1. `codex-notes.md`
  2. `agent-notes.md`
  3. `README.md`
  4. `api-spec.md`
- Local iOS simulator build caveat:
  - if the repo stays under `Desktop` / File Provider managed storage, Flutter iOS packaging can fail with `resource fork, Finder information, or similar detritus not allowed`
  - this is a workspace-path issue, not a Dart app failure
- Verified workaround on `2026-06-14`:
  - clone/copy the repo to `/private/tmp/PlanIt-flutter-run`
  - from there, both `flutter build ios --simulator --debug --dart-define=API_BASE_URL=http://localhost:8080` and `flutter run -d 6314C368-B770-4949-8A5A-EFC99DC3B498 --dart-define=API_BASE_URL=http://localhost:8080` succeeded
- Verified in-workspace fix on `2026-06-14`:
  - point `build` to `/private/tmp/PlanIt-flutter-build`
  - if needed, clear stale `.dart_tool/flutter_build`
  - after that, both `flutter build ios --simulator --debug --dart-define=API_BASE_URL=http://localhost:8080` and `flutter run -d 6314C368-B770-4949-8A5A-EFC99DC3B498 --dart-define=API_BASE_URL=http://localhost:8080` succeeded from the current workspace
- Most important code entry points for follow-up work:
  - `lib/app/bootstrap/app_bootstrap.dart`
  - `lib/app/router/app_router.dart`
  - `lib/core/session/session_controller.dart`
  - `lib/features/plan_generation/presentation/pages/plan_generation_loading_page.dart`
  - `lib/features/today_plan/presentation/controllers/today_plan_controller.dart`
  - `lib/features/history/presentation/controllers/history_controller.dart`
  - `lib/features/my_page/presentation/controllers/my_page_controller.dart`
