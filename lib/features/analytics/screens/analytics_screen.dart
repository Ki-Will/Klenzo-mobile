import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/k_card.dart';

// ── Provider (placeholder — swap for real API call) ────────────────────────
final analyticsSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // TODO: Replace with real API call: GET /finance/analytics/summary
  return {
    'totalSpend': 0.0,
    'totalIncome': 0.0,
    'netBalance': 0.0,
  };
});

final analyticsCategoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // TODO: Replace with real API call: GET /finance/analytics/categories
  return [];
});

// ── Screen ─────────────────────────────────────────────────────────────────
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(analyticsSummaryProvider);
    final categoriesAsync = ref.watch(analyticsCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.bgCard,
        onRefresh: () async {
          ref.invalidate(analyticsSummaryProvider);
          ref.invalidate(analyticsCategoriesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Summary Cards
            summaryAsync.when(
              loading: () => const SizedBox(
                  height: 100, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text(e.toString(),
                  style: const TextStyle(color: AppColors.danger)),
              data: (summary) => _SummaryCards(summary: summary),
            ),
            const SizedBox(height: 24),

            // Category Breakdown
            const Text('SPENDING BY CATEGORY',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            const SizedBox(height: 10),
            categoriesAsync.when(
              loading: () => const SizedBox(
                  height: 100, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text(e.toString(),
                  style: const TextStyle(color: AppColors.danger)),
              data: (categories) {
                if (categories.isEmpty) {
                  return const KCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No spending data yet',
                            style: TextStyle(color: AppColors.textMuted)),
                      ),
                    ),
                  );
                }
                return KCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: categories.map((cat) {
                      final name = cat['category']?.toString() ?? 'Other';
                      final amount = (cat['amount'] as num?)?.toDouble() ?? 0;
                      final percentage =
                          (cat['percentage'] as num?)?.toDouble() ?? 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(name,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                                Text(Formatters.currency(amount),
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: AppColors.bgElevated,
                                color: AppColors.accent,
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('${percentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Monthly Trend placeholder
            const Text('MONTHLY TREND',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            const SizedBox(height: 10),
            const KCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.show_chart_rounded,
                          color: AppColors.textMuted, size: 40),
                      SizedBox(height: 12),
                      Text('Trend chart coming soon',
                          style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final Map<String, dynamic> summary;
  const _SummaryCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    final spend = (summary['totalSpend'] as num?)?.toDouble() ?? 0;
    final income = (summary['totalIncome'] as num?)?.toDouble() ?? 0;
    final net = (summary['netBalance'] as num?)?.toDouble() ?? 0;

    return Column(
      children: [
        // Net balance hero card
        KGradientCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Net Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              Text(
                '${net >= 0 ? '+' : ''}${Formatters.currency(net)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'Income',
                value: Formatters.currency(income),
                color: AppColors.success,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStat(
                label: 'Expenses',
                value: Formatters.currency(spend),
                color: AppColors.danger,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
