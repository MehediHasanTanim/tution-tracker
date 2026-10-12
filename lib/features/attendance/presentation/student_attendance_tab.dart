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
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/organic_widgets.dart';
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
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
        OrganicPanel(
          radius: OrganicRadius.panel,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatMonth(
                        month,
                        language: language,
                        numerals: numerals,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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
              const SizedBox(height: 4),
              _CalendarGrid(month: month, marks: marks, today: today),
              const SizedBox(height: 12),
              const _Legend(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          style: FilledButton.styleFrom(
            backgroundColor: Organic.of(context).sage,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: () => _share(month, counts),
          icon: const Icon(Icons.share_rounded),
          label: Text(l10n.attShare),
        ),
      ],
    );
  }
}

/// Colour plus a glyph, so a day is readable without telling colours apart.
/// The handoff's calendar: present sage, absent deep terracotta, late
/// neutral.
(Color, Color, String, String) _look(
  DayStatus status,
  Organic o,
  AppLocalizations l10n,
) => switch (status) {
  DayStatus.present => (o.sageSoft, o.onSageSoft, '✓', l10n.attStatusPresent),
  DayStatus.late => (o.neutralSoft, o.onNeutralSoft, 'L', l10n.attStatusLate),
  DayStatus.absent => (o.accentStrong, Colors.white, '✗', l10n.attStatusAbsent),
  DayStatus.excused => (
    o.accentSoft,
    o.onAccentSoft,
    'E',
    l10n.attStatusExcused,
  ),
  DayStatus.cancelled => (o.raised, o.muted, '–', l10n.classCancelled),
  DayStatus.holiday => (o.raised, o.muted, 'H', l10n.classHoliday),
};

class _CalendarGrid extends ConsumerWidget {
  const _CalendarGrid({
    required this.month,
    required this.marks,
    required this.today,
  });

  final YearMonth month;
  final List<DayMark> marks;
  final LocalDate today;

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
            style: theme.textTheme.labelSmall?.copyWith(
              color: Organic.of(context).muted,
            ),
          ),
        ),
      for (var i = 0; i < offset; i++) const SizedBox.shrink(),
      for (var d = 1; d <= month.daysInMonth; d++)
        _DayCell(
          day: d,
          status: byDay[d],
          numerals: numerals,
          date: LocalDate(month.year, month.month, d),
          isToday: LocalDate(month.year, month.month, d) == today,
          l10n: l10n,
        ),
    ];

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
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
    required this.isToday,
    required this.l10n,
  });

  final int day;
  final DayStatus? status;
  final NumeralStyle numerals;
  final LocalDate date;
  final bool isToday;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final o = Organic.of(context);
    final look = status == null ? null : _look(status!, o, l10n);
    final dayText = formatCount(day, numerals);
    final fg = look?.$2 ?? o.subtle;
    return Semantics(
      label: look == null ? dayText : '$dayText, ${look.$4}',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: look?.$1,
          shape: BoxShape.circle,
          border: isToday ? Border.all(color: o.text, width: 2) : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
                if (look != null)
                  Text(look.$3, style: TextStyle(fontSize: 10, color: fg)),
              ],
            ),
          ),
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
    final o = Organic.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final s in DayStatus.values)
          Builder(
            builder: (context) {
              final look = _look(s, o, l10n);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: look.$1,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      look.$3,
                      style: TextStyle(fontSize: 11, color: look.$2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(look.$4, style: Theme.of(context).textTheme.bodySmall),
                ],
              );
            },
          ),
      ],
    );
  }
}
