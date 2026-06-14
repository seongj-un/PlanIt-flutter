# PlanIt Flutter

Real-backend Flutter client for PlanIt.

## Source of truth

- [`api-spec.md`](api-spec.md)
- [`docs/superpowers/specs/2026-06-12-flutter-app-design.md`](docs/superpowers/specs/2026-06-12-flutter-app-design.md)
- [`docs/superpowers/plans/2026-06-12-flutter-app-foundation.md`](docs/superpowers/plans/2026-06-12-flutter-app-foundation.md)

## Current status

- iOS/Android Flutter app is implemented end-to-end against the existing backend.
- Included flows:
  - auth: welcome, login, sign up, session restore, token refresh, logout
  - onboarding: study profile, exam plan, subject scopes
  - plan generation: job creation, polling, resume after app restart
  - main app: dashboard, today plan detail/edit/complete, history, my page

## Requirements

- Flutter SDK compatible with `sdk: ^3.11.5` in [`pubspec.yaml`](pubspec.yaml)
- iOS Simulator, Android Emulator, or a physical device
- A reachable backend base URL

## Run

1. Install packages.

```bash
flutter pub get
```

2. Regenerate serializers when needed.

```bash
dart run build_runner build
```

3. Run the app with the backend base URL.

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

Notes:

- iOS Simulator can usually reach a local server with `http://localhost:<port>`.
- Android Emulator usually needs `http://10.0.2.2:<port>`.
- Physical devices need a backend address reachable on the same network.
- This workspace is currently fixed for local iOS simulator use by pointing `build` to `/private/tmp/PlanIt-flutter-build`.
- If iOS simulator build fails with `resource fork, Finder information, or similar detritus not allowed`, recreate that symlinked build directory outside `Desktop/Documents` and clear `.dart_tool/flutter_build`.
- Verified on `2026-06-14`: after moving only the generated build output outside the File Provider managed path, both `flutter build ios --simulator --debug` and `flutter run` succeeded from the current workspace.

## Verification

```bash
flutter analyze
flutter test
```

## Architecture

- `feature-first + core`
- routing: `go_router`
- state: `flutter_riverpod`
- network: `dio`
- token storage: `flutter_secure_storage`
- local preferences: `shared_preferences`

## Current implementation notes

- `PlanGenerationLoadingPage` creates the job and also resumes polling from a saved `jobId`.
- Subject scope data is passed in-memory into plan generation because the current contract does not provide a read API for saved scopes.
- Notification settings are write-only from the app's perspective right now because `GET /users/me` does not return them.
- Logout clears the local session even if `POST /auth/logout` fails.
