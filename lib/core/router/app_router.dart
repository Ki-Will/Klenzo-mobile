import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/wallet/screens/transactions_screen.dart';
import '../../features/transfers/screens/transfer_screen.dart';
import '../../features/kyc/screens/kyc_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../shared/widgets/main_nav_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (ctx, state) {
      final isLoading =
          authState is AuthInitial || authState is AuthLoading;
      final isLoggedIn = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (isLoading) return '/';
      if (!isLoggedIn &&
          !isAuthRoute &&
          state.matchedLocation != '/') {
        return '/login';
      }
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/register',
          builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (ctx, state, child) => MainNavShell(child: child),
        routes: [
          GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen()),
          GoRoute(
              path: '/wallets',
              builder: (_, __) => const WalletScreen()),
          GoRoute(
            path: '/transactions',
            builder: (_, state) => TransactionsScreen(
              walletId: state.uri.queryParameters['walletId'],
            ),
          ),
          GoRoute(
              path: '/transfers',
              builder: (_, __) => const TransferScreen()),
          GoRoute(
              path: '/kyc', builder: (_, __) => const KycScreen()),
          GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen()),
          GoRoute(
              path: '/notifications',
              builder: (_, __) => const NotificationsScreen()),
          GoRoute(
              path: '/payroll',
              builder: (_, __) =>
                  const _ComingSoon(label: 'Payroll')),
        ],
      ),
    ],
  );
});

class _ComingSoon extends StatelessWidget {
  final String label;
  const _ComingSoon({required this.label});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Text('$label coming soon',
            style: const TextStyle(color: Color(0xFF94A3B8))),
      ),
    );
  }
}
