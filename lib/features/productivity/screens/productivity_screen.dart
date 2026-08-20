import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/k_badge.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_card.dart';
import '../../../shared/widgets/k_text_field.dart';

// ── Model ──────────────────────────────────────────────────────────────────
class Task {
  final String id;
  final String title;
  final String? description;
  final String status;
  final int priority;
  final String? dueDate;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.status = 'todo',
    this.priority = 0,
    this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'todo',
      priority: json['priority'] ?? 0,
      dueDate: json['dueDate']?.toString(),
    );
  }
}

// ── Provider (placeholder — swap for real API call) ────────────────────────
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  // TODO: Replace with real API call: GET /productivity/tasks
  return [];
});

// ── Screen ─────────────────────────────────────────────────────────────────
class ProductivityScreen extends ConsumerStatefulWidget {
  const ProductivityScreen({super.key});

  @override
  ConsumerState<ProductivityScreen> createState() => _ProductivityScreenState();
}

class _ProductivityScreenState extends ConsumerState<ProductivityScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'New task',
            onPressed: () => _showCreateTask(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                    label: 'All',
                    selected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all')),
                const SizedBox(width: 8),
                _FilterChip(
                    label: 'To Do',
                    selected: _filter == 'todo',
                    onTap: () => setState(() => _filter = 'todo')),
                const SizedBox(width: 8),
                _FilterChip(
                    label: 'In Progress',
                    selected: _filter == 'in_progress',
                    onTap: () => setState(() => _filter = 'in_progress')),
                const SizedBox(width: 8),
                _FilterChip(
                    label: 'Done',
                    selected: _filter == 'done',
                    onTap: () => setState(() => _filter = 'done')),
              ],
            ),
          ),
          // Task list
          Expanded(
            child: RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.bgCard,
              onRefresh: () => ref.refresh(tasksProvider.future),
              child: tasksAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(e.toString(),
                      style: const TextStyle(color: AppColors.danger)),
                ),
                data: (tasks) {
                  final filtered = _filter == 'all'
                      ? tasks
                      : tasks.where((t) => t.status == _filter).toList();
                  if (filtered.isEmpty) {
                    return ListView(children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.bolt_rounded,
                                color: AppColors.textMuted, size: 56),
                            SizedBox(height: 16),
                            Text('No tasks',
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                            SizedBox(height: 8),
                            Text('Stay productive — add your first task',
                                style:
                                    TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ]);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => _TaskCard(task: filtered[i]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTask(BuildContext ctx, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String status = 'todo';
    int priority = 0;

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
              Text('New Task', style: Theme.of(ctx2).textTheme.titleLarge),
              const SizedBox(height: 20),
              KTextField(
                label: 'Task title',
                hint: 'What needs to be done?',
                controller: titleCtrl,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              KTextField(
                label: 'Description (optional)',
                hint: 'Add more details',
                controller: descCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: status,
                      decoration:
                          const InputDecoration(labelText: 'Status'),
                      items: ['todo', 'in_progress', 'done']
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s
                                    .replaceAll('_', ' ')
                                    .split(' ')
                                    .map((w) => w[0].toUpperCase() + w.substring(1))
                                    .join(' ')),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => status = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: priority,
                      decoration:
                          const InputDecoration(labelText: 'Priority'),
                      items: [0, 1, 2, 3]
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p == 0
                                    ? 'None'
                                    : p == 1
                                        ? 'Low'
                                        : p == 2
                                            ? 'Medium'
                                            : 'High'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => priority = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              KButton(
                label: 'Create Task',
                onPressed: () {
                  // TODO: POST /productivity/tasks
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.bgElevated,
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          border: Border.all(
              color: selected ? AppColors.accent : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  const _TaskCard({required this.task});

  KBadgeVariant get _statusBadge => switch (task.status) {
        'done' => KBadgeVariant.success,
        'in_progress' => KBadgeVariant.info,
        'cancelled' => KBadgeVariant.danger,
        _ => KBadgeVariant.neutral,
      };

  String get _statusLabel => switch (task.status) {
        'todo' => 'TO DO',
        'in_progress' => 'IN PROGRESS',
        'done' => 'DONE',
        'cancelled' => 'CANCELLED',
        _ => task.status.toUpperCase(),
      };

  @override
  Widget build(BuildContext context) {
    return KCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: task.status == 'done'
                  ? AppColors.success
                  : task.status == 'in_progress'
                      ? AppColors.info
                      : AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: TextStyle(
                        color: task.status == 'done'
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: task.status == 'done'
                            ? TextDecoration.lineThrough
                            : null)),
                if (task.description != null) ...[
                  const SizedBox(height: 2),
                  Text(task.description!,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    KBadge(label: _statusLabel, variant: _statusBadge),
                    if (task.priority > 0) ...[
                      const SizedBox(width: 6),
                      KBadge(
                        label: task.priority == 1
                            ? 'LOW'
                            : task.priority == 2
                                ? 'MED'
                                : 'HIGH',
                        variant: task.priority >= 3
                            ? KBadgeVariant.danger
                            : task.priority == 2
                                ? KBadgeVariant.warning
                                : KBadgeVariant.neutral,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
