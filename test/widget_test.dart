import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_code_generator/main.dart';

void main() {
  testWidgets('Enterprise QR Code Generator smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EnterpriseQRCodeApp());

    // Verify that our app title/heading is present.
    expect(find.text('Enterprise QR Code Generator'), findsOneWidget);
  });
}
