import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_snapshot.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../shared/widgets/app_loading_view.dart';
import 'app_redirect_logic.dart';
import 'main_shell.dart';
import 'route_paths.dart';

abstract final class AppRouter {
  static GoRouter createRouter({
    required Listenable refreshListenable,
    required SessionSnapshotProvider sessionSnapshotProvider,
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
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: _SplashPlaceholderPage()),
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
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _RoutePlaceholderPage(
              title: 'Study Profile',
              subtitle: 'Study profile onboarding placeholder.',
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.examPlan,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _RoutePlaceholderPage(
              title: 'Exam Plan',
              subtitle: 'Exam plan onboarding placeholder.',
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.subjectScope,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _RoutePlaceholderPage(
              title: 'Subject Scope',
              subtitle: 'Subject scope onboarding placeholder.',
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.planGenerationLoading,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _RoutePlaceholderPage(
              title: 'Plan Generation',
              subtitle: 'Plan generation loading placeholder.',
            ),
          ),
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
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: _RoutePlaceholderPage(
                      title: 'Home',
                      subtitle: 'Dashboard summary placeholder.',
                    ),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.history,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: _RoutePlaceholderPage(
                      title: 'History',
                      subtitle: 'Study history placeholder.',
                    ),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.myPage,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: _RoutePlaceholderPage(
                      title: 'My Page',
                      subtitle: 'Profile and settings placeholder.',
                    ),
                  ),
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

class _SplashPlaceholderPage extends StatelessWidget {
  const _SplashPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppLoadingView(
        title: 'Splash',
        message: 'Preparing your study plan...',
      ),
    );
  }
}

class _RoutePlaceholderPage extends StatelessWidget {
  const _RoutePlaceholderPage({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 12),
                      Text(subtitle, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
