import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/features/reports/data/report_repository.dart';

/// Cash received per month. One series, so one colour and no legend; the
/// section title names it. Bars are thin with a rounded top, the grid is
/// faint, and touching a bar shows its exact amount.
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
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: top / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
              ),
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
                        width: 12,
                        color: scheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
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
