import 'package:flutter_test/flutter_test.dart';

import 'package:wodoo_app/main.dart';

void main() {
  testWidgets('Wodoo app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WodooApp());

    // Verify that the app starts with login screen
    expect(find.text('Wodoo'), findsOneWidget);
    expect(find.text('CrossFit Antrenman Programı'), findsOneWidget);
  });
}