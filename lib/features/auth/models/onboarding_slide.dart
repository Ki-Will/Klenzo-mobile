import 'package:flutter/material.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.id,
    required this.tab,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.stat,
    required this.statLabel,
    required this.icon,
    required this.accent,
  });

  final String id;
  final String tab;
  final String title;
  final String subtitle;
  final String description;
  final String stat;
  final String statLabel;
  final IconData icon;
  final Color accent;
}

const kOnboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    id: 'sms',
    tab: 'SMS Auto-Tracking',
    title: 'Instant SMS Expense Tracking',
    subtitle: 'Zero manual entry',
    description:
        'Capture and categorize bank SMS alerts in real time with 99.9% parsing precision.',
    stat: '99.9%',
    statLabel: 'SMS parsing accuracy',
    icon: Icons.sms_rounded,
    accent: Color(0xFF2EE6C5),
  ),
  OnboardingSlide(
    id: 'groups',
    tab: 'Split Expenses',
    title: 'Split bills with anyone',
    subtitle: 'Settle in seconds',
    description:
        'Track shared rent, dinners, and trips with equal or custom split algorithms.',
    stat: '\$2.4M',
    statLabel: 'tracked',
    icon: Icons.groups_rounded,
    accent: Color(0xFF22D3EE),
  ),
  OnboardingSlide(
    id: 'ai',
    tab: 'AI Financial Insights',
    title: 'A private financial advisor',
    subtitle: 'Live budget optimization',
    description:
        'Spot burn-rate spikes and get a monthly savings path from your own history.',
    stat: '30%',
    statLabel: 'avg. monthly savings',
    icon: Icons.auto_awesome,
    accent: Color(0xFF34D399),
  ),
  OnboardingSlide(
    id: 'transfers',
    tab: 'Instant P2P Transfers',
    title: 'P2P & mobile money',
    subtitle: 'Zero-friction settlement',
    description:
        'Move funds across wallets, MTN MoMo, and banks on a double-entry ledger.',
    stat: '< 50ms',
    statLabel: 'settlement speed',
    icon: Icons.swap_horiz_rounded,
    accent: Color(0xFFFBBF24),
  ),
];

int wrapIndex(int current, int delta, int length) {
  if (length <= 0) return 0;
  return ((current + delta) % length + length) % length;
}
