// Smoke test: app boots to splash then navigates to Home.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stack_tower/app.dart';

void main() {
  testWidgets('App boots and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: StackTowerApp()));
    await tester.pump();

    expect(find.text('Stack Tower'), findsOneWidget);
  });
}
