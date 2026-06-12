# PlanIt Flutter App Design

## Goal

문서에 정의된 전체 사용자 플로우를 포함하는 `Flutter` 모바일 앱을 새로 구축한다.

- 플랫폼: `iOS`, `Android`
- 백엔드 연동: 처음부터 실제 API 연동
- API 계약 기준: `api-spec.md`
- 인증 범위: 회원가입, 로그인, 자동 로그인, 토큰 재발급, 로그아웃
- 화면 범위: Splash, Welcome, Login, Sign Up, User Info Collection, 시험 계획 입력, 시험 범위 입력, Plan Generation Loading, Home, Today Plan Detail, Today Plan Edit, History, History Detail, My Page

비범위:

- Web 지원
- 앞으로의 예상 플랜 보기
- 복습 문제 출제
- 백엔드 API 설계 변경

## Product Direction

기능 흐름은 기존 문서 구조를 유지하되, UI는 스크린샷을 그대로 복제하지 않고 더 정돈된 모바일 생산성 앱 톤으로 재해석한다.

- 정보 밀도보다 가독성을 우선한다.
- 핵심 행동 버튼은 명확하게 분리한다.
- 오늘 해야 할 일과 진행 상태를 가장 눈에 띄게 배치한다.
- 카드, 섹션 헤더, 단계형 입력 흐름을 중심으로 구성한다.

## Architecture

앱은 `feature-first` 구조와 공통 앱 코어를 조합해 구성한다.

```text
lib/
  app/
    bootstrap/
    router/
    theme/
  core/
    network/
    session/
    storage/
    error/
  shared/
    widgets/
    models/
    utils/
  features/
    auth/
    onboarding/
    exam_plan/
    plan_generation/
    dashboard/
    today_plan/
    history/
    my_page/
```

기능별 내부 구조는 아래를 기본으로 한다.

```text
features/<feature>/
  data/
    datasource/
    dto/
    repository/
  domain/
    model/
  presentation/
    pages/
    widgets/
    controllers/
```

핵심 원칙:

- 화면은 `repository` 인터페이스를 통해서만 데이터를 읽는다.
- 네트워크, 세션, 저장소, 에러 매핑은 `core`에서 공통 처리한다.
- DTO는 API 계약에 맞추고, 화면은 도메인 모델 또는 화면 전용 view model만 사용한다.
- mock 계층은 기본 경로에 두지 않는다. 대신 추상화 경계는 유지해 테스트 대역을 주입할 수 있게 한다.

## Technical Choices

- 라우팅: `go_router`
- 상태 관리: `flutter_riverpod`
- HTTP: `dio`
- 토큰 저장: `flutter_secure_storage`
- 단순 로컬 상태 저장: `shared_preferences`
- 날짜/포맷: `intl`
- JSON 직렬화: `json_serializable`

선정 이유:

- `go_router`는 인증 분기와 탭 기반 구조를 함께 다루기 쉽다.
- `flutter_riverpod`은 feature 단위 비동기 상태와 세션 의존성을 명확하게 나누기 좋다.
- `dio`는 인터셉터 기반 토큰 갱신과 공통 에러 처리가 용이하다.

## App Flow

### Root Flow

1. `Splash`
2. 저장된 세션 확인
3. 세션 복구 성공 시 사용자 상태 확인
4. `onboardingCompleted` 여부에 따라 온보딩 또는 메인 앱 진입
5. 세션 없음 또는 복구 실패 시 `Welcome`

### Auth Flow

- `Welcome`
- `Login`
- `Sign Up`

로그인 또는 회원가입 성공 후:

- 사용자 정보가 미완성인 경우 `User Info Collection`
- 완료된 경우 다음 미완료 온보딩 단계로 이동

### Onboarding Flow

- `User Info Collection`
- 시험 계획 입력
- 시험 범위 입력
- `Plan Generation Loading`

플랜 생성 완료 시 메인 앱으로 이동한다.

### Main App Flow

하단 탭 3개:

- `Home`
- `History`
- `My Page`

서브 화면:

- `Today Plan Detail`
- `Today Plan Edit`
- `History Detail`

`Home`은 대시보드 요약과 오늘 플랜 미리보기를 함께 보여주는 진입 화면이다.

## Routing Design

라우팅은 인증 영역과 메인 앱 영역을 명확히 분리한다.

- 인증 영역: `Splash`, `Welcome`, `Login`, `Sign Up`
- 온보딩 영역: `User Info Collection`, 시험 계획 입력, 시험 범위 입력, `Plan Generation Loading`
- 메인 앱 영역: 탭 셸 + 하위 상세 화면

라우팅 분기 기준:

- 저장된 세션 존재 여부
- 세션 복구 성공 여부
- `onboardingCompleted`
- 진행 중인 `plan generation job` 존재 여부

설계 원칙:

- 탭 상태와 인증 상태를 같은 컨트롤러에 섞지 않는다.
- 새로고침 또는 앱 재실행 후에도 현재 사용자 단계로 안정적으로 복귀해야 한다.
- 로그아웃 시 모든 보호 라우트에서 이탈시켜 `Welcome`으로 강제 이동한다.

