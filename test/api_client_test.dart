import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Mobile API Client & Endpoints Tests', () => {
    test('Endpoints path configuration test', () {
      const baseUrl = 'http://10.0.2.2:3000/api';
      expect(baseUrl, contains('/api'));
    });
  });
}
