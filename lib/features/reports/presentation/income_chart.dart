import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/features/reports/data/report_repository.dart';

/// Cash received per month. One series, so no legend; the section title
/// names it. Bars are pill-topped, past months in a soft tint and this month
/// in the full accent, with no grid; touching a bar shows its exact amount.
class IncomeChart extends StatelessWidget {
  const IncomeChart({
    required this.income,
    required this.language,
    required this.numerals,
    required this.grouping,
    super.key,
  });

  final List<MonthIncome> income;
  final AppLanguage language;
  final NumeralStyle numerals;
  final GroupingStyle grouping;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final o = Organic.of(context);
    final style = Theme.of(context).textTheme.labelSmall;
    final peak = income.fold<int>(0, (m, e) => e.amount > m ? e.amount : m);
    final top = peak == 0 ? 1.0 : peak * 1.15;

    String money(int v) =>
        formatTaka(Taka(v), numerals: numerals, grouping: grouping);

    return Semantics(
      container: true,
      label: [
        for (final e in income)
          '${formatMonth(e.month, language: language, numerals: numerals)}: ${money(e.amount)}',
      ].join('; '),
      child: ExcludeSemantics(
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: top,
              alignment: BarChartAlignment.spaceAround,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= income.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            monthShortName(income[i].month.month, language),
                            style: style,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => scheme.inverseSurface,
                  tooltipBorderRadius: BorderRadius.circular(16),
                  getTooltipItem: (group, _, rod, _) {
                    final e = income[group.x];
                    return BarTooltipItem(
                      '${formatMonth(e.month, language: language, numerals: numerals)}\n${money(e.amount)}',
                      TextStyle(color: scheme.onInverseSurface, fontSize: 12),
                    );
                  },
                ),
              ),
              barGroups: [
                for (var i = 0; i < income.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: income[i].amount.toDouble(),
                        width: 16,
                        // This month stands out; past months sit back.
                        color: i == income.length - 1
                            ? o.accent
                            : o.accentDecor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(OrganicRadius.pill),
                          bottom: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