## Session And Token Lifecycle

저장 항목:

- `accessToken`
- `refreshToken`
- 토큰 만료 시각
- 마지막 사용자 상태 스냅샷 최소 정보
- 진행 중인 `plan generation jobId`

동작 규칙:

- 앱 시작 시 `refreshToken`이 있으면 `POST /auth/refresh` 호출
- 성공 시 새 `accessToken` 저장 후 `GET /users/me`로 현재 상태 조회
- 실패 시 저장된 세션 제거 후 `Welcome` 이동
- API 요청 중 `401` 발생 시 인터셉터가 재발급을 1회 시도
- 재발급 성공 시 원 요청 재시도
- 재발급 실패 시 세션 제거 및 인증 화면 복귀

경계 조건:

- 동시 다발 `401`은 refresh 중복 호출을 막아야 한다.
- refresh 진행 중 신규 요청은 대기시키거나 동일 future를 공유한다.
- 로그아웃은 서버 호출 성공 여부와 관계없이 로컬 세션 정리를 우선한다.

## Network Contract

API 계약 기준은 `api-spec.md`다. 다만 실제 백엔드 구현과 차이가 발생할 가능성을 고려해 네트워크 계층에서 계약 드리프트를 빠르게 드러내야 한다.

공통 응답 처리:

- `success == true`면 `data` 추출
- `success == false`면 `error.code`, `error.message`, `fieldErrors`를 공통 예외 모델로 변환

공통 규칙:

- Base URL은 런타임 설정 또는 환경 상수로 관리
- `Authorization: Bearer <accessToken>` 자동 주입
- 날짜는 `Asia/Seoul` 기준으로 해석
- 요청/응답 로깅은 디버그 빌드에서만 활성화

## Feature Design

### 1. Auth

지원 API:

