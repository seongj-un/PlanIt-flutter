import 'session_tokens.dart';

class SessionSnapshot {
  const SessionSnapshot({this.tokens, this.activeJobId});

  final SessionTokens? tokens;
  final String? activeJobId;

  bool get isAuthenticated => tokens != null;

  SessionSnapshot copyWith({
    SessionTokens? tokens,
    bool clearTokens = false,
    String? activeJobId,
    bool clearActiveJobId = false,
  }) {
    return SessionSnapshot(
      tokens: clearTokens ? null : (tokens ?? this.tokens),
      activeJobId: clearActiveJobId ? null : (activeJobId ?? this.activeJobId),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is SessionSnapshot &&
        other.tokens == tokens &&
        other.activeJobId == activeJobId;
  }

  @override
  int get hashCode => Object.hash(tokens, activeJobId);
}
