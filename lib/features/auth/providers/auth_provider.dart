import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_model.dart';
import '../repositories/auth_repository.dart';
import '../../../core/storage/secure_storage.dart';

// ── State ──────────────────────────────────────────────────────────────────
sealed class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  AuthAuthenticated(this.user);
  final AuthUser user;
}
class AuthUnauthenticated extends AuthState {}
class AuthMfaRequired extends AuthState {
  AuthMfaRequired(this.mfaToken);
  final String mfaToken;
}
class AuthError extends AuthState {
  AuthError(this.message);
  final String message;
}

// ── Notifier ───────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo, this._storage) : super(AuthInitial()) {
    _init();
  }

  final AuthRepository _repo;
  final SecureStorage _storage;

  Future<void> _init() async {
    final token = await _storage.getAccessToken();
    if (token == null) {
      state = AuthUnauthenticated();
      return;
    }
    try {
      final user = await _repo.getMe();
      state = AuthAuthenticated(user);
    } catch (_) {
      await _storage.clearAll();
      state = AuthUnauthenticated();
    }
  }

  Future<bool> login(String email, String password) async {
    state = AuthLoading();
    try {
      final result = await _repo.login(LoginRequest(email: email, password: password));

      if (result is MfaChallenge) {
        state = AuthMfaRequired(result.mfaToken);
        return false;
      }

      final response = result as AuthResponse;
      state = AuthAuthenticated(response.user);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> loginWithMfa(String mfaToken, String code) async {
    state = AuthLoading();
    try {
      final res = await _repo.loginMfa(mfaToken, code);
      state = AuthAuthenticated(res.user);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    state = AuthLoading();
    try {
      final result = await _repo.googleLogin(idToken);

      if (result is MfaChallenge) {
        state = AuthMfaRequired(result.mfaToken);
        return false;
      }

      final response = result as AuthResponse;
      state = AuthAuthenticated(response.user);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    state = AuthLoading();
    try {
      final res = await _repo.register(RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      ));
      state = AuthAuthenticated(res.user);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = AuthUnauthenticated();
  }

  AuthUser? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  bool get mfaRequired => state is AuthMfaRequired;
  String? get mfaToken => state is AuthMfaRequired ? (state as AuthMfaRequired).mfaToken : null;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(secureStorageProvider),
  );
});

/// Convenience: expose the logged-in user or null.
final currentUserProvider = Provider<AuthUser?>((ref) {
  final auth = ref.watch(authProvider);
  if (auth is AuthAuthenticated) return auth.user;
  return null;
});
