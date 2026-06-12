import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/repository/auth_repository.dart';

const _unexpectedAuthErrorMessage = '잠시 후 다시 시도해주세요.';

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, LoginFormState>((ref) {
      return LoginController(ref.watch(authRepositoryProvider));
    });

class LoginController extends StateNotifier<LoginFormState> {
  LoginController(this._repository) : super(const LoginFormState());

  final AuthRepository _repository;

  Future<bool> submit({required String email, required String password}) async {
    final normalizedEmail = email.trim();
    final nextState = LoginFormState(
      emailError: _validateEmail(normalizedEmail),
      passwordError: _validatePassword(password),
    );

    if (nextState.hasErrors) {
      state = nextState;
      return false;
    }

    state = const LoginFormState(isSubmitting: true);

    try {
      await _repository.login(email: normalizedEmail, password: password);
      state = const LoginFormState(isSuccess: true);
      return true;
    } on ApiErrorException catch (error) {
      state = LoginFormState.fromApiError(error);
      return false;
    } catch (_) {
      state = const LoginFormState(formError: _unexpectedAuthErrorMessage);
      return false;
    }
  }
}

class LoginFormState {
  const LoginFormState({
    this.emailError,
    this.passwordError,
    this.formError,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  factory LoginFormState.fromApiError(ApiErrorException error) {
    String? emailError;
    String? passwordError;

    for (final fieldError in error.fieldErrors) {
      switch (fieldError.field) {
        case 'email':
          emailError = fieldError.reason;
        case 'password':
          passwordError = fieldError.reason;
      }
    }

    final hasFieldError =
        (emailError != null && emailError.isNotEmpty) ||
        (passwordError != null && passwordError.isNotEmpty);

    return LoginFormState(
      emailError: emailError,
      passwordError: passwordError,
      formError: hasFieldError ? null : error.message,
    );
  }

  final String? emailError;
  final String? passwordError;
  final String? formError;
  final bool isSubmitting;
  final bool isSuccess;

  bool get hasErrors =>
      (emailError != null && emailError!.isNotEmpty) ||
      (passwordError != null && passwordError!.isNotEmpty);
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

  return null;
}
