import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageKeys {
  static const accessToken = 'kz.access_token';
  static const refreshToken = 'kz.refresh_token';
  static const pinSetup = 'kz.is_pin_setup';
  static const onboardingSeen = 'kz.onboarding_seen';

  static const legacyAccessToken = 'access_token';
  static const legacyRefreshToken = 'refresh_token';
  static const legacyPinSetup = 'is_pin_setup';
}

class SecureStorage {
  static final _storage = FlutterSecureStorage();

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: SecureStorageKeys.accessToken, value: token);
    await _storage.delete(key: SecureStorageKeys.legacyAccessToken);
  }

  Future<String?> getAccessToken() async {
    return await _readWithLegacy(
      SecureStorageKeys.accessToken,
      SecureStorageKeys.legacyAccessToken,
    );
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: SecureStorageKeys.accessToken);
    await _storage.delete(key: SecureStorageKeys.legacyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: SecureStorageKeys.refreshToken, value: token);
    await _storage.delete(key: SecureStorageKeys.legacyRefreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _readWithLegacy(
      SecureStorageKeys.refreshToken,
      SecureStorageKeys.legacyRefreshToken,
    );
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: SecureStorageKeys.refreshToken);
    await _storage.delete(key: SecureStorageKeys.legacyRefreshToken);
  }

  Future<void> setPinSetupCompleted(bool setup) async {
    await _storage.write(
      key: SecureStorageKeys.pinSetup,
      value: setup.toString(),
    );
    await _storage.delete(key: SecureStorageKeys.legacyPinSetup);
  }

  Future<bool> isPinSetup() async {
    final res = await _readWithLegacy(
      SecureStorageKeys.pinSetup,
      SecureStorageKeys.legacyPinSetup,
    );
    return res == 'true';
  }

  Future<void> setOnboardingSeen(bool seen) async {
    await _storage.write(
      key: SecureStorageKeys.onboardingSeen,
      value: seen.toString(),
    );
  }

  Future<bool> hasSeenOnboarding() async {
    final res = await _storage.read(key: SecureStorageKeys.onboardingSeen);
    return res == 'true';
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<String?> _readWithLegacy(String key, String legacyKey) async {
    final current = await _storage.read(key: key);
    if (current != null) return current;
    final legacy = await _storage.read(key: legacyKey);
    if (legacy != null) {
      await _storage.write(key: key, value: legacy);
      await _storage.delete(key: legacyKey);
    }
    return legacy;
  }
}
