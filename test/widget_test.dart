import 'package:flutter_test/flutter_test.dart';
import 'package:audioview_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Just verify the app builds without crashing
    // We can add more meaningful tests later
  });
}
