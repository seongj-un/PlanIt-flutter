import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/core/network/api_response.dart';
import 'package:planit_flutter/features/auth/domain/model/auth_user.dart';
import 'package:planit_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:planit_flutter/features/auth/presentation/controllers/login_controller.dart';
import 'package:planit_flutter/shared/models/api_field_error.dart';

void main() {
  group('LoginController', () {
    test('validates email and password before submitting', () async {
      final repository = _FakeAuthRepository();
      final controller = LoginController(repository);

      final result = await controller.submit(email: '', password: '');

      expect(result, isFalse);
      expect(repository.loginCallCount, 0);
      expect(controller.state.emailError, '이메일을 입력해주세요.');
      expect(controller.state.passwordError, '비밀번호를 입력해주세요.');
      expect(controller.state.isSubmitting, isFalse);
    });

    test('maps server field errors onto matching fields', () async {
      final repository = _FakeAuthRepository();
      repository.loginError = const ApiErrorException(
        code: 'VALIDATION_ERROR',
        message: '입력값을 확인해주세요.',
        fieldErrors: [
          ApiFieldError(field: 'email', reason: '등록되지 않은 이메일입니다.'),
          ApiFieldError(field: 'password', reason: '비밀번호가 올바르지 않습니다.'),
        ],
      );
      final controller = LoginController(repository);

      final result = await controller.submit(
        email: 'minji@example.com',
        password: 'wrong-password',
      );

      expect(result, isFalse);
      expect(controller.state.emailError, '등록되지 않은 이메일입니다.');
      expect(controller.state.passwordError, '비밀번호가 올바르지 않습니다.');
      expect(controller.state.formError, isNull);
      expect(controller.state.isSubmitting, isFalse);
    });

    test('sets success state after a successful login', () async {
      final repository = _FakeAuthRepository();
      final controller = LoginController(repository);

      final result = await controller.submit(
        email: 'minji@example.com',
        password: 'P@ssw0rd!',
      );

      expect(result, isTrue);
      expect(repository.loginCallCount, 1);
      expect(controller.state.isSuccess, isTrue);
      expect(controller.state.formError, isNull);
      expect(controller.state.emailError, isNull);
      expect(controller.state.passwordError, isNull);
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  int loginCallCount = 0;
  Object? loginError;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    loginCallCount += 1;

    final error = loginError;
    if (error != null) {
      throw error;
    }

    return const AuthUser(
      id: 1,
      name: '김민지',
      email: 'minji@example.com',
      onboardingCompleted: true,
    );
  }

  @override
  Future<AuthUser> signup({
    required String name,
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }
}
