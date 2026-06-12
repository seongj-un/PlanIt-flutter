import '../../features/my_page/domain/model/user_profile.dart';
import 'session_tokens.dart';

enum SessionStatus {
  initial,
  restoring,
  restoreFailed,
  authenticated,
  unauthenticated,
}

class SessionSnapshot {
  const SessionSnapshot({
    this.tokens,
    this.activeJobId,
    this.userProfile,
    this.status = SessionStatus.initial,
  });

  final SessionTokens? tokens;
  final String? activeJobId;
  final UserProfile? userProfile;
  final SessionStatus status;

  bool get hasSession => tokens != null;
  bool get isAuthenticated =>
      status == SessionStatus.authenticated && hasSession;
  bool get shouldResumePlanGeneration =>
      (activeJobId?.isNotEmpty ?? false) &&
      userProfile != null &&
      userProfile!.onboardingCompleted == false;

  SessionSnapshot copyWith({
    SessionTokens? tokens,
    bool clearTokens = false,
    String? activeJobId,
    bool clearActiveJobId = false,
    UserProfile? userProfile,
    bool clearUserProfile = false,
    SessionStatus? status,
  }) {
    return SessionSnapshot(
      tokens: clearTokens ? null : (tokens ?? this.tokens),
      activeJobId: clearActiveJobId ? null : (activeJobId ?? this.activeJobId),
      userProfile: clearUserProfile ? null : (userProfile ?? this.userProfile),
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is SessionSnapshot &&
        other.tokens == tokens &&
        other.activeJobId == activeJobId &&
        other.userProfile == userProfile &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(tokens, activeJobId, userProfile, status);
}
