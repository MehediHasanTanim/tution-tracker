import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/organic_widgets.dart';
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

  /// How many months the income chart shows: the design's 6 / 12 switch.
  int _span = 6;

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

    final o = Organic.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReports)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatMonth(month, language: language, numerals: numerals),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: l10n.calPrevMonth,
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => setState(() => _month = month.previous()),
              ),
              IconButton(
                tooltip: l10n.calNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => setState(() => _month = month.next()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (summary != null) ...[
            if (summary.expected == 0 && summary.cashReceived == 0)
              OrganicPanel(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text(l10n.reportNoData)),
              )
            else ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Figure(
                      l10n.homeExpected,
                      money(summary.expected),
                      o.sageSoft,
                      o.onSageSoft,
                    ),
                    const SizedBox(width: 10),
                    _Figure(
                      l10n.homeCollected,
                      money(summary.collected),
                      o.accentSoft,
                      o.onAccentSoft,
                    ),
                    const SizedBox(width: 10),
                    _Figure(
                      l10n.homeOutstanding,
                      money(summary.outstanding),
                      o.surface,
                      o.text,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              OrganicPanel(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    if (summary.collectionPercent != null)
                      _line(
                        context,
                        l10n.reportCollectionRate,
                        applyNumerals(
                          '${summary.collectionPercent}%',
                          numerals,
                        ),
                      ),
                    _line(
                      context,
                      l10n.reportCash,
                      money(summary.cashReceived),
                    ),
                  ],
                ),
              ),
            ],
          ],
          if (rows != null && rows.isNotEmpty) ...[
            const SizedBox(height: 24),
            SectionTitle(l10n.reportBatches),
            const SizedBox(height: 10),
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BatchRow(row: r, money: money, numerals: numerals),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(l10n.reportNote, style: theme.textTheme.bodySmall),
            ),
          ],
          const SizedBox(height: 24),
          OrganicPanel(
            radius: OrganicRadius.panel,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.reportIncomeTitle,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    for (final n in const [6, 12])
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 4),
                        child: ChoiceChip(
                          label: Text(
                            l10n.reportMonths(formatCount(n, numerals)),
                          ),
                          selected: _span == n,
                          visualDensity: VisualDensity.compact,
                          onSelected: (_) => setState(() => _span = n),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                if (income != null)
                  IncomeChart(
                    income: income.length > _span
                        ? income.sublist(income.length - _span)
                        : income,
                    language: language,
                    numerals: numerals,
                    grouping: grouping,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Organic.of(context).muted),
          ),
        ),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    ),
  );
}

/// One of the three month figures, on its own tinted tile.
class _Figure extends StatelessWidget {
  const _Figure(this.label, this.value, this.background, this.foreground);

  final String label;
  final String value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: OrganicPanel(
        color: background,
        radius: 20,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w400,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    final theme = Theme.of(context);
    final o = Organic.of(context);
    final percent = row.attendance.percent;
    final share = row.expected == 0 ? 0.0 : row.collected / row.expected;
    return OrganicPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.batch?.name ?? l10n.reportNoBatch,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(money(row.outstanding), style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          PillProgress(value: share, color: o.sage, track: o.neutralSoft),
          const SizedBox(height: 6),
          Text(
            [
              l10n.reportStudents(formatCount(row.students, numerals)),
              '${l10n.homeCollected} ${money(row.collected)}',
              if (percent != null)
                l10n.reportAttendance(applyNumerals('$percent%', numerals)),
            ].join(' · '),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
