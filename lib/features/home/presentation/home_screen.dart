import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/features/attendance/data/attendance_providers.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:tution_tracker/features/backup/presentation/backup_banner.dart';
import 'package:tution_tracker/features/home/presentation/extra_class_sheet.dart';
import 'package:tution_tracker/features/onboarding/data/onboarding_providers.dart';
import 'package:tution_tracker/features/reports/data/report_providers.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// The Today screen: this month's money at a glance, the day's classes, and
/// fees falling due this week (spec DB-1, AT-1).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navHome)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showExtraClassSheet(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.homeAddExtra),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: const [
          _SampleBanner(),
          BackupBanner(),
          _MonthCard(),
          SizedBox(height: 16),
          _ClassesSection(),
          SizedBox(height: 16),
          _UpcomingSection(),
        ],
      ),
    );
  }
}

class _MonthCard extends ConsumerWidget {
  const _MonthCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = todayFrom(ref.watch(clockProvider));
    final summary = ref.watch(monthSummaryProvider(YearMonth.from(today)));
    final owing = ref.watch(owingProvider(today));
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;
    String money(int v) =>
        formatTaka(Taka(v), numerals: numerals, grouping: grouping);

    final s = summary.value;
    final o = owing.value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: s == null || o == null
            ? const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.homeMonthTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Figure(l10n.homeExpected, money(s.expected)),
                      _Figure(l10n.homeCollected, money(s.collected)),
                      _Figure(l10n.homeOutstanding, money(s.outstanding)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.homeTotalOwed(money(o.totalOutstanding)),
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (o.overdueStudents > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ActionChip(
                        avatar: const Icon(Icons.warning_amber, size: 18),
                        label: Text(
                          l10n.homeOverdueStudents(
                            formatCount(o.overdueStudents, numerals),
                          ),
                        ),
                        onPressed: () => context.go('/fees'),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ClassesSection extends ConsumerWidget {
  const _ClassesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = todayFrom(ref.watch(clockProvider));
    final date = ref.watch(selectedDateProvider);
    final notifier = ref.read(selectedDateProvider.notifier);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final classes = ref.watch(expectedSessionsProvider(date));

    final isToday = date == today;
    final title = isToday
        ? l10n.homeToday
        : weekdayName(date.isoWeekday, language);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.homePrevDay,
              icon: const Icon(Icons.chevron_left),
              onPressed: () => notifier.shift(-1),
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(date.year, date.month, date.day),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(today.year + 1, 12, 31),
                    helpText: l10n.homePickDate,
                  );
                  if (picked != null) {
                    notifier.set(LocalDate.fromDateTime(picked));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      Text(
                        formatDate(
                          date,
                          language: language,
                          numerals: numerals,
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isToday)
              TextButton(
                onPressed: notifier.resetToToday,
                child: Text(l10n.homeToday),
              ),
            IconButton(
              tooltip: l10n.homeNextDay,
              icon: const Icon(Icons.chevron_right),
              onPressed: () => notifier.shift(1),
            ),
          ],
        ),
        classes.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('$e'),
          data: (list) => list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.homeNoClasses)),
                )
              : Column(
                  children: [
                    for (final c in list) _ClassCard(session: c, date: date),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ClassCard extends ConsumerWidget {
  const _ClassCard({required this.session, required this.date});

  final ExpectedSession session;
  final LocalDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;

    final (label, color, icon) = switch (session.state) {
      ClassState.notTaken => (
        l10n.classNotTaken,
        scheme.surfaceContainerHighest,
        Icons.radio_button_unchecked,
      ),
      ClassState.taken => (
        l10n.classTaken,
        scheme.primaryContainer,
        Icons.check_circle,
      ),
      ClassState.cancelled => (
        l10n.classCancelled,
        scheme.errorContainer,
        Icons.event_busy,
      ),
      ClassState.holiday => (
        l10n.classHoliday,
        scheme.tertiaryContainer,
        Icons.beach_access,
      ),
    };

    final record = session.record;
    final detail = [
      if (session.startTime != null)
        applyNumerals(session.startTime!.toKey(), numerals),
      if (session.state == ClassState.taken && record != null)
        l10n.classAttended(
          formatCount(record.attendedCount, numerals),
          formatCount(record.attendanceCount, numerals),
        ),
      if (session.isExtra) l10n.classExtra,
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(session.owner.name),
        subtitle: detail.isEmpty ? null : Text(detail),
        trailing: Chip(
          avatar: Icon(icon, size: 18),
          label: Text(label),
          backgroundColor: color,
          visualDensity: VisualDensity.compact,
        ),
        onTap: () => context.push(
          attendanceLocation(session.owner, date, session.startTime),
        ),
      ),
    );
  }
}

class _UpcomingSection extends ConsumerWidget {
  const _UpcomingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = todayFrom(ref.watch(clockProvider));
    final dues = ref.watch(upcomingDuesProvider(today)).value;
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;
    if (dues == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.homeUpcoming,
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/fees'),
              child: Text(l10n.homeSeeAll),
            ),
          ],
        ),
        if (dues.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.homeUpcomingNone),
          ),
        for (final d in dues)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(d.studentName),
            subtitle: Text(
              formatDate(d.dueDate, language: language, numerals: numerals),
            ),
            trailing: Text(
              formatTaka(
                Taka(d.balance),
                numerals: numerals,
                grouping: grouping,
              ),
            ),
            onTap: () => context.push('/fees/pay/${d.studentId}'),
          ),
      ],
    );
  }
}

/// Shown while sample data is loaded, with one-tap removal (spec ON-5).
class _SampleBanner extends ConsumerWidget {
  const _SampleBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!(ref.watch(sampleLoadedProvider).value ?? false)) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: ListTile(
          leading: const Icon(Icons.auto_awesome_outlined),
          title: Text(l10n.sampleBanner),
          trailing: TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final service = await ref.read(sampleDataServiceProvider.future);
              await service.remove();
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.sampleRemoved)),
              );
            },
            child: Text(l10n.sampleRemove),
          ),
        ),
      ),
    );
  }
}
