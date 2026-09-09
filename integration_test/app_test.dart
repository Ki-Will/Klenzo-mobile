import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klenzo_mobile/app.dart';

void main() {
  group('Klenzo Mobile Application E2E Integration Suite', () => {
    testWidgets('App initializes and mounts widget tree cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: KlenzoApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Klenzo App Root renders
      expect(find.byType(KlenzoApp), findsOneWidget);
    });
  });
}
