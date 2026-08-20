import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/k_badge.dart';
import '../../../shared/widgets/k_button.dart';
import '../../../shared/widgets/k_card.dart';
import '../../../shared/widgets/k_text_field.dart';

// ── Model ──────────────────────────────────────────────────────────────────
class Group {
  final String id;
  final String name;
  final int memberCount;
  final double netBalance;

  const Group({
    required this.id,
    required this.name,
    this.memberCount = 0,
    this.netBalance = 0,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    final members = json['members'] as List?;
    return Group(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      memberCount: members?.length ?? 0,
      netBalance: (json['netBalance'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ── Provider (placeholder — swap for real API call) ────────────────────────
final groupsProvider = FutureProvider<List<Group>>((ref) async {
  // TODO: Replace with real API call: GET /finance/groups
  return [];
});

// ── Screen ─────────────────────────────────────────────────────────────────
class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'New group',
            onPressed: () => _showCreateGroup(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.bgCard,
        onRefresh: () => ref.refresh(groupsProvider.future),
        child: groupsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(e.toString(),
                style: const TextStyle(color: AppColors.danger)),
          ),
          data: (groups) => groups.isEmpty
              ? ListView(children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.group_outlined,
                            color: AppColors.textMuted, size: 56),
                        SizedBox(height: 16),
                        Text('No groups yet',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        Text(
                            'Create a group to split bills with friends',
                            style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ])
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _GroupCard(group: groups[i]),
                ),
        ),
      ),
    );
  }

  void _showCreateGroup(BuildContext ctx, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

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
              Text('New Group', style: Theme.of(ctx2).textTheme.titleLarge),
              const SizedBox(height: 20),
              KTextField(
                label: 'Group name',
                hint: 'e.g. Flatmates, Road Trip',
                controller: nameCtrl,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              KTextField(
                label: 'Add member email (optional)',
                hint: 'friend@example.com',
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              KButton(
                label: 'Create Group',
                onPressed: () {
                  // TODO: POST /finance/groups
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

class _GroupCard extends StatelessWidget {
  final Group group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final isPositive = group.netBalance >= 0;

    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(group.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              KBadge(
                label: '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                variant: KBadgeVariant.info,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your balance',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text(
                '${isPositive ? '+' : ''}${Formatters.currency(group.netBalance)}',
                style: TextStyle(
                  color: isPositive ? AppColors.success : AppColors.danger,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
