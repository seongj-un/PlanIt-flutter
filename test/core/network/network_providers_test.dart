import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/app/bootstrap/app_bootstrap.dart';
import 'package:planit_flutter/core/network/api_config.dart';
import 'package:planit_flutter/core/network/network_providers.dart';
import 'package:planit_flutter/core/session/session_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'sessionControllerProvider exposes reactive SessionSnapshot state',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final preferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          appRuntimeConfigProvider.overrideWithValue(
            const AppRuntimeConfig(
              apiConfig: ApiConfig(baseUrl: 'https://api.test'),
            ),
          ),
          sharedPreferencesInstanceProvider.overrideWithValue(preferences),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(sessionControllerProvider);

      expect(state, isA<SessionSnapshot>());
    },
  );
}
