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

## 다음 턴 시작 체크

- 이 파일 먼저 읽기
- 그다음 `api-spec.md`와 `docs/superpowers/specs/2026-06-12-flutter-app-design.md` 확인
- 구현 전에는 현재 브랜치 상태와 Flutter SDK 사용 가능 여부 확인
