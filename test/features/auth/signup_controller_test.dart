import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/core/network/api_response.dart';
import 'package:planit_flutter/features/auth/domain/model/auth_user.dart';
import 'package:planit_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:planit_flutter/features/auth/presentation/controllers/signup_controller.dart';
import 'package:planit_flutter/shared/models/api_field_error.dart';

void main() {
  group('SignupController', () {
    test('validates local fields before submitting', () async {
      final repository = _FakeAuthRepository();
      final controller = SignupController(repository);

      final result = await controller.submit(
        name: '',
        email: 'wrong',
        password: '123',
      );

      expect(result, isFalse);
      expect(repository.signupCallCount, 0);
      expect(controller.state.nameError, '이름을 입력해주세요.');
      expect(controller.state.emailError, '올바른 이메일 형식을 입력해주세요.');
      expect(controller.state.passwordError, '비밀번호는 8자 이상이어야 합니다.');
    });

    test('maps server field errors onto matching fields', () async {
      final repository = _FakeAuthRepository();
      repository.signupError = const ApiErrorException(
        code: 'VALIDATION_ERROR',
        message: '입력값을 확인해주세요.',
        fieldErrors: [
          ApiFieldError(field: 'name', reason: '이름을 다시 확인해주세요.'),
          ApiFieldError(field: 'email', reason: '이미 사용 중인 이메일입니다.'),
          ApiFieldError(field: 'password', reason: '비밀번호 형식을 다시 확인해주세요.'),
        ],
      );
      final controller = SignupController(repository);

      final result = await controller.submit(
        name: '김민지',
        email: 'minji@example.com',
        password: 'P@ssw0rd!',
      );

      expect(result, isFalse);
      expect(controller.state.nameError, '이름을 다시 확인해주세요.');
      expect(controller.state.emailError, '이미 사용 중인 이메일입니다.');
      expect(controller.state.passwordError, '비밀번호 형식을 다시 확인해주세요.');
      expect(controller.state.formError, isNull);
    });

    test('surfaces non-field api errors as form error', () async {
      final repository = _FakeAuthRepository();
      repository.signupError = const ApiErrorException(
        code: 'CONFLICT',
        message: '회원가입을 완료할 수 없습니다.',
      );
      final controller = SignupController(repository);

      final result = await controller.submit(
        name: '김민지',
        email: 'minji@example.com',
        password: 'P@ssw0rd!',
      );

      expect(result, isFalse);
      expect(controller.state.formError, '회원가입을 완료할 수 없습니다.');
      expect(controller.state.nameError, isNull);
      expect(controller.state.emailError, isNull);
      expect(controller.state.passwordError, isNull);
    });

    test('sets a fallback form error for unexpected exceptions', () async {
      final repository = _FakeAuthRepository();
      repository.signupError = StateError('boom');
      final controller = SignupController(repository);

      final result = await controller.submit(
        name: '김민지',
        email: 'minji@example.com',
        password: 'P@ssw0rd!',
      );

      expect(result, isFalse);
      expect(controller.state.formError, '잠시 후 다시 시도해주세요.');
    });

    test('sets success state after a successful signup', () async {
      final repository = _FakeAuthRepository();
      final controller = SignupController(repository);

      final result = await controller.submit(
        name: '김민지',
        email: 'minji@example.com',
        password: 'P@ssw0rd!',
      );

      expect(result, isTrue);
      expect(repository.signupCallCount, 1);
      expect(controller.state.isSuccess, isTrue);
      expect(controller.state.formError, isNull);
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  int signupCallCount = 0;
  Object? signupError;

  @override
  Future<AuthUser> login({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    signupCallCount += 1;

    final error = signupError;
    if (error != null) {
      throw error;
    }

    return const AuthUser(
      id: 1,
      name: '김민지',
      email: 'minji@example.com',
      onboardingCompleted: false,
    );
  }
}
