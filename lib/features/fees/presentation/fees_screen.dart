import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/platform/url_launcher_service.dart';
import 'package:tution_tracker/core/utils/contact_links.dart';
import 'package:tution_tracker/core/utils/phone.dart';
import 'package:tution_tracker/features/fees/data/fee_repository.dart';
import 'package:tution_tracker/features/fees/domain/fee_status.dart';
import 'package:tution_tracker/features/fees/presentation/fees_providers.dart';
import 'package:tution_tracker/features/students/presentation/student_avatar.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// The Fees tab: who owes what, most urgent first (spec FE-4).
class FeesScreen extends ConsumerWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final all = ref.watch(dueListProvider);
    final visible = ref.watch(visibleDueListProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;

    String money(int amount) =>
        formatTaka(Taka(amount), numerals: numerals, grouping: grouping);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navFees)),
      body: Column(
        children: [
          all.maybeWhen(
            data: (list) => _TotalsHeader(
              total: money(list.fold(0, (s, e) => s + e.totalBalance)),
              count: formatCount(list.length, numerals),
            ),
            orElse: () => const SizedBox(height: 8),
          ),
          const _FilterBar(),
          Expanded(
            child: visible.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) {
                if (list.isEmpty) {
                  final nothingOwed = all.value?.isEmpty ?? true;
                  return _Empty(
                    title: nothingOwed
                        ? l10n.feesEmptyTitle
                        : l10n.studentsNoMatch,
                    body: nothingOwed ? l10n.feesEmptyBody : null,
                    icon: nothingOwed
                        ? Icons.check_circle_outline
                        : Icons.search_off,
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) => _DueTile(
                    entry: list[i],
                    money: money,
                    numerals: numerals,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsHeader extends StatelessWidget {
  const _TotalsHeader({required this.total, required this.count});

  final String total;
  final String count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.feesOutstanding,
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      total,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.feesStudentsOwing(count),
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  static const _none = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(dueFilterProvider);
    final notifier = ref.read(dueFilterProvider.notifier);
    final batches = ref.watch(batchOptionsProvider).value ?? const [];

    final modeLabels = {
      DueMode.all: l10n.filterAll,
      DueMode.overdue: l10n.filterOverdue,
      DueMode.dueThisWeek: l10n.filterDueWeek,
    };
    String? batchName;
    for (final b in batches) {
      if (b.id == filter.batchId) batchName = b.name;
    }

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          for (final mode in DueMode.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(modeLabels[mode]!),
                selected: filter.mode == mode,
                onSelected: (_) => notifier.setMode(mode),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: PopupMenuButton<DueSort>(
              tooltip: l10n.sortByAmount,
              onSelected: notifier.setSort,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: DueSort.overdueDays,
                  child: Text(l10n.sortByOverdue),
                ),
                PopupMenuItem(
                  value: DueSort.amount,
                  child: Text(l10n.sortByAmount),
                ),
              ],
              child: Chip(
                avatar: const Icon(Icons.sort, size: 18),
                label: Text(
                  filter.sort == DueSort.amount
                      ? l10n.sortByAmount
                      : l10n.sortByOverdue,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: PopupMenuButton<String>(
              tooltip: l10n.studentsFilterBatch,
              onSelected: (v) => notifier.setBatch(v == _none ? null : v),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _none,
                  child: Text(l10n.studentsAllBatches),
                ),
                for (final b in batches)
                  PopupMenuItem(value: b.id, child: Text(b.name)),
              ],
              child: Chip(
                avatar: const Icon(Icons.groups_outlined, size: 18),
                label: Text(batchName ?? l10n.studentsFilterBatch),
                backgroundColor: filter.batchId == null
                    ? null
                    : Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DueTile extends ConsumerWidget {
  const _DueTile({
    required this.entry,
    required this.money,
    required this.numerals,
  });

  final DueListEntry entry;
  final String Function(int) money;
  final NumeralStyle numerals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = ref.watch(appLanguageProvider);
    final today = todayFrom(ref.read(clockProvider));
    final student = entry.student;
    final late = overdueDays(entry.oldestDueDate, today);
    final phone =
        parseBdPhone(student.guardianPhone ?? '') ??
        parseBdPhone(student.studentPhone ?? '');

    final detail = [
      l10n.feesOpenMonths(formatCount(entry.openCount, numerals)),
      late > 0
          ? l10n.feesOverdueDays(formatCount(late, numerals))
          : l10n.feesDueOn(
              formatDate(
                entry.oldestDueDate,
                language: language,
                numerals: numerals,
              ),
            ),
    ].join(' · ');

    return ListTile(
      leading: StudentAvatar(name: student.name, photoPath: student.photoPath),
      title: Text(student.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        detail,
        style: late > 0 ? TextStyle(color: theme.colorScheme.error) : null,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            money(entry.totalBalance),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: late > 0 ? theme.colorScheme.error : null,
            ),
          ),
          IconButton(
            tooltip: l10n.actionCall,
            icon: const Icon(Icons.call),
            onPressed: phone == null
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await ref
                        .read(urlLauncherProvider)
                        .open(ContactLinks.call(phone));
                    if (!ok) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.contactLaunchFailed)),
                      );
                    }
                  },
          ),
        ],
      ),
      // One tap from the row to the payment screen (spec FE-1).
      onTap: () => context.push('/fees/pay/${student.id}'),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.title, required this.icon, this.body});

  final String title;
  final String? body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(body!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
