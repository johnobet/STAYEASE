import 'package:flutter_test/flutter_test.dart';
import 'package:stayease/main.dart';

void main() {
  testWidgets('StayEase smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StayEaseApp());

    expect(find.text('StayEase'), findsOneWidget);
  });
}