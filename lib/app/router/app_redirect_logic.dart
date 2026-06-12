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
      return location == RoutePaths.studyProfile
          ? null
          : RoutePaths.studyProfile;
    }

    if (_isPublicOnlyRoute(location) || location == RoutePaths.splash) {
      return RoutePaths.home;
    }

    return null;
  }

  static bool _isAuthRoute(String location) {
    return location == RoutePaths.welcome ||
        location == RoutePaths.login ||
        location == RoutePaths.signUp;
  }

  static bool _isOnboardingRoute(String location) {
    return location == RoutePaths.studyProfile ||
        location == RoutePaths.examPlan ||
        location == RoutePaths.subjectScope ||
        location == RoutePaths.planGenerationLoading;
  }

  static bool _isPublicOnlyRoute(String location) {
    return _isAuthRoute(location) || _isOnboardingRoute(location);
  }
}
