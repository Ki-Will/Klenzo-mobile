abstract class Endpoints {
  // ── Base ──────────────────────────────────────────────────────────────────
  // Android emulator → host machine's localhost
  static const baseUrl = 'http://10.0.2.2:3000/api';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const me = '/auth/me';

  // ── Wallets ───────────────────────────────────────────────────────────────
  static const wallets = '/wallets';

  // ── Transactions ──────────────────────────────────────────────────────────
  static const transactions = '/transactions';

  // ── Transfers ─────────────────────────────────────────────────────────────
  static const transfers = '/transfers';

  // ── Payroll ───────────────────────────────────────────────────────────────
  static const payroll = '/payroll';
  static const payrollEmployees = '/payroll/employees';
  static const payrollRuns = '/payroll/runs';

  // ── KYC ───────────────────────────────────────────────────────────────────
  static const kyc = '/kyc';
  static const kycDocuments = '/kyc/documents';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const notifications = '/notifications';
}
