import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/features/reports/data/report_providers.dart';
import 'package:tution_tracker/features/reports/data/report_repository.dart';
import 'package:tution_tracker/features/reports/presentation/income_chart.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// The monthly report: what was expected, collected and is still owed, by
/// batch, plus a year of income (spec RP-1, RP-2).
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  YearMonth? _month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;
    final thisMonth = YearMonth.from(todayFrom(ref.watch(clockProvider)));
    final month = _month ?? thisMonth;

    String money(int v) =>
        formatTaka(Taka(v), numerals: numerals, grouping: grouping);

    final summary = ref.watch(monthSummaryProvider(month)).value;
    final rows = ref.watch(batchBreakdownProvider(month)).value;
    final income = ref.watch(incomeProvider(thisMonth)).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReports)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l10n.calPrevMonth,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _month = month.previous()),
              ),
              Expanded(
                child: Text(
                  formatMonth(month, language: language, numerals: numerals),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l10n.calNextMonth,
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _month = month.next()),
              ),
            ],
          ),
          if (summary != null) ...[
            if (summary.expected == 0 && summary.cashReceived == 0)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text(l10n.reportNoData)),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _line(
                        context,
                        l10n.homeExpected,
                        money(summary.expected),
                      ),
                      _line(
                        context,
                        l10n.homeCollected,
                        money(summary.collected),
                      ),
                      _line(
                        context,
                        l10n.homeOutstanding,
                        money(summary.outstanding),
                      ),
                      if (summary.collectionPercent != null)
                        _line(
                          context,
                          l10n.reportCollectionRate,
                          applyNumerals(
                            '${summary.collectionPercent}%',
                            numerals,
                          ),
                        ),
                      const Divider(),
                      _line(
                        context,
                        l10n.reportCash,
                        money(summary.cashReceived),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          if (rows != null && rows.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.reportBatches, style: theme.textTheme.titleMedium),
            for (final r in rows)
              _BatchRow(row: r, money: money, numerals: numerals),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l10n.reportNote, style: theme.textTheme.bodySmall),
            ),
          ],
          const SizedBox(height: 24),
          Text(l10n.reportIncomeTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (income != null)
            IncomeChart(
              income: income,
              language: language,
              numerals: numerals,
              grouping: grouping,
            ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    ),
  );
}

class _BatchRow extends StatelessWidget {
  const _BatchRow({
    required this.row,
    required this.money,
    required this.numerals,
  });

  final BatchBreakdown row;
  final String Function(int) money;
  final NumeralStyle numerals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percent = row.attendance.percent;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(row.batch?.name ?? l10n.reportNoBatch),
      subtitle: Text(
        [
          l10n.reportStudents(formatCount(row.students, numerals)),
          '${l10n.homeCollected} ${money(row.collected)}',
          if (percent != null)
            l10n.reportAttendance(applyNumerals('$percent%', numerals)),
        ].join(' · '),
      ),
      trailing: Text(
        money(row.outstanding),
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
