import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:control_funcionarios_flutter/main.dart';

void main() {
  testWidgets('MyApp widget builds without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds successfully
    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
