import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planit_flutter/app/bootstrap/app_bootstrap.dart';
import 'package:planit_flutter/core/network/api_config.dart';
import 'package:planit_flutter/core/network/network_providers.dart';

void main() {
  test('AppRuntimeConfig.fromEnvironment requires API_BASE_URL', () {
    expect(AppRuntimeConfig.fromEnvironment, throwsStateError);
  });

  testWidgets('App starts on the splash route with injected runtime config', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRuntimeConfigProvider.overrideWithValue(
            const AppRuntimeConfig(
              apiConfig: ApiConfig(baseUrl: 'https://api.test'),
            ),
          ),
          sharedPreferencesInstanceProvider.overrideWithValue(
            sharedPreferences,
          ),
        ],
        child: const PlanItApp(),
      ),
    );

    expect(find.text('Splash'), findsOneWidget);
    expect(find.text('Preparing your study plan...'), findsOneWidget);
  });
}
