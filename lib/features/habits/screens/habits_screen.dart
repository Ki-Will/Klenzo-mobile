import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/k_badge.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_card.dart';
import '../../../shared/widgets/k_text_field.dart';

// ── Model ──────────────────────────────────────────────────────────────────
class Habit {
  final String id;
  final String name;
  final String? description;
  final String frequency;
  final int currentStreak;
  final int longestStreak;
  final bool completedToday;

  const Habit({
    required this.id,
    required this.name,
    this.description,
    required this.frequency,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completedToday = false,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      frequency: json['frequency']?.toString() ?? 'daily',
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      completedToday: json['completedToday'] ?? false,
    );
  }
}

// ── Provider (placeholder — swap for real API call) ────────────────────────
final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  // TODO: Replace with real API call: GET /habits
  return [];
});

// ── Screen ─────────────────────────────────────────────────────────────────
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'New habit',
            onPressed: () => _showCreateHabit(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.bgCard,
        onRefresh: () => ref.refresh(habitsProvider.future),
        child: habitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(e.toString(),
                style: const TextStyle(color: AppColors.danger)),
          ),
          data: (habits) => habits.isEmpty
              ? ListView(children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.auto_awesome_outlined,
                            color: AppColors.textMuted, size: 56),
                        SizedBox(height: 16),
                        Text('No habits yet',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        Text('Build good habits, one day at a time',
                            style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ])
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: habits.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _HabitCard(habit: habits[i]),
                ),
        ),
      ),
    );
  }

  void _showCreateHabit(BuildContext ctx, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String frequency = 'daily';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx2, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx2).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Habit', style: Theme.of(ctx2).textTheme.titleLarge),
              const SizedBox(height: 20),
              KTextField(
                label: 'Habit name',
                hint: 'e.g. Read 30 minutes',
                controller: nameCtrl,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              KTextField(
                label: 'Description (optional)',
                hint: 'Why this matters to you',
                controller: descCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: ['daily', 'weekly']
                    .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f[0].toUpperCase() + f.substring(1)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => frequency = v!),
              ),
              const SizedBox(height: 20),
              KButton(
                label: 'Create Habit',
                onPressed: () {
                  // TODO: POST /habits
                  Navigator.pop(ctx2);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    return KCard(
      child: Row(
        children: [
          // Streak circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: habit.completedToday
                  ? AppColors.successLight
                  : AppColors.accentSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: habit.completedToday
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.success, size: 24)
                  : Text(
                      '${habit.currentStreak}',
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    KBadge(
                      label: habit.frequency.toUpperCase(),
                      variant: KBadgeVariant.info,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '🔥 ${habit.currentStreak} streak · Best: ${habit.longestStreak}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!habit.completedToday)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.accent, size: 28),
              tooltip: 'Mark complete',
              onPressed: () {
                // TODO: POST /habits/:id/complete
              },
            ),
        ],
      ),
    );
  }
}
