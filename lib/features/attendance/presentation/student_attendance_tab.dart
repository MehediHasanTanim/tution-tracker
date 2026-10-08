import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/platform/share_service.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/attendance/data/attendance_providers.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_message.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_stats.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// A student's month of attendance: totals, a calendar, and a button to send
/// the guardian a summary (spec AT-8, AT-10).
class StudentAttendanceTab extends ConsumerStatefulWidget {
  const StudentAttendanceTab({required this.student, super.key});

  final Student student;

  @override
  ConsumerState<StudentAttendanceTab> createState() =>
      _StudentAttendanceTabState();
}

class _StudentAttendanceTabState extends ConsumerState<StudentAttendanceTab> {
  YearMonth? _month;

  Future<void> _share(YearMonth month, AttendanceCounts counts) async {
    final l10n = AppLocalizations.of(context);
    final language = ref.read(appLanguageProvider);
    final numerals =
        ref.read(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final tutor = ref.read(tutorProfileProvider).value?.name ?? '';
    final text = composeAttendanceSummary(
      l10n: l10n,
      studentName: widget.student.name,
      monthText: formatMonth(month, language: language, numerals: numerals),
      counts: counts,
      numerals: numerals,
      tutorName: tutor,
    );
    await ref.read(shareServiceProvider).shareText(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final today = todayFrom(ref.watch(clockProvider));
    final month = _month ?? YearMonth.from(today);
    final key = (studentId: widget.student.id, month: month);
    final counts =
        ref.watch(studentMonthProvider(key)).value ?? AttendanceCounts.none;
    final marks = ref.watch(studentCalendarProvider(key)).value ?? const [];
    String n(int v) => formatCount(v, numerals);

    Widget stat(String label, int value) => Chip(
      label: Text('$label ${n(value)}'),
      visualDensity: VisualDensity.compact,
    );

    return ListView(
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
        Wrap(
          spacing: 8,
          children: [
            stat(l10n.attClassesCount, counts.total),
            stat(l10n.attStatusPresent, counts.present),
            stat(l10n.attStatusLate, counts.late),
            stat(l10n.attStatusAbsent, counts.absent),
            stat(l10n.attStatusExcused, counts.excused),
            if (counts.percent != null)
              stat(l10n.attRate, counts.percent!)
            else
              const SizedBox.shrink(),
          ],
        ),
        if (counts.total == 0 && marks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(child: Text(l10n.attNoClasses)),
          ),
        const SizedBox(height: 12),
        _CalendarGrid(month: month, marks: marks),
        const SizedBox(height: 8),
        const _Legend(),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () => _share(month, counts),
          icon: const Icon(Icons.share),
          label: Text(l10n.attShare),
        ),
      ],
    );
  }
}

/// Colour plus a glyph, so a day is readable without telling colours apart.
(Color, String, String) _look(
  DayStatus status,
  ColorScheme scheme,
  AppLocalizations l10n,
) => switch (status) {
  DayStatus.present => (scheme.primaryContainer, '✓', l10n.attStatusPresent),
  DayStatus.late => (scheme.tertiaryContainer, 'L', l10n.attStatusLate),
  DayStatus.absent => (scheme.errorContainer, '✗', l10n.attStatusAbsent),
  DayStatus.excused => (scheme.secondaryContainer, 'E', l10n.attStatusExcused),
  DayStatus.cancelled => (
    scheme.surfaceContainerHighest,
    '–',
    l10n.classCancelled,
  ),
  DayStatus.holiday => (scheme.surfaceContainerHighest, 'H', l10n.classHoliday),
};

class _CalendarGrid extends ConsumerWidget {
  const _CalendarGrid({required this.month, required this.marks});

  final YearMonth month;
  final List<DayMark> marks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final byDay = {for (final m in marks) m.date.day: m.status};

    // Weeks start on Saturday. ISO weekday: Mon=1 .. Sun=7.
    final offset = (month.firstDay.isoWeekday + 1) % 7;
    const weekdayOrder = [6, 7, 1, 2, 3, 4, 5];

    final cells = <Widget>[
      for (final w in weekdayOrder)
        Center(
          child: Text(
            weekdayShortName(w, language),
            style: theme.textTheme.labelSmall,
          ),
        ),
      for (var i = 0; i < offset; i++) const SizedBox.shrink(),
      for (var d = 1; d <= month.daysInMonth; d++)
        _DayCell(
          day: d,
          status: byDay[d],
          numerals: numerals,
          date: LocalDate(month.year, month.month, d),
          l10n: l10n,
        ),
    ];

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.status,
    required this.numerals,
    required this.date,
    required this.l10n,
  });

  final int day;
  final DayStatus? status;
  final NumeralStyle numerals;
  final LocalDate date;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final look = status == null ? null : _look(status!, scheme, l10n);
    final dayText = formatCount(day, numerals);
    return Semantics(
      label: look == null ? dayText : '$dayText, ${look.$3}',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: look?.$1,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dayText, style: Theme.of(context).textTheme.bodySmall),
            if (look != null)
              Text(look.$2, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final s in DayStatus.values)
          Builder(
            builder: (context) {
              final look = _look(s, scheme, l10n);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: look.$1,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(look.$2, style: const TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 4),
                  Text(look.$3, style: Theme.of(context).textTheme.bodySmall),
                ],
              );
            },
          ),
      ],
    );
  }
}
