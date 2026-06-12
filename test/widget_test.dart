import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/app/bootstrap/app_bootstrap.dart';
import 'package:planit_flutter/core/network/api_config.dart';

void main() {
  test('AppRuntimeConfig.fromEnvironment requires API_BASE_URL', () {
    expect(AppRuntimeConfig.fromEnvironment, throwsStateError);
  });

  testWidgets('App starts on the splash route with injected runtime config', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRuntimeConfigProvider.overrideWithValue(
            const AppRuntimeConfig(
              apiConfig: ApiConfig(baseUrl: 'https://api.test'),
            ),
          ),
        ],
        child: const PlanItApp(),
      ),
    );

    expect(find.text('Splash'), findsOneWidget);
    expect(find.text('Preparing your study plan...'), findsOneWidget);
  });
}
