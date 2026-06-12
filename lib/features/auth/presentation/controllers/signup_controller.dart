import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/repository/auth_repository.dart';

const _unexpectedAuthErrorMessage = '잠시 후 다시 시도해주세요.';

final signupControllerProvider =
    StateNotifierProvider.autoDispose<SignupController, SignupFormState>((ref) {
      return SignupController(ref.watch(authRepositoryProvider));
    });

class SignupController extends StateNotifier<SignupFormState> {
  SignupController(this._repository) : super(const SignupFormState());

  final AuthRepository _repository;

  Future<bool> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim();
    final nextState = SignupFormState(
      nameError: _validateName(normalizedName),
      emailError: _validateEmail(normalizedEmail),
      passwordError: _validatePassword(password),
    );

    if (nextState.hasErrors) {
      state = nextState;
      return false;
    }

    state = const SignupFormState(isSubmitting: true);

    try {
      await _repository.signup(
        name: normalizedName,
        email: normalizedEmail,
        password: password,
      );
      state = const SignupFormState(isSuccess: true);
      return true;
    } on ApiErrorException catch (error) {
      state = SignupFormState.fromApiError(error);
      return false;
    } catch (_) {
      state = const SignupFormState(formError: _unexpectedAuthErrorMessage);
      return false;
    }
  }
}

class SignupFormState {
  const SignupFormState({
    this.nameError,
    this.emailError,
    this.passwordError,
    this.formError,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  factory SignupFormState.fromApiError(ApiErrorException error) {
    String? nameError;
    String? emailError;
    String? passwordError;

    for (final fieldError in error.fieldErrors) {
      switch (fieldError.field) {
        case 'name':
          nameError = fieldError.reason;
        case 'email':
          emailError = fieldError.reason;
        case 'password':
          passwordError = fieldError.reason;
      }
    }

    final hasFieldError =
        (nameError != null && nameError.isNotEmpty) ||
        (emailError != null && emailError.isNotEmpty) ||
        (passwordError != null && passwordError.isNotEmpty);

    return SignupFormState(
      nameError: nameError,
      emailError: emailError,
      passwordError: passwordError,
      formError: hasFieldError ? null : error.message,
    );
  }

  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? formError;
  final bool isSubmitting;
  final bool isSuccess;

  bool get hasErrors =>
      (nameError != null && nameError!.isNotEmpty) ||
      (emailError != null && emailError!.isNotEmpty) ||
      (passwordError != null && passwordError!.isNotEmpty);
}

String? _validateName(String value) {
  if (value.isEmpty) {
    return '이름을 입력해주세요.';
  }

  return null;
}

String? _validateEmail(String value) {
  if (value.isEmpty) {
    return '이메일을 입력해주세요.';
  }

  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!pattern.hasMatch(value)) {
    return '올바른 이메일 형식을 입력해주세요.';
  }

  return null;
}

String? _validatePassword(String value) {
  if (value.isEmpty) {
    return '비밀번호를 입력해주세요.';
  }

  if (value.length < 8) {
    return '비밀번호는 8자 이상이어야 합니다.';
  }

  return null;
}
