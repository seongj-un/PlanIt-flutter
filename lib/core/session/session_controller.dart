import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/my_page/domain/model/user_profile.dart';
import 'session_repository.dart';
import 'session_snapshot.dart';
import 'session_tokens.dart';

class SessionController extends StateNotifier<SessionSnapshot> {
  SessionController(this._repository) : super(const SessionSnapshot());

  final SessionRepository _repository;

  Future<void> clear() async {
    await _repository.clear();
    state = const SessionSnapshot(status: SessionStatus.unauthenticated);
  }

  Future<SessionSnapshot> restore() async {
    final snapshot = await _repository.restore();
    state = snapshot.copyWith(
      status: snapshot.tokens == null
          ? SessionStatus.unauthenticated
          : SessionStatus.restoring,
      clearUserProfile: true,
    );
    return snapshot;
  }

  Future<SessionSnapshot> restoreAuthenticatedSession({
    required Future<UserProfile> Function() fetchCurrentUser,
  }) async {
    state = state.copyWith(
      status: SessionStatus.restoring,
      clearUserProfile: true,
    );

    final snapshot = await _repository.restore();
    if (snapshot.tokens == null) {
      state = const SessionSnapshot(status: SessionStatus.unauthenticated);
      return state;
    }

    state = snapshot.copyWith(
      status: SessionStatus.restoring,
      clearUserProfile: true,
    );

    try {
      final userProfile = await fetchCurrentUser();
      final latestTokens = await _repository.readTokens();

      state = SessionSnapshot(
        tokens: latestTokens ?? snapshot.tokens,
        activeJobId: snapshot.activeJobId,
        userProfile: userProfile,
        status: SessionStatus.authenticated,
      );
    } catch (_) {
      await _repository.clear();
      state = const SessionSnapshot(status: SessionStatus.unauthenticated);
    }

    return state;
  }

  Future<void> save({
    required SessionTokens tokens,
    String? activeJobId,
    UserProfile? userProfile,
  }) async {
    await _repository.save(tokens: tokens, activeJobId: activeJobId);
    final nextUserProfile = userProfile ?? state.userProfile;
    state = SessionSnapshot(
      tokens: tokens,
      activeJobId: activeJobId,
      userProfile: nextUserProfile,
      status: nextUserProfile == null
          ? SessionStatus.restoring
          : SessionStatus.authenticated,
    );
  }

  Future<void> saveActiveJobId(String jobId) async {
    await _repository.saveActiveJobId(jobId);
    state = state.copyWith(activeJobId: jobId);
  }

  Future<void> updateTokens(SessionTokens tokens) async {
    await _repository.saveTokens(tokens);
    state = state.copyWith(tokens: tokens);
  }
}
