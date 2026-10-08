import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/features/batches/data/batch_providers.dart';
import 'package:tution_tracker/features/batches/data/batch_repository.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// "Sat, Mon · 17:00" style schedule line shared by the list and detail.
String batchScheduleText(
  Batch? batch, {
  required AppLanguage language,
  required NumeralStyle numerals,
}) {
  if (batch == null) return '';
  final days = [
    for (final d in _readingOrder(batch.scheduleDayList))
      weekdayName(d, language),
  ].join(', ');
  final time = batch.startTimeValue;
  return time == null
      ? days
      : '$days · ${applyNumerals(time.toKey(), numerals)}';
}

// Saturday first, as a Bangladeshi week reads.
List<int> _readingOrder(List<int> days) {
  const order = [6, 7, 1, 2, 3, 4, 5];
  return [
    for (final d in order)
      if (days.contains(d)) d,
  ];
}

class BatchListView extends ConsumerWidget {
  const BatchListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final batches = ref.watch(batchSummariesProvider);
    final showArchived = ref.watch(showArchivedBatchesProvider);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              FilterChip(
                label: Text(l10n.batchShowArchived),
                selected: showArchived,
                onSelected: (_) =>
                    ref.read(showArchivedBatchesProvider.notifier).toggle(),
              ),
            ],
          ),
        ),
        Expanded(
          child: batches.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.batchesEmptyTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.batchesEmptyBody),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final s = list[i];
                  final b = s.batch;
                  final detail = [?b.subject, ?b.classLevel].join(' · ');
                  final fee = formatTaka(
                    Taka(b.defaultFee),
                    numerals: numerals,
                    grouping: grouping,
                  );
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.groups)),
                    title: Text(
                      b.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      [
                        if (detail.isNotEmpty) detail,
                        batchScheduleText(
                          b,
                          language: language,
                          numerals: numerals,
                        ),
                        '${l10n.batchMemberCount(formatCount(s.memberCount, numerals))} · $fee',
                      ].join('\n'),
                    ),
                    isThreeLine: true,
                    trailing: b.isArchived
                        ? Chip(
                            label: Text(l10n.statusArchived),
                            visualDensity: VisualDensity.compact,
                          )
                        : null,
                    onTap: () => context.push('/batches/${b.id}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
