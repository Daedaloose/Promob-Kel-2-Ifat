import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:peaceful_mind/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PeacefulMindApp());

    // Verify that the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}