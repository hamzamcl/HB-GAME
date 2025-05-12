// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Toro-Vache game UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ToroVacheApp());

    // Verify that the title is displayed
    expect(find.text('Jeu Toro et Vache'), findsOneWidget);

    // Verify that the input field exists
    expect(find.byType(TextField), findsOneWidget);

    // Verify that the submit button exists
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Valider'), findsOneWidget);

    // Verify that the history text exists
    expect(find.text('Historique des tentatives :'), findsOneWidget);
  });
}
