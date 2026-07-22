import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/session/session_controller.dart';
import '../../../my_page/domain/model/user_profile.dart';
import '../../data/repository/study_profile_repository_impl.dart';
import '../../domain/model/study_profile_input.dart';
import '../../domain/repository/study_profile_repository.dart';

const _studyProfileErrorMessage = '잠시 후 다시 시도해주세요.';

final studyProfileControllerProvider =
    StateNotifierProvider<StudyProfileController, StudyProfileFormState>((ref) {
      final session = ref.read(sessionControllerProvider).userProfile;
      return StudyProfileController(
        repository: ref.watch(studyProfileRepositoryProvider),
        sessionController: ref.watch(sessionControllerNotifierProvider),
        currentUser: session,
      );
    });

class StudyProfileController extends StateNotifier<StudyProfileFormState> {
  StudyProfileController({
    required StudyProfileRepository repository,
    required SessionController sessionController,
    UserProfile? currentUser,
  }) : _repository = repository,
       _sessionController = sessionController,
       super(StudyProfileFormState.fromUserProfile(currentUser));

  final StudyProfileRepository _repository;
  final SessionController _sessionController;

  void setPreferredStudyMethod(String value) {
    state = state.copyWith(
      preferredStudyMethod: value,
      clearPreferredMethodError: true,
      clearFormError: true,
    );
  }

  Future<bool> submit({required String usualStudyHoursText}) async {
    final studyHours = int.tryParse(usualStudyHoursText.trim());
    final validationState = state.copyWith(
      studyHoursError: _validateStudyHours(
        usualStudyHoursText.trim(),
        studyHours,
      ),
      preferredMethodError: _validatePreferredMethod(
        state.preferredStudyMethod,
      ),
      clearFormError: true,
      clearSuccess: true,
    );

    if (validationState.hasErrors || studyHours == null) {
      state = validationState;
      return false;
    }

    state = validationState.copyWith(isSubmitting: true);

    try {
      final userProfile = await _repository.saveStudyProfile(
        StudyProfileInput(
          usualStudyHoursPerDay: studyHours,
          preferredStudyMethod: state.preferredStudyMethod!,
        ),
      );
      await _persistUserProfile(userProfile);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } on ApiErrorException catch (error) {
      state = StudyProfileFormState.fromApiError(error, baseState: state);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        formError: _studyProfileErrorMessage,
      );
      return false;
    }
  }

  Future<void> _persistUserProfile(UserProfile userProfile) {
    final tokens = _sessionController.state.tokens;
    if (tokens == null) {
      return Future.value();
    }

    return _sessionController.save(
      tokens: tokens,
      activeJobId: _sessionController.state.activeJobId,
      userProfile: userProfile,
    );
  }
}

class StudyProfileFormState {
  const StudyProfileFormState({
    this.preferredStudyMethod,
    this.initialStudyHoursText = '',
    this.studyHoursError,
    this.preferredMethodError,
    this.formError,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  factory StudyProfileFormState.fromApiError(
    ApiErrorException error, {
    required StudyProfileFormState baseState,
  }) {
    String? studyHoursError;
    String? preferredMethodError;

    for (final fieldError in error.fieldErrors) {
      switch (fieldError.field) {
        case 'usualStudyHoursPerDay':
          studyHoursError = fieldError.reason;
        case 'preferredStudyMethod':
          preferredMethodError = fieldError.reason;
      }
    }

    final hasFieldError = [
      studyHoursError,
      preferredMethodError,
    ].any((value) => value != null && value.isNotEmpty);

    return baseState.copyWith(
      studyHoursError: studyHoursError,
      preferredMethodError: preferredMethodError,
      formError: hasFieldError ? null : error.message,
      isSubmitting: false,
    );
  }

  factory StudyProfileFormState.fromUserProfile(UserProfile? userProfile) {
    return StudyProfileFormState(
      preferredStudyMethod: userProfile?.preferredStudyMethod,
      initialStudyHoursText:
          userProfile?.usualStudyHoursPerDay?.toString() ?? '',
    );
  }

  final String? preferredStudyMethod;
  final String initialStudyHoursText;
  final String? studyHoursError;
  final String? preferredMethodError;
  final String? formError;
  final bool isSubmitting;
  final bool isSuccess;

  bool get hasErrors =>
      (studyHoursError != null && studyHoursError!.isNotEmpty) ||
      (preferredMethodError != null && preferredMethodError!.isNotEmpty);

  StudyProfileFormState copyWith({
    String? preferredStudyMethod,
    String? initialStudyHoursText,
    String? studyHoursError,
    String? preferredMethodError,
    String? formError,
    bool clearFormError = false,
    bool clearPreferredMethodError = false,
    bool clearSuccess = false,
    bool? isSubmitting,
    bool? isSuccess,
  }) {
    return StudyProfileFormState(
      preferredStudyMethod: preferredStudyMethod ?? this.preferredStudyMethod,
      initialStudyHoursText:
          initialStudyHoursText ?? this.initialStudyHoursText,
      studyHoursError: studyHoursError ?? this.studyHoursError,
      preferredMethodError: clearPreferredMethodError
          ? null
          : (preferredMethodError ?? this.preferredMethodError),
      formError: clearFormError ? null : (formError ?? this.formError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: clearSuccess ? false : (isSuccess ?? this.isSuccess),
    );
  }
}

String? _validatePreferredMethod(String? value) {
  if (value == null || value.isEmpty) {
    return '선호 학습 방식을 선택해주세요.';
  }
  return null;
}

String? _validateStudyHours(String value, int? parsed) {
  if (value.isEmpty) {
    return '하루 공부 시간을 입력해주세요.';
  }
  if (parsed == null || parsed <= 0) {
    return '올바른 공부 시간을 입력해주세요.';
  }
  return null;
}
