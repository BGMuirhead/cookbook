import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookbook_app/main.dart';

void main() {
  testWidgets('CookbookApp builds without crashing', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: CookbookApp()));

    // Verify that the app title is displayed.
    expect(find.text('Cookbook'), findsOneWidget);
  });
}