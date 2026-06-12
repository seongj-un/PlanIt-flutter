import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_snapshot.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/exam_plan/presentation/pages/exam_plan_page.dart';
import '../../features/exam_plan/presentation/pages/subject_scope_page.dart';
import '../../features/history/presentation/pages/history_detail_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/my_page/presentation/pages/account_settings_page.dart';
import '../../features/my_page/presentation/pages/my_page.dart';
import '../../features/my_page/presentation/pages/notification_settings_page.dart';
import '../../features/my_page/presentation/pages/study_settings_page.dart';
import '../../features/onboarding/presentation/pages/study_profile_page.dart';
import '../../features/dashboard/presentation/pages/home_page.dart';
import '../../features/plan_generation/domain/model/plan_generation_input.dart';
import '../../features/plan_generation/presentation/pages/plan_generation_loading_page.dart';
import '../../features/today_plan/domain/model/today_plan.dart';
import '../../features/today_plan/presentation/pages/today_plan_detail_page.dart';
import '../../features/today_plan/presentation/pages/today_plan_edit_page.dart';
import '../../shared/widgets/app_loading_view.dart';
import 'app_redirect_logic.dart';
import 'main_shell.dart';
import 'route_paths.dart';

abstract final class AppRouter {
  static GoRouter createRouter({
    required Listenable refreshListenable,
    required SessionSnapshotProvider sessionSnapshotProvider,
    required RetrySessionRestore retrySessionRestore,
  }) {
    return GoRouter(
      initialLocation: RoutePaths.splash,
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        return AppRedirectLogic.resolve(
          location: state.matchedLocation,
          session: sessionSnapshotProvider(),
        );
      },
      routes: [
        GoRoute(
          path: RoutePaths.splash,
          pageBuilder: (context, state) => NoTransitionPage(
            child: _SplashPlaceholderPage(
              refreshListenable: refreshListenable,
              sessionSnapshotProvider: sessionSnapshotProvider,
              retrySessionRestore: retrySessionRestore,
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.welcome,
          pageBuilder: (context, state) =>
              const MaterialPage(child: WelcomePage()),
        ),
        GoRoute(
          path: RoutePaths.login,
          pageBuilder: (context, state) =>
              const MaterialPage(child: LoginPage()),
        ),
        GoRoute(
          path: RoutePaths.signUp,
          pageBuilder: (context, state) =>
              const MaterialPage(child: SignUpPage()),
        ),
        GoRoute(
          path: RoutePaths.studyProfile,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: StudyProfilePage()),
        ),
        GoRoute(
          path: RoutePaths.examPlan,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ExamPlanPage()),
        ),
        GoRoute(
          path: RoutePaths.subjectScope,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SubjectScopePage()),
        ),
        GoRoute(
          path: RoutePaths.planGenerationLoading,
          pageBuilder: (context, state) {
            final initialInput = state.extra is PlanGenerationInput
                ? state.extra as PlanGenerationInput
                : null;
            return NoTransitionPage(
              child: PlanGenerationLoadingPage(initialInput: initialInput),
            );
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.home,
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: HomePage()),
                  routes: [
                    GoRoute(
                      path: 'today-plan',
                      pageBuilder: (context, state) => const MaterialPage(
                        child: TodayPlanDetailPage(),
                      ),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          pageBuilder: (context, state) => MaterialPage(
                            child: TodayPlanEditPage(
                              initialPlan: state.extra is TodayPlan
                                  ? state.extra as TodayPlan
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.history,
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: HistoryPage()),
                  routes: [
                    GoRoute(
                      path: ':date',
                      pageBuilder: (context, state) => MaterialPage(
                        child: HistoryDetailPage(
                          date: state.pathParameters['date']!,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.myPage,
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: MyPagePage()),
                  routes: [
                    GoRoute(
                      path: 'study-settings',
                      pageBuilder: (context, state) =>
                          const MaterialPage(child: StudySettingsPage()),
                    ),
                    GoRoute(
                      path: 'notification-settings',
                      pageBuilder: (context, state) =>
                          const MaterialPage(child: NotificationSettingsPage()),
                    ),
                    GoRoute(
                      path: 'account-settings',
                      pageBuilder: (context, state) =>
                          const MaterialPage(child: AccountSettingsPage()),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

typedef SessionSnapshotProvider = SessionSnapshot Function();
typedef RetrySessionRestore = Future<void> Function();

class _SplashPlaceholderPage extends StatelessWidget {
  const _SplashPlaceholderPage({
    required this.refreshListenable,
    required this.sessionSnapshotProvider,
    required this.retrySessionRestore,
  });

  final Listenable refreshListenable;
  final SessionSnapshotProvider sessionSnapshotProvider;
  final RetrySessionRestore retrySessionRestore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: refreshListenable,
        builder: (context, _) {
          final session = sessionSnapshotProvider();
          if (session.status == SessionStatus.restoreFailed &&
              session.hasSession) {
            return AppLoadingView(
              title: 'Splash',
              message: 'We could not restore your session. Try again.',
              isLoading: false,
              actionLabel: 'Retry',
              onAction: () {
                retrySessionRestore();
              },
            );
          }

          return const AppLoadingView(
            title: 'Splash',
            message: 'Preparing your study plan...',
          );
        },
      ),
    );
  }
}
