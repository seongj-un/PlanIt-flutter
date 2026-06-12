import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/core/network/api_response.dart';
import 'package:planit_flutter/features/auth/data/repository/auth_repository_impl.dart';
import 'package:planit_flutter/features/auth/domain/model/auth_user.dart';
import 'package:planit_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:planit_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:planit_flutter/shared/models/api_field_error.dart';

void main() {
  testWidgets('keeps route policy out of the login page on success', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'minji@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'P@ssw0rd!');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('로그인되었습니다.'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('renders server field errors below the matching login fields', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    repository.loginError = const ApiErrorException(
      code: 'VALIDATION_ERROR',
      message: '입력값을 확인해주세요.',
      fieldErrors: [
        ApiFieldError(field: 'email', reason: '이메일을 다시 확인해주세요.'),
        ApiFieldError(field: 'password', reason: '비밀번호를 다시 확인해주세요.'),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'minji@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('이메일을 다시 확인해주세요.'), findsOneWidget);
    expect(find.text('비밀번호를 다시 확인해주세요.'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  Object? loginError;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final error = loginError;
    if (error != null) {
      throw error;
    }

    return const AuthUser(id: 1, name: '김민지', onboardingCompleted: true);
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
