import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/core/network/api_response.dart';
import 'package:planit_flutter/features/auth/data/repository/auth_repository_impl.dart';
import 'package:planit_flutter/features/auth/domain/model/auth_user.dart';
import 'package:planit_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:planit_flutter/features/auth/presentation/pages/signup_page.dart';
import 'package:planit_flutter/shared/models/api_field_error.dart';

void main() {
  testWidgets('renders server field errors below the matching signup fields', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    repository.signupError = const ApiErrorException(
      code: 'VALIDATION_ERROR',
      message: '입력값을 확인해주세요.',
      fieldErrors: [
        ApiFieldError(field: 'name', reason: '이름을 입력해주세요.'),
        ApiFieldError(field: 'email', reason: '이미 사용 중인 이메일입니다.'),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: SignUpPage()),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), '김민지');
    await tester.enterText(find.byType(TextField).at(1), 'minji@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'P@ssw0rd!');
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('이름을 입력해주세요.'), findsOneWidget);
    expect(find.text('이미 사용 중인 이메일입니다.'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
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
    final error = signupError;
    if (error != null) {
      throw error;
    }

    return const AuthUser(id: 1, name: '김민지', onboardingCompleted: false);
  }
}
