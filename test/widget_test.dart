import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_final_project_22k5037/core/di/injection.dart';
import 'package:flutter_final_project_22k5037/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupDependencies();
  });

  testWidgets('App builds and shows MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartTravelApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
