import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/session/session_controller.dart';
import '../../../my_page/domain/model/user_profile.dart';
import '../../data/repository/exam_plan_repository_impl.dart';
import '../../domain/model/exam_plan_input.dart';
import '../../domain/model/exam_plan_result.dart';
import '../../domain/model/subject_scope_input.dart';
import '../../domain/repository/exam_plan_repository.dart';

const _examPlanErrorMessage = '잠시 후 다시 시도해주세요.';

final examPlanControllerProvider =
    StateNotifierProvider<ExamPlanController, ExamPlanFormState>((ref) {
      final session = ref.read(sessionControllerProvider).userProfile;
      return ExamPlanController(
        repository: ref.watch(examPlanRepositoryProvider),
        sessionController: ref.watch(sessionControllerNotifierProvider),
        currentUser: session,
      );
    });

final subjectScopeControllerProvider =
    StateNotifierProvider<SubjectScopeController, SubjectScopeFormState>((ref) {
      return SubjectScopeController(
        repository: ref.watch(examPlanRepositoryProvider),
      );
    });

class ExamPlanController extends StateNotifier<ExamPlanFormState> {
  ExamPlanController({
    required ExamPlanRepository repository,
    required SessionController sessionController,
    UserProfile? currentUser,
  }) : _repository = repository,
       _sessionController = sessionController,
       super(ExamPlanFormState.fromUserProfile(currentUser));

  final ExamPlanRepository _repository;
  final SessionController _sessionController;

  void setTargetExamType(String value) {
    state = state.copyWith(
      targetExamType: value,
      clearTargetExamTypeError: true,
      clearFormError: true,
    );
  }

  Future<bool> submit({
    required String targetExamLabel,
    required String examDate,
  }) async {
    final normalizedLabel = targetExamLabel.trim();
    final normalizedDate = examDate.trim();
    final validationState = state.copyWith(
      targetExamTypeError: _validateTargetExamType(state.targetExamType),
      targetExamLabelError: _validateTargetExamLabel(normalizedLabel),
      examDateError: _validateExamDate(normalizedDate),
      clearFormError: true,
      clearSuccess: true,
    );

    if (validationState.hasErrors) {
      state = validationState;
      return false;
    }

    state = validationState.copyWith(isSubmitting: true);

    try {
      final examPlanResult = await _repository.saveExamPlan(
        ExamPlanInput(
          targetExamType: state.targetExamType!,
          targetExamLabel: normalizedLabel,
          examDate: normalizedDate,
        ),
      );
      await _persistExamPlan(examPlanResult);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } on ApiErrorException catch (error) {
      state = ExamPlanFormState.fromApiError(error, baseState: state);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        formError: _examPlanErrorMessage,
      );
      return false;
    }
  }

  Future<void> _persistExamPlan(ExamPlanResult result) {
    final tokens = _sessionController.state.tokens;
    final currentUser = _sessionController.state.userProfile;
    if (tokens == null || currentUser == null) {
      return Future.value();
    }

    // The exam-plan endpoint returns only the exam fields, so preserve the
    // cached user identity and merge just those fields into the session.
    final mergedUserProfile = UserProfile(
      id: currentUser.id,
      name: currentUser.name,
      email: currentUser.email,
      age: currentUser.age,
      schoolLevel: currentUser.schoolLevel,
      targetExamType: result.targetExamType ?? currentUser.targetExamType,
      targetExamLabel: result.targetExamLabel ?? currentUser.targetExamLabel,
      examDate: result.examDate ?? currentUser.examDate,
      usualStudyHoursPerDay: currentUser.usualStudyHoursPerDay,
      preferredStudyMethod: currentUser.preferredStudyMethod,
      sproutCount: currentUser.sproutCount,
      attendanceStreakDays: currentUser.attendanceStreakDays,
      onboardingCompleted: currentUser.onboardingCompleted,
    );

    return _sessionController.save(
      tokens: tokens,
      activeJobId: _sessionController.state.activeJobId,
      userProfile: mergedUserProfile,
    );
  }
}

class SubjectScopeController extends StateNotifier<SubjectScopeFormState> {
  SubjectScopeController({required ExamPlanRepository repository})
    : _repository = repository,
      super(const SubjectScopeFormState());

  final ExamPlanRepository _repository;

