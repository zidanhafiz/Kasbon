import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kasbon_pos/main.dart';

void main() {
  testWidgets('App loads and displays dashboard', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: KasbonApp(),
      ),
    );

    // Wait for the app to load
    await tester.pumpAndSettle();

    // Verify that the dashboard screen is displayed
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
