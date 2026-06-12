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
- Common API envelope parsing is in `lib/core/network/api_response.dart`, including `fieldErrors` mapping to `ApiFieldError`.
- `AuthInterceptor` injects `Authorization` headers and retries one failed request after refresh.
- Concurrent `401` refreshes are deduplicated by `RefreshCoordinator`, so later auth/onboarding repositories should share the same core `Dio` instance instead of creating their own.
- Regression tests added:
  - `test/core/session/session_controller_test.dart`
  - `test/core/network/auth_interceptor_test.dart`
