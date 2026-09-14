import 'package:flutter_test/flutter_test.dart';

import 'package:shield_vpn/main.dart';

void main() {
  testWidgets('App boots to the home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const ShieldVpnApp());
    await tester.pump();

    // Home screen shows the app title and a connect prompt.
    expect(find.text('Shield'), findsOneWidget);
    expect(find.text('Tap to connect'), findsOneWidget);
  });
}
