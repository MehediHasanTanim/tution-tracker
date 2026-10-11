import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
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

/// The Batches tab: every batch with its class days and time, and a button
/// for a new one (design: `batchTab`).
class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final o = Organic.of(context);
    final batches = ref.watch(batchSummariesProvider);
    final showArchived = ref.watch(showArchivedBatchesProvider);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;

    final addButton = BlockButton(
      l10n.batchesAdd,
      onPressed: () => context.push('/batches/new'),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navBatches)),
      body: batches.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            BlockStack(
              children: [
                BlockText(
                  l10n.batchesIntro(formatCount(list.length, numerals)),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FilterChip(
                    label: Text(l10n.batchShowArchived),
                    selected: showArchived,
                    onSelected: (_) =>
                        ref.read(showArchivedBatchesProvider.notifier).toggle(),
                  ),
                ),
                if (list.isEmpty) ...[
                  const SizedBox(height: 24),
                  Icon(Icons.layers_rounded, size: 64, color: o.accentDecor),
                  Text(
                    l10n.batchesEmptyTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(l10n.batchesEmptyBody, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                ],
                for (final s in list)
                  BlockItem(
                    leading: const BlockIcon(Icons.layers_rounded, sage: true),
                    title: s.batch.name,
                    subtitle: [
                      ?s.batch.subject,
                      batchScheduleText(
                        s.batch,
                        language: language,
                        numerals: numerals,
                      ),
                      formatTaka(
                        Taka(s.batch.defaultFee),
                        numerals: numerals,
                        grouping: grouping,
                      ),
                    ].where((t) => t.isNotEmpty).join(' · '),
                    tag: s.batch.isArchived
                        ? l10n.statusArchived
                        : l10n.batchStudentsTag(
                            formatCount(s.memberCount, numerals),
                          ),
                    tagBackground: s.batch.isArchived ? o.raised : o.sageSoft,
                    tagForeground: s.batch.isArchived ? o.muted : o.onSageSoft,
                    chevron: true,
                    onTap: () => context.push('/batches/${s.batch.id}'),
                  ),
                addButton,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