  Future<bool> submit(List<SubjectScopeInput> inputs) async {
    final normalizedInputs = inputs
        .where(
          (input) =>
              input.subjectName.trim().isNotEmpty ||
              input.examRange.trim().isNotEmpty ||
              input.preferredMethodNote.trim().isNotEmpty,
        )
        .toList();

    if (normalizedInputs.isEmpty) {
      state = const SubjectScopeFormState(formError: '과목 범위를 하나 이상 입력해주세요.');
      return false;
    }

    for (final input in normalizedInputs) {
      if (input.subjectName.trim().isEmpty ||
          input.examRange.trim().isEmpty ||
          input.preferredMethodNote.trim().isEmpty ||
          input.priority.trim().isEmpty) {
        state = const SubjectScopeFormState(
          formError: '각 과목의 범위, 방법, 우선순위를 모두 입력해주세요.',
        );
        return false;
      }
    }

    state = const SubjectScopeFormState(isSubmitting: true);

    try {
      await _repository.saveSubjectScopes(normalizedInputs);
      state = const SubjectScopeFormState(isSuccess: true);
      return true;
    } on ApiErrorException catch (error) {
      state = SubjectScopeFormState(formError: error.message);
      return false;
    } catch (_) {
      state = const SubjectScopeFormState(formError: _examPlanErrorMessage);
      return false;
    }
  }
}

class ExamPlanFormState {
  const ExamPlanFormState({
    this.targetExamType,
    this.initialTargetExamLabel = '',
    this.initialExamDate = '',
    this.targetExamTypeError,
    this.targetExamLabelError,
    this.examDateError,
    this.formError,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  factory ExamPlanFormState.fromApiError(
    ApiErrorException error, {
    required ExamPlanFormState baseState,
  }) {
    String? targetExamTypeError;
    String? targetExamLabelError;
    String? examDateError;

    for (final fieldError in error.fieldErrors) {
      switch (fieldError.field) {
        case 'targetExamType':
          targetExamTypeError = fieldError.reason;
        case 'targetExamLabel':
          targetExamLabelError = fieldError.reason;
        case 'examDate':
          examDateError = fieldError.reason;
      }
    }

    final hasFieldError = [
      targetExamTypeError,
      targetExamLabelError,
      examDateError,
    ].any((value) => value != null && value.isNotEmpty);

    return baseState.copyWith(
      targetExamTypeError: targetExamTypeError,
      targetExamLabelError: targetExamLabelError,
      examDateError: examDateError,
      formError: hasFieldError ? null : error.message,
      isSubmitting: false,
    );
  }

  factory ExamPlanFormState.fromUserProfile(UserProfile? userProfile) {
    return ExamPlanFormState(
      targetExamType: userProfile?.targetExamType,
      initialTargetExamLabel: userProfile?.targetExamLabel ?? '',
      initialExamDate: userProfile?.examDate == null
          ? ''
          : _formatDate(userProfile!.examDate!),
    );
  }

  final String? targetExamType;
  final String initialTargetExamLabel;
  final String initialExamDate;
  final String? targetExamTypeError;
  final String? targetExamLabelError;
  final String? examDateError;
  final String? formError;
  final bool isSubmitting;
  final bool isSuccess;

  bool get hasErrors =>
      (targetExamTypeError != null && targetExamTypeError!.isNotEmpty) ||
      (targetExamLabelError != null && targetExamLabelError!.isNotEmpty) ||
      (examDateError != null && examDateError!.isNotEmpty);

  ExamPlanFormState copyWith({
    String? targetExamType,
    String? initialTargetExamLabel,
    String? initialExamDate,
    String? targetExamTypeError,
    String? targetExamLabelError,
    String? examDateError,
    String? formError,
    bool clearTargetExamTypeError = false,
    bool clearFormError = false,
    bool clearSuccess = false,
    bool? isSubmitting,
    bool? isSuccess,
  }) {
    return ExamPlanFormState(
      targetExamType: targetExamType ?? this.targetExamType,
      initialTargetExamLabel:
          initialTargetExamLabel ?? this.initialTargetExamLabel,
      initialExamDate: initialExamDate ?? this.initialExamDate,
      targetExamTypeError: clearTargetExamTypeError
          ? null
          : (targetExamTypeError ?? this.targetExamTypeError),
      targetExamLabelError: targetExamLabelError ?? this.targetExamLabelError,
      examDateError: examDateError ?? this.examDateError,
      formError: clearFormError ? null : (formError ?? this.formError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: clearSuccess ? false : (isSuccess ?? this.isSuccess),
    );
  }
}

class SubjectScopeFormState {
  const SubjectScopeFormState({
    this.formError,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  final String? formError;
  final bool isSubmitting;
  final bool isSuccess;
}

String _formatDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String? _validateExamDate(String value) {
  if (value.isEmpty) {
    return '시험 날짜를 입력해주세요.';
  }
  if (DateTime.tryParse(value) == null) {
    return '날짜는 yyyy-MM-dd 형식으로 입력해주세요.';
  }
  return null;
}

String? _validateTargetExamLabel(String value) {
  if (value.isEmpty) {
    return '시험 이름을 입력해주세요.';
  }
  return null;
}

String? _validateTargetExamType(String? value) {
  if (value == null || value.isEmpty) {
    return '시험 종류를 선택해주세요.';
  }
  return null;
}
