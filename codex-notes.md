# Codex Context Notes

If context is reset, read this file first, then `agent-notes.md`.

## Current Source Of Truth

- Design spec: `docs/superpowers/specs/2026-06-12-flutter-app-design.md`
- Implementation plan: `docs/superpowers/plans/2026-06-12-flutter-app-foundation.md`

## Current Scaffold State

- Flutter project scaffolded in-place with `flutter create --platforms=ios,android --project-name planit_flutter .`
- Package name used by Dart/Flutter: `planit_flutter`
- Baseline `flutter test` passed immediately after scaffold generation

## Replacement Targets Later

- `lib/main.dart` - temporary scaffold baseline file
- `test/widget_test.dart` - temporary scaffold baseline file
- App dependencies and routing in later tasks via `pubspec.yaml` and supporting source files

## Guardrails

- Do not start Task 2 in this task.
- Keep changes limited to the scaffold baseline unless the current task explicitly requires more.

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
