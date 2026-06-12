import 'package:flutter_test/flutter_test.dart';
import 'package:planit_flutter/main.dart';

void main() {
  testWidgets('App starts on the splash route', (tester) async {
    await tester.pumpWidget(const PlanItApp());

    expect(find.text('Splash'), findsOneWidget);
    expect(find.text('Preparing your study plan...'), findsOneWidget);
  });
}
