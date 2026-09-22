import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:monolith/main.dart';

void main() {
  testWidgets('App boots to the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MonolithApp()));
    await tester.pumpAndSettle();

    expect(find.text('Monolith'), findsWidgets);
  });
}
