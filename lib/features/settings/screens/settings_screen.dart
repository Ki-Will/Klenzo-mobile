import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/k_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _smartInsights = true;
  bool _transactionAlerts = true;
  bool _securityAlerts = true;
  bool _groupAlerts = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            const Text('ACCOUNT',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            const SizedBox(height: 10),
            KCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    subtitle: '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                    onTap: () => context.push('/profile'),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Security',
                    subtitle: 'Password, 2FA, sessions',
                    onTap: () => context.push('/security'),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.shield_outlined,
                    label: 'Identity Verification',
                    subtitle: (user?.kycStatus ?? 'unverified').toUpperCase(),
                    onTap: () => context.push('/kyc'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notifications Section
            const Text('NOTIFICATIONS',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            const SizedBox(height: 10),
            KCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SwitchTile(
                    icon: Icons.psychology_outlined,
                    label: 'Smart Insights',
                    subtitle: 'AI-powered spending tips',
                    value: _smartInsights,
                    onChanged: (v) => setState(() => _smartInsights = v),
                  ),
                  const Divider(height: 1),
                  _SwitchTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'Transaction Alerts',
                    subtitle: 'Get notified on every transaction',
                    value: _transactionAlerts,
                    onChanged: (v) => setState(() => _transactionAlerts = v),
                  ),
                  const Divider(height: 1),
                  _SwitchTile(
                    icon: Icons.security_outlined,
                    label: 'Security Alerts',
                    subtitle: 'Login attempts and suspicious activity',
                    value: _securityAlerts,
                    onChanged: (v) => setState(() => _securityAlerts = v),
                  ),
                  const Divider(height: 1),
                  _SwitchTile(
                    icon: Icons.group_outlined,
                    label: 'Group Alerts',
                    subtitle: 'Group activity and settlements',
                    value: _groupAlerts,
                    onChanged: (v) => setState(() => _groupAlerts = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Section
            const Text('APP',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            const SizedBox(height: 10),
            KCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    label: 'About Klenzo',
                    subtitle: 'v1.0.0',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Danger Zone
            KCard(
              padding: EdgeInsets.zero,
              child: _SettingsTile(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                iconColor: AppColors.danger,
                labelColor: AppColors.danger,
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: labelColor ?? AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
