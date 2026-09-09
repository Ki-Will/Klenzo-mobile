# Klenzo Mobile — Cross-Platform Flutter App

**Klenzo Mobile** is the mobile client for the Klenzo financial platform, built with **Flutter**, **Riverpod** state management, **Dio** HTTP client, **Go Router**, and **Flutter Secure Storage**.

---

## 📱 Features

- **Auth & Onboarding**: JWT authentication with automatic refresh token handling (`TokenInterceptor`).
- **Wallets & Accounts**: Multi-wallet balance display and account details (`/api/wallets`).
- **P2P & Mobile Money Transfers**: Instant peer-to-peer and MTN Mobile Money transfers (`/api/transfers`).
- **KYC & Compliance**: Verification status and document uploads (`/api/kyc`).
- **Payroll**: Employee management and payroll run processing (`/api/payroll`).
- **Expense & Habits Tracking**: Real-time spending visualization and habit streak logs.

---

## 🛠️ Development Setup

```bash
# 1. Get Flutter dependencies
flutter pub get

# 2. Configure Backend Endpoint (lib/core/api/endpoints.dart)
# For Android Emulator: http://10.0.2.2:3000/api or http://10.0.2.2/api (via Nginx)
# For Physical Device: http://<HOST_IP>/api

# 3. Run application
flutter run
```

---

## 🚀 Building for Production

### Android (APK & App Bundle)

```bash
# Build standalone release APK
flutter build apk --release

# Build Google Play App Bundle (.aab)
flutter build appbundle --release
# Output file: build/app/outputs/bundle/release/app-release.aab
```

### iOS (App Store .ipa)

```bash
# Build iOS Release App Store package
flutter build ipa --release
# Output file: build/ios/archive/Runner.xcarchive
```

---

## 🧪 Testing Suite

### Unit & State Tests
```bash
flutter test
```

### Integration E2E Tests
```bash
flutter test integration_test/app_test.dart
```
*(Runs Flutter Integration Test suite verifying app startup, navigation, and feature mounting).*
