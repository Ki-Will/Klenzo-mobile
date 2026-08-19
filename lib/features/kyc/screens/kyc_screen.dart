import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/k_badge.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_card.dart';

class KycScreen extends ConsumerWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final status = user?.kycStatus ?? 'unverified';

    KBadgeVariant badgeVariant = switch (status) {
      'verified' => KBadgeVariant.success,
      'pending' => KBadgeVariant.warning,
      'rejected' => KBadgeVariant.danger,
      _ => KBadgeVariant.neutral,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Identity Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KCard(
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.accentSurface,
                      borderRadius: BorderRadius.all(AppRadius.lg),
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: AppColors.accent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('KYC Status',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 12)),
                        const SizedBox(height: 4),
                        KBadge(
                          label: status.toUpperCase(),
                          variant: badgeVariant,
                          dot: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (status == 'unverified' || status == 'rejected') ...[
              const Text('Complete Verification',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text(
                'Verify your identity to unlock all Klenzo features including higher transfer limits and payroll.',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ..._steps.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StepCard(step: s),
                  )),
              const SizedBox(height: 24),
              KButton(
                label: 'Start Verification',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {},
              ),
            ] else if (status == 'pending') ...[
              const SizedBox(height: 40),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.hourglass_top_rounded,
                        color: AppColors.warning, size: 56),
                    SizedBox(height: 16),
                    Text('Verification Under Review',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text(
                        'We are reviewing your documents. This usually takes 1–2 business days.',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 40),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.verified_rounded,
                        color: AppColors.success, size: 64),
                    SizedBox(height: 16),
                    Text('Identity Verified',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Text(
                        'Your account is fully verified. Enjoy all Klenzo features.',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const _steps = [
    _VerificationStep(
      icon: Icons.person_outline_rounded,
      title: 'Personal Information',
      subtitle: 'Full name, date of birth, nationality',
    ),
    _VerificationStep(
      icon: Icons.credit_card_outlined,
      title: 'Government ID',
      subtitle: 'NIN, passport, or driver license',
    ),
    _VerificationStep(
      icon: Icons.camera_alt_outlined,
      title: 'Selfie Verification',
      subtitle: 'Live photo to match your ID',
    ),
  ];
}

class _VerificationStep {
  final IconData icon;
  final String title;
  final String subtitle;
  const _VerificationStep(
      {required this.icon, required this.title, required this.subtitle});
}

class _StepCard extends StatelessWidget {
  final _VerificationStep step;
  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return KCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.all(AppRadius.md),
            ),
            child: Icon(step.icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                Text(step.subtitle,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted),
        ],
      ),
    );
  }
}
