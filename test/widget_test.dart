import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sum_academy/app/app.dart';

void main() {
  testWidgets('Splash screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SumAcademyApp());

    expect(find.text('Sum Academy LMS'), findsOneWidget);
    expect(
      find.text('Developed by Alee (TryUnity Solutions)'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('splash_loader')), findsOneWidget);
  });
}
