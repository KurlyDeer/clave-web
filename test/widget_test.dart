import 'package:english_bridge/app.dart';
import 'package:english_bridge/features/welcome/welcome_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:english_bridge/core/providers/shared_preferences_provider.dart';

void main() {
  testWidgets('Welcome screen renders app name', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const EnglishBridgeApp(home: WelcomeScreen()),
      ),
    );
    expect(find.text('English Bridge'), findsOneWidget);
  });
}
