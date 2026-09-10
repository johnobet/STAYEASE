import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stayease/core/theme/app_theme.dart';
import 'package:stayease/core/widgets/buttons/app_button.dart';

// Note: this deliberately does NOT pump `StayEaseApp` from main.dart, since
// that calls Firebase.initializeApp() and needs platform channels that
// aren't available in a plain widget test. Once phase 11 (Testing) sets up
// a Firebase emulator + mocks, add integration tests that cover AuthGate's
// routing logic. For now this just guards the design-system building
// blocks against basic regressions.
void main() {
  testWidgets('AppButton renders its label and responds to taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: AppButton(
              label: 'Reserve room',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Reserve room'), findsOneWidget);

    await tester.tap(find.text('Reserve room'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('Disabled AppButton does not respond to taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: AppButton(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Disabled'));
    await tester.pumpAndSettle();

    expect(tapped, isFalse);
  });
}