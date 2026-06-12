import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_repository.dart';
import 'session_snapshot.dart';
import 'session_tokens.dart';

class SessionController extends StateNotifier<SessionSnapshot> {
  SessionController(this._repository) : super(const SessionSnapshot());

  final SessionRepository _repository;

  Future<void> clear() async {
    await _repository.clear();
    state = const SessionSnapshot();
  }

  Future<SessionSnapshot> restore() async {
    final snapshot = await _repository.restore();
    state = snapshot;
    return snapshot;
  }

  Future<void> save({
    required SessionTokens tokens,
    String? activeJobId,
  }) async {
    await _repository.save(tokens: tokens, activeJobId: activeJobId);
    state = SessionSnapshot(tokens: tokens, activeJobId: activeJobId);
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
