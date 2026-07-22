import '../../core/session/session_snapshot.dart';
import 'route_paths.dart';

abstract final class AppRedirectLogic {
  static String? resolve({
    required String location,
    required SessionSnapshot session,
  }) {
    if (session.status == SessionStatus.initial ||
        session.status == SessionStatus.restoring) {
      return location == RoutePaths.splash ? null : RoutePaths.splash;
    }

    if (session.status == SessionStatus.restoreFailed && session.hasSession) {
      return location == RoutePaths.splash ? null : RoutePaths.splash;
    }

    if (!session.hasSession ||
        session.status == SessionStatus.unauthenticated) {
      if (_isAuthRoute(location)) {
        return null;
      }

      return RoutePaths.welcome;
    }

    final userProfile = session.userProfile;
    if (userProfile == null) {
      return location == RoutePaths.splash ? null : RoutePaths.splash;
    }

    if (session.shouldResumePlanGeneration) {
      return location == RoutePaths.planGenerationLoading
          ? null
          : RoutePaths.planGenerationLoading;
    }

    if (!userProfile.onboardingCompleted) {
      if (_isAllowedOnboardingRoute(location)) {
        return null;
      }

      return RoutePaths.studyProfile;
    }

    // Once onboarded, only auth routes and the splash bounce back to home.
    // The onboarding / plan-generation routes stay reachable so the user can
    // create a new plan later — e.g. if they skipped plan generation during
    // onboarding, "플랜 만들기" on the home screen can route back into the flow.
    if (_isAuthRoute(location) || location == RoutePaths.splash) {
      return RoutePaths.home;
    }

    return null;
  }

  static bool _isAuthRoute(String location) {
    return location == RoutePaths.welcome ||
        location == RoutePaths.login ||
        location == RoutePaths.signUp;
  }

  static bool _isAllowedOnboardingRoute(String location) {
    return location == RoutePaths.studyProfile ||
        location == RoutePaths.examPlan ||
        location == RoutePaths.subjectScope ||
        location == RoutePaths.planGenerationLoading;
  }
}
