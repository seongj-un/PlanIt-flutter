import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/session/session_controller.dart';
import '../../../my_page/data/repository/user_repository_impl.dart';
import '../../../my_page/domain/model/user_profile.dart';
import '../../../my_page/domain/repository/user_repository.dart';
import '../../data/repository/plan_generation_repository_impl.dart';
import '../../domain/model/plan_generation_input.dart';
import '../../domain/model/plan_generation_status.dart';
import '../../domain/repository/plan_generation_repository.dart';

const _planGenerationErrorMessage = '플랜 생성 중 문제가 발생했어요.';
const _missingPlanGenerationInputMessage = '플랜 생성 요청 정보를 찾을 수 없어요.';

final planGenerationControllerProvider = StateNotifierProvider<
    PlanGenerationController,
    PlanGenerationState>((ref) {
  return PlanGenerationController(
    repository: ref.watch(planGenerationRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
    sessionController: ref.watch(sessionControllerNotifierProvider),
  );
});

class PlanGenerationController extends StateNotifier<PlanGenerationState> {
  PlanGenerationController({
    required PlanGenerationRepository repository,
    required UserRepository userRepository,
    required SessionController sessionController,
    this.pollInterval = const Duration(seconds: 2),
  }) : _repository = repository,
       _userRepository = userRepository,
       _sessionController = sessionController,
       super(const PlanGenerationState());

  final PlanGenerationRepository _repository;
  final UserRepository _userRepository;
  final SessionController _sessionController;
  final Duration pollInterval;

  Timer? _pollTimer;
  bool _initialized = false;

  Future<void> initialize({PlanGenerationInput? initialInput}) async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    final activeJobId = _sessionController.state.activeJobId;
    if (activeJobId != null && activeJobId.isNotEmpty) {
      state = state.copyWith(
        phase: PlanGenerationPhase.polling,
        jobId: activeJobId,
        message: '진행 중인 플랜 생성을 이어받고 있어요.',
        progressPercent: 0,
        clearErrorMessage: true,
      );
      _startPolling(activeJobId);
      return;
    }

    if (initialInput == null) {
      state = state.copyWith(
        phase: PlanGenerationPhase.failed,
        errorMessage: _missingPlanGenerationInputMessage,
        message: _missingPlanGenerationInputMessage,
      );
      return;
    }

    state = state.copyWith(
      phase: PlanGenerationPhase.starting,
      message: '학습 플랜 생성을 시작하고 있어요.',
      progressPercent: 0,
      clearErrorMessage: true,
    );

    try {
      final createdJob = await _repository.createJob(initialInput);
      await _sessionController.saveActiveJobId(createdJob.jobId);
      await _handleStatus(createdJob);
      if (createdJob.isInProgress) {
        _startPolling(createdJob.jobId);
      }
    } on ApiErrorException catch (error) {
      await _sessionController.clearActiveJobId();
      state = state.copyWith(
        phase: PlanGenerationPhase.failed,
        errorMessage: error.message,
        message: error.message,
      );
    } catch (_) {
      await _sessionController.clearActiveJobId();
      state = state.copyWith(
        phase: PlanGenerationPhase.failed,
        errorMessage: _planGenerationErrorMessage,
        message: _planGenerationErrorMessage,
      );
    }
  }

  Future<void> _pollStatus(String jobId) async {
    try {
      final status = await _repository.fetchStatus(jobId);
      await _handleStatus(status);
    } on ApiErrorException catch (error) {
      _pollTimer?.cancel();
      await _sessionController.clearActiveJobId();
      state = state.copyWith(
        phase: PlanGenerationPhase.failed,
        errorMessage: error.message,
        message: error.message,
      );
    } catch (_) {
      _pollTimer?.cancel();
      await _sessionController.clearActiveJobId();
      state = state.copyWith(
        phase: PlanGenerationPhase.failed,
        errorMessage: _planGenerationErrorMessage,
        message: _planGenerationErrorMessage,
      );
    }
  }

  Future<void> _handleStatus(PlanGenerationStatus status) async {
    if (status.isInProgress) {
      state = state.copyWith(
        phase: PlanGenerationPhase.polling,
        jobId: status.jobId,
        progressPercent: status.progressPercent ?? 0,
        message: status.message ?? '오늘 할 플랜을 계산하고 있어요.',
        clearErrorMessage: true,
      );
      return;
    }

    if (status.isCompleted) {
      _pollTimer?.cancel();
      final userProfile = await _refreshCurrentUser();
      await _sessionController.clearActiveJobId();
      await _persistUserProfile(userProfile);
      state = state.copyWith(
        phase: PlanGenerationPhase.completed,
        jobId: status.jobId,
        progressPercent: 100,
        message: status.message ?? '오늘 플랜이 준비됐어요.',
        clearErrorMessage: true,
      );
      return;
    }

    _pollTimer?.cancel();
    await _sessionController.clearActiveJobId();
    state = state.copyWith(
      phase: PlanGenerationPhase.failed,
      jobId: status.jobId,
      progressPercent: status.progressPercent ?? 100,
      errorMessage: status.message ?? _planGenerationErrorMessage,
      message: status.message ?? _planGenerationErrorMessage,
    );
  }

  Future<UserProfile> _refreshCurrentUser() {
    return _userRepository.getCurrentUser();
  }

  Future<void> _persistUserProfile(UserProfile userProfile) async {
    final tokens = _sessionController.state.tokens;
    if (tokens == null) {
      return;
    }

    await _sessionController.save(tokens: tokens, userProfile: userProfile);
  }

  void _startPolling(String jobId) {
    _pollTimer?.cancel();
    unawaited(_pollStatus(jobId));
    _pollTimer = Timer.periodic(pollInterval, (_) {
      unawaited(_pollStatus(jobId));
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

enum PlanGenerationPhase { idle, starting, polling, completed, failed }

class PlanGenerationState {
  const PlanGenerationState({
    this.phase = PlanGenerationPhase.idle,
    this.jobId,
    this.progressPercent,
    this.message,
    this.errorMessage,
  });

  final PlanGenerationPhase phase;
  final String? jobId;
  final int? progressPercent;
  final String? message;
  final String? errorMessage;

  bool get isLoading =>
      phase == PlanGenerationPhase.starting ||
      phase == PlanGenerationPhase.polling;

  PlanGenerationState copyWith({
    PlanGenerationPhase? phase,
    String? jobId,
    int? progressPercent,
    String? message,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PlanGenerationState(
      phase: phase ?? this.phase,
      jobId: jobId ?? this.jobId,
      progressPercent: progressPercent ?? this.progressPercent,
      message: message ?? this.message,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}
