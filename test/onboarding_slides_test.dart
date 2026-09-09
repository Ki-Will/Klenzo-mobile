import 'package:flutter_test/flutter_test.dart';
import 'package:klenzo_mobile/features/auth/models/onboarding_slide.dart';
import 'package:klenzo_mobile/core/storage/secure_storage.dart';

void main() {
  group('Onboarding slides', () {
    test('carousel has SMS, split, AI, and P2P slides', () {
      expect(
        kOnboardingSlides.map((s) => s.tab).toList(),
        [
          'SMS Auto-Tracking',
          'Split Expenses',
          'AI Financial Insights',
          'Instant P2P Transfers',
        ],
      );
    });

    test('wrapIndex cycles the PageView indicator', () {
      expect(wrapIndex(0, -1, 4), 3);
      expect(wrapIndex(3, 1, 4), 0);
      expect(wrapIndex(1, 1, 4), 2);
      expect(wrapIndex(0, 0, 0), 0);
    });
  });

  group('Secure storage keys', () {
    test('uses namespaced kz. keys (no generic token names)', () {
      expect(SecureStorageKeys.accessToken, 'kz.access_token');
      expect(SecureStorageKeys.refreshToken, 'kz.refresh_token');
      expect(SecureStorageKeys.pinSetup, 'kz.is_pin_setup');
      expect(SecureStorageKeys.onboardingSeen, 'kz.onboarding_seen');
    });
  });
}
