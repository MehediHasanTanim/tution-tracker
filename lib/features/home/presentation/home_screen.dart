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
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/organic_widgets.dart';
import 'package:tution_tracker/features/attendance/data/attendance_providers.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:tution_tracker/features/attendance/presentation/mark_off_sheet.dart';
import 'package:tution_tracker/features/backup/presentation/backup_banner.dart';
import 'package:tution_tracker/features/fees/presentation/fees_providers.dart';
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
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: const [
            _Greeting(),
            SizedBox(height: 16),
            _SampleBanner(),
            BackupBanner(),
            _MonthCard(),
            SizedBox(height: 24),
            _ClassesSection(),
            SizedBox(height: 24),
            _UpcomingSection(),
          ],
        ),
      ),
    );
  }
}

/// Today's date, a greeting with the tutor's name, and their initial.
class _Greeting extends ConsumerWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final o = Organic.of(context);
    final today = todayFrom(ref.watch(clockProvider));
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final name = ref.watchSetting(SettingKeys.tutorName).trim();
    final date =
        '${weekdayName(today.isoWeekday, language)}, '
        '${formatDate(today, language: language, numerals: numerals)}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: theme.textTheme.bodyMedium?.copyWith(color: o.muted),
              ),
              // The tab's name stays in the semantics tree for screen readers.
              Semantics(
                header: true,
                label: l10n.navHome,
                child: ExcludeSemantics(
                  child: Text(
                    name.isEmpty
                        ? l10n.homeGreetingPlain
                        : l10n.homeGreeting(name),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ExcludeSemantics(
          child: CircleAvatar(
            radius: 24,
            backgroundColor: o.sageSoft,
            foregroundColor: o.onSageSoft,
            child: Text(
              name.isEmpty
                  ? l10n.appTitle.characters.first
                  : name.characters.first,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}

/// The month at a glance: collected out of expected on a terracotta card,
/// then what is still owed and how many students are overdue.
class _MonthCard extends ConsumerWidget {
  const _MonthCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final o = Organic.of(context);
    final today = todayFrom(ref.watch(clockProvider));
    final month = YearMonth.from(today);
    final summary = ref.watch(monthSummaryProvider(month));
    final owing = ref.watch(owingProvider(today));
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;
    String money(int v) =>
        formatTaka(Taka(v), numerals: numerals, grouping: grouping);

    final s = summary.value;
    final o2 = owing.value;
    if (s == null || o2 == null) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final share = s.expected == 0 ? 0.0 : s.collected / s.expected;
    final heroText = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          label: l10n.homeMonthTitle,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(OrganicRadius.panel),
            child: ColoredBox(
              color: o.accentSoft,
              child: Stack(
                children: [
                  // The handoff's soft circle, tucked into the top corner.
                  PositionedDirectional(
                    end: -30,
                    top: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: o.accentDecor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeCollectedMonth(
                            formatMonth(
                              month,
                              language: language,
                              numerals: numerals,
                            ),
                          ),
                          style: heroText.labelLarge?.copyWith(
                            color: o.onAccentSoft,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            money(s.collected),
                            style: heroText.displayMedium?.copyWith(
                              color: o.onAccentSoft,
                            ),
                          ),
                        ),
                        Text(
                          l10n.homeOfExpected(money(s.expected)),
                          style: heroText.bodyMedium?.copyWith(
                            color: o.onAccentSoft,
                          ),
                        ),
                        const SizedBox(height: 14),
                        PillProgress(
                          value: share,
                          height: 12,
                          color: o.accent,
                          track: o.track,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Tile(
                  label: l10n.homeOutstanding,
                  value: money(s.outstanding),
                  background: o.surface,
                  foreground: o.text,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Tile(
                  label: l10n.filterOverdue,
                  value: '${formatCount(o2.overdueStudents, numerals)} →',
                  semanticLabel: l10n.homeOverdueStudents(
                    formatCount(o2.overdueStudents, numerals),
                  ),
                  background: o.accentStrong,
                  foreground: Colors.white,
                  onTap: () {
                    ref
                        .read(dueFilterProvider.notifier)
                        .setMode(DueMode.overdue);
                    context.go('/fees');
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            l10n.homeTotalOwed(money(o2.totalOutstanding)),
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
    this.semanticLabel,
    this.onTap,
  });

  final String label;
  final String value;
  final String? semanticLabel;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: OrganicPanel(
        color: background,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: foreground),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
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
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(OrganicRadius.card),
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
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleLarge),
                      Text(
                        formatDate(
                          date,
                          language: language,
                          numerals: numerals,
                          calendar: watchCalendar(ref),
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
              tooltip: l10n.homePrevDay,
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => notifier.shift(-1),
            ),
            IconButton(
              tooltip: l10n.homeNextDay,
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () => notifier.shift(1),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
                    for (final c in list)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ClassCard(session: c, date: date),
                      ),
                  ],
                ),
        ),
        // The design's dashed "Extra class" pill, under the day's classes.
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            onPressed: () => showExtraClassSheet(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.homeAddExtra),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: Organic.of(context).accent.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
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

  bool get _isOff =>
      session.state == ClassState.cancelled ||
      session.state == ClassState.holiday;

  /// Cancel, holiday and restore straight from the Today list (spec AT-4).
  Future<void> _onMenu(BuildContext context, WidgetRef ref, String v) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = await ref.read(attendanceRepositoryProvider.future);
    if (v == 'restore') {
      await repo.reopen(session.record!.id);
      return;
    }
    if (!context.mounted) return;
    final result = await showMarkOffSheet(context);
    if (result == null) return;
    await repo.markOff(
      owner: session.owner,
      date: date,
      startTime: session.startTime,
      status: result.status,
      reason: result.note,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.status == SessionStatus.cancelled
              ? l10n.classCancelled
              : l10n.classHoliday,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final o = Organic.of(context);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;

    final (label, background, foreground) = switch (session.state) {
      ClassState.notTaken => (l10n.classNotTaken, o.accent, o.onAccent),
      ClassState.taken => (l10n.classTaken, o.sageSoft, o.onSageSoft),
      ClassState.cancelled => (
        l10n.classCancelled,
        o.neutralSoft,
        o.onNeutralSoft,
      ),
      ClassState.holiday => (l10n.classHoliday, o.accentSoft, o.onAccentSoft),
    };

    final record = session.record;
    final detail = [
      if (session.state == ClassState.taken && record != null)
        l10n.classAttended(
          formatCount(record.attendedCount, numerals),
          formatCount(record.attendanceCount, numerals),
        ),
      if (session.isExtra) l10n.classExtra,
    ].join(' · ');
    final clock = session.startTime == null
        ? null
        : formatClockParts(
            session.startTime!,
            language: language,
            numerals: numerals,
          );

    return OrganicPanel(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 4, 12),
      onTap: () => context.push(
        attendanceLocation(session.owner, date, session.startTime),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            if (clock != null) ...[
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clock.time,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(clock.period, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.owner.name, style: theme.textTheme.titleMedium),
                  if (detail.isNotEmpty)
                    Text(detail, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusPill(
              label: label,
              background: background,
              foreground: foreground,
              height: 36,
            ),
            PopupMenuButton<String>(
              tooltip: l10n.homeClassMenu,
              icon: const Icon(Icons.more_vert),
              onSelected: (v) => _onMenu(context, ref, v),
              itemBuilder: (context) => [
                if (!_isOff)
                  PopupMenuItem(value: 'off', child: Text(l10n.offAction))
                else if (session.record != null)
                  PopupMenuItem(value: 'restore', child: Text(l10n.attRestore)),
              ],
            ),
          ],
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

    final o = Organic.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          l10n.homeUpcoming,
          trailing: TextButton(
            onPressed: () => context.go('/fees'),
            child: Text(l10n.homeSeeAll),
          ),
        ),
        if (dues.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.homeUpcomingNone,
              style: theme.textTheme.bodyMedium?.copyWith(color: o.muted),
            ),
          ),
        for (final d in dues)
          InkWell(
            borderRadius: BorderRadius.circular(OrganicRadius.card),
            onTap: () => context.push('/fees/pay/${d.studentId}'),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        d.studentName,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${formatDate(d.dueDate, language: language, numerals: numerals, calendar: watchCalendar(ref))}'
                      ' · '
                      '${formatTaka(Taka(d.balance), numerals: numerals, grouping: grouping)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: o.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
        margin: EdgeInsets.zero,
        color: Organic.of(context).sageSoft,
        child: ListTile(
          leading: const Icon(Icons.auto_awesome_rounded),
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
