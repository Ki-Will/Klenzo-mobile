import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/k_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _demoNotifs = [
    _Notif(
      icon: Icons.arrow_downward_rounded,
      color: AppColors.success,
      title: 'Money Received',
      body: 'You received \$500.00 from John Doe',
      time: '2 min ago',
    ),
    _Notif(
      icon: Icons.shield_outlined,
      color: AppColors.accent,
      title: 'KYC Reminder',
      body: 'Complete your identity verification to unlock all features',
      time: '1 hr ago',
    ),
    _Notif(
      icon: Icons.send_rounded,
      color: AppColors.warning,
      title: 'Transfer Sent',
      body: 'Your transfer of \$200.00 is being processed',
      time: 'Yesterday',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _demoNotifs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) => _NotifCard(notif: _demoNotifs[i]),
      ),
    );
  }
}

class _Notif {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  const _Notif(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body,
      required this.time});
}

class _NotifCard extends StatelessWidget {
  final _Notif notif;
  const _NotifCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    return KCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: notif.color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.all(AppRadius.md),
            ),
            child: Icon(notif.icon, color: notif.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif.title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(notif.body,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(notif.time,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