- `POST /auth/signup`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`

화면 책임:

- `Welcome`: 로그인/회원가입 진입
- `Login`: 이메일/비밀번호 입력, 에러 표시
- `Sign Up`: 이름/이메일/비밀번호 입력, 성공 시 세션 저장

### 2. Onboarding

지원 API:

- `PUT /users/me/study-profile`
- `PUT /exam-plans/active`
- `PUT /exam-plans/active/scopes`
- `GET /users/me`

화면 책임:

- 사용자 기본 정보 입력
- 목표 시험 정보 입력
- 과목별 범위 입력

원칙:

- 단계별 저장은 서버에 즉시 반영한다.
- 뒤로 가기 후 재진입 시 서버 상태를 다시 읽어 폼에 반영한다.

### 3. Plan Generation

지원 API:

- `POST /plan-generation-jobs`
- `GET /plan-generation-jobs/{jobId}`

화면 책임:

- 생성 요청 제출
- loading 상태 표시
- polling
- 성공/실패 분기

동작 규칙:

- `jobId`를 로컬에 저장해 앱 재실행 후에도 복구 가능하게 한다.
- 완료 시 저장된 `jobId`를 제거하고 `Home`으로 이동한다.
- 실패 시 메시지를 보여주고 입력 화면으로 복귀시킨다.

### 4. Dashboard And Today Plan

지원 API:

- `GET /dashboard`
- `GET /plans/today`
- `PUT /plans/today`
- `PATCH /plans/today/items/{planItemId}`
- `POST /plans/today/complete`
- `GET /plans/today/progress`

화면 책임:

- `Home`: 대시보드 요약, 오늘 플랜 미리보기, 출석/새싹
- `Today Plan Detail`: 항목 목록, 체크, 진행도
- `Today Plan Edit`: 항목 추가/수정/삭제

원칙:

- `Home`과 `Today Plan Detail`은 같은 오늘 플랜 소스를 공유한다.
- 체크 토글 후 즉시 UI를 갱신하되 실패 시 롤백한다.
- 완료 처리 실패 `409`는 사용자에게 명시적으로 보여준다.

### 5. History

지원 API:

- `GET /plans/history?month=yyyy-MM`
- `GET /plans/history/{date}`

화면 책임:

- 월별 기록 캘린더/리스트
- 특정 날짜 상세 내역

원칙:

- 현재 월 기준 진입
- 날짜 선택 시 상세 조회
- 완료 여부와 과목 요약을 빠르게 읽을 수 있게 구성

### 6. My Page

지원 API:

- `GET /users/me`
- `PATCH /users/me/study-settings`
- `PATCH /users/me/notification-settings`
- `PATCH /users/me/account`
- `POST /auth/logout`

화면 책임:

- 프로필 정보
- 공부 설정
- 알림 설정
- 계정 설정
- 로그아웃

## State Management

`flutter_riverpod` 기준으로 상태를 나눈다.

- `sessionProvider`: 현재 세션, 인증 여부, 복구 상태
- `currentUserProvider`: 사용자 프로필 및 온보딩 완료 여부
- feature별 controller/provider:
  - `loginControllerProvider`
  - `signupControllerProvider`
  - `studyProfileControllerProvider`
  - `examPlanControllerProvider`
  - `planGenerationControllerProvider`
  - `dashboardProvider`
  - `todayPlanProvider`
  - `todayPlanEditControllerProvider`
  - `historyProvider`
  - `myPageProvider`

원칙:

- 화면별 로딩/성공/실패 상태는 feature 내부에서 관리
- 전역 세션과 전역 라우팅 분기는 공통 계층에서 관리
- 비동기 상태는 `AsyncValue` 패턴으로 일관되게 처리

## Error Handling

에러는 세 층으로 나눈다.

### Field Errors

- 회원가입, 로그인, 온보딩 입력 화면
- 서버 `fieldErrors`가 있으면 해당 필드 하단에 직접 노출

### Screen Errors

- 대시보드 조회 실패, 히스토리 조회 실패, 오늘 플랜 상세 실패
- 인라인 에러 뷰 + 재시도 버튼 제공

### Global Errors

- 인증 만료
- 네트워크 단절
- 서버 장애

표시 원칙:

- 사용자 행동을 막는 오류는 다이얼로그 또는 명시 배너 사용
- 일시적 오류는 스낵바보다 인라인 재시도 우선
- 비즈니스 오류는 숨기지 않고 의미를 직접 설명

## UI System

디자인은 재해석 기준으로 간다.

- 중립 톤 배경 + 강조색 1개 중심
- 타이포는 제목/본문/보조정보 위계 명확화
- 8pt 기반 spacing system
- 카드, 칩, 진행바, 하단 CTA 버튼을 공통 컴포넌트화

공통 컴포넌트 우선 후보:

- `AppScaffold`
- `PrimaryButton`
- `SecondaryButton`
- `AppTextField`
- `SectionCard`
- `ProgressSummaryCard`
- `PlanItemTile`
- `InlineErrorView`
- `EmptyStateView`

## Testing Strategy

### Unit Tests

- 토큰 저장/복구
- refresh 흐름
- DTO -> domain 변환
- 에러 매핑

### Widget Tests

- 로그인/회원가입 폼 검증
- 사용자 정보 입력
- 오늘 플랜 체크/완료 처리
- 히스토리 날짜 선택

### Integration-Oriented Flow Tests

- 앱 시작 후 자동 로그인 분기
- 온보딩 미완료 사용자 리다이렉트
- 플랜 생성 polling 후 `Home` 이동
- 로그아웃 후 보호 라우트 차단

## Delivery Plan

구현은 아래 순서로 진행한다.

1. Flutter 프로젝트 스캐폴딩
2. 공통 코어 구축
3. 인증 플로우
4. 온보딩 플로우
5. 플랜 생성 로딩
6. 메인 탭과 대시보드
7. 오늘 플랜 상세/수정
8. 히스토리
9. 마이페이지
10. 테스트 및 다듬기

## Risks And Mitigations

### Risk: API Spec And Backend Drift

- 실제 백엔드 응답이 문서와 다를 수 있다.
- 대응: DTO 파싱 실패와 에러 응답을 명확히 로깅하고, 어댑터 계층에서 흡수한다.

### Risk: Token Refresh Race Conditions

- 동시 요청에서 refresh 중복 호출이 발생할 수 있다.
- 대응: refresh coordinator를 두고 단일 재발급 흐름만 허용한다.

### Risk: Full-Scope Delivery Size

- 전체 화면 범위가 넓다.
- 대응: 공통 코어를 먼저 고정하고 기능을 순차적으로 닫는다.

## Out Of Scope For First Pass

- 푸시 알림 실제 등록
- 애널리틱스
- 오프라인 우선 동기화
- 태블릿 전용 레이아웃

## Implementation Notes On 2026-06-12

- 실제 구현은 이 문서의 범위를 모두 포함한다.
- 다만 API 계약상 읽기 경로가 부족한 영역은 아래처럼 보완했다.

### Plan Generation Input Recovery

- `PUT /exam-plans/active/scopes` 이후 subject scope를 다시 읽는 API가 현재 범위에 없다.
- 그래서 앱은 subject scope 화면에서 `PlanGenerationInput`을 바로 만들어 `Plan Generation Loading`으로 route extra로 넘긴다.
- loading 화면은 새 job 생성과 기존 `jobId` polling 복구를 모두 담당한다.

### Notification Settings Hydration Gap

- 현재 `GET /users/me` 응답에는 notification settings가 없다.
- 그래서 알림 설정 화면은 서버 현재값 hydrate 없이 기본값으로 진입하고, 저장만 실백엔드에 연결한다.
- 추후 조회 API 또는 `GET /users/me` 필드 확장이 생기면 이 부분을 보강해야 한다.

### Session And Logout Behavior

- 로그아웃은 `POST /auth/logout` 성공 여부와 무관하게 로컬 세션 정리를 우선한다.
- plan generation 완료 후에는 `GET /users/me`를 다시 호출해 `onboardingCompleted` 상태를 갱신한 뒤 메인 앱으로 이동한다.

### Today Plan Edit Routing

- `Today Plan Edit`는 현재 `TodayPlan` route extra를 받아 폼을 초기화한다.
- 앱 내 정상 플로우에서는 문제가 없지만, 직접 deep link로 열면 fallback 화면이 표시된다.
