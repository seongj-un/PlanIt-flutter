import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/session/session_controller.dart';
import '../../data/repository/user_repository_impl.dart';
import '../../domain/model/user_profile.dart';
import '../../domain/repository/user_repository.dart';

const _myPageErrorMessage = '마이페이지 정보를 처리하지 못했어요.';

final myPageControllerProvider =
    StateNotifierProvider<MyPageController, MyPageState>((ref) {
      return MyPageController(
        repository: ref.watch(userRepositoryProvider),
        sessionController: ref.watch(sessionControllerNotifierProvider),
      );
    });

class MyPageController extends StateNotifier<MyPageState> {
  MyPageController({
    required UserRepository repository,
    required SessionController sessionController,
  }) : _repository = repository,
       _sessionController = sessionController,
       super(MyPageState(userProfile: sessionController.state.userProfile));

  final UserRepository _repository;
  final SessionController _sessionController;

  Future<void> load({bool forceRefresh = false}) async {
    if (state.isLoading) {
      return;
    }
    if (state.userProfile != null && !forceRefresh) {
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final userProfile = await _repository.getCurrentUser();
      await _persistUserProfile(userProfile);
      state = state.copyWith(
        isLoading: false,
        userProfile: userProfile,
        clearErrorMessage: true,
      );
    } on ApiErrorException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: _myPageErrorMessage);
    }
  }

  Future<bool> saveStudySettings({
    required String usualStudyHoursPerDayText,
    required String preferredStudyMethod,
  }) async {
    final studyHours = int.tryParse(usualStudyHoursPerDayText.trim());
    if (studyHours == null || studyHours <= 0 || preferredStudyMethod.isEmpty) {
      state = state.copyWith(
        errorMessage: '공부 시간과 학습 방식을 확인해주세요.',
        clearSuccessMessage: true,
      );
      return false;
    }

    state = state.copyWith(isSaving: true, clearErrorMessage: true, clearSuccessMessage: true);

    try {
      await _repository.updateStudySettings(
        usualStudyHoursPerDay: studyHours,
        preferredStudyMethod: preferredStudyMethod,
      );
      final refreshedUser = await _repository.getCurrentUser();
      await _persistUserProfile(refreshedUser);
      state = state.copyWith(
        isSaving: false,
        userProfile: refreshedUser,
        successMessage: '공부 설정을 저장했어요.',
      );
      return true;
    } on ApiErrorException catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(isSaving: false, errorMessage: _myPageErrorMessage);
      return false;
    }
  }

  Future<bool> saveNotificationSettings({
    required bool dailyReminderEnabled,
    required String dailyReminderTime,
  }) async {
    if (dailyReminderTime.trim().isEmpty) {
      state = state.copyWith(
        errorMessage: '알림 시간을 입력해주세요.',
        clearSuccessMessage: true,
      );
      return false;
    }

    state = state.copyWith(isSaving: true, clearErrorMessage: true, clearSuccessMessage: true);

    try {
      await _repository.updateNotificationSettings(
        dailyReminderEnabled: dailyReminderEnabled,
        dailyReminderTime: dailyReminderTime.trim(),
      );
      state = state.copyWith(
        isSaving: false,
        successMessage: '알림 설정을 저장했어요.',
      );
      return true;
    } on ApiErrorException catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(isSaving: false, errorMessage: _myPageErrorMessage);
      return false;
    }
  }

  Future<bool> saveAccountSettings({
    required String name,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final trimmedPassword = password.trim();
    if (trimmedName.isEmpty || trimmedPassword.isEmpty) {
      state = state.copyWith(
        errorMessage: '이름과 비밀번호를 모두 입력해주세요.',
        clearSuccessMessage: true,
      );
      return false;
    }

    state = state.copyWith(isSaving: true, clearErrorMessage: true, clearSuccessMessage: true);

    try {
      await _repository.updateAccount(name: trimmedName, password: trimmedPassword);
      final refreshedUser = await _repository.getCurrentUser();
      await _persistUserProfile(refreshedUser);
      state = state.copyWith(
        isSaving: false,
        userProfile: refreshedUser,
        successMessage: '계정 정보를 저장했어요.',
      );
      return true;
    } on ApiErrorException catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(isSaving: false, errorMessage: _myPageErrorMessage);
      return false;
    }
  }

  Future<bool> logout() async {
    final refreshToken = _sessionController.state.tokens?.refreshToken;
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _repository.logout(refreshToken);
      }
    } catch (_) {
      // Local session cleanup is the source of truth for logout UX.
    } finally {
      await _sessionController.clear();
    }

    return true;
  }

  Future<void> _persistUserProfile(UserProfile userProfile) async {
    final tokens = _sessionController.state.tokens;
    if (tokens == null) {
      return;
    }

    await _sessionController.save(
      tokens: tokens,
      activeJobId: _sessionController.state.activeJobId,
      userProfile: userProfile,
    );
  }
}

class MyPageState {
  const MyPageState({
    this.userProfile,
    this.errorMessage,
    this.successMessage,
    this.isLoading = false,
    this.isSaving = false,
  });

  final UserProfile? userProfile;
  final String? errorMessage;
  final String? successMessage;
  final bool isLoading;
  final bool isSaving;

  MyPageState copyWith({
    UserProfile? userProfile,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    bool? isLoading,
    bool? isSaving,
  }) {
    return MyPageState(
      userProfile: userProfile ?? this.userProfile,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
