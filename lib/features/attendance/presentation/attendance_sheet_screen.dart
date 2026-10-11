import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/features/attendance/data/attendance_providers.dart';
import 'package:tution_tracker/features/attendance/domain/attendance_stats.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:tution_tracker/features/fees/presentation/fields_dialog.dart';
import 'package:tution_tracker/features/students/presentation/student_avatar.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Takes attendance for one class on one date: everyone starts as present
/// and the tutor flips the exceptions (spec flow A).
class AttendanceSheetScreen extends ConsumerWidget {
  const AttendanceSheetScreen({required this.args, super.key});

  final SheetArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final data = ref.watch(sheetDataProvider(args));
    return data.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('$e')),
      ),
      data: (d) {
        if (d.ownerName == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.studentsNoMatch)),
          );
        }
        return _SheetView(
          // A fresh state whenever the class's status changes (restored).
          key: ValueKey(d.session?.status),
          args: args,
          data: d,
        );
      },
    );
  }
}

class _SheetView extends ConsumerStatefulWidget {
  const _SheetView({required this.args, required this.data, super.key});

  final SheetArgs args;
  final SheetData data;

  @override
  ConsumerState<_SheetView> createState() => _SheetViewState();
}

enum _Leave { save, discard, stay }

class _SheetViewState extends ConsumerState<_SheetView> {
  late final Map<String, AttendanceStatus> _marks = {
    for (final e in widget.data.roster)
      e.student.id: e.status ?? AttendanceStatus.present,
  };
  late final _topic = TextEditingController(
    text: widget.data.session?.topic ?? '',
  );
  bool _dirty = false;
  bool _saving = false;

  SessionRecord? get _session => widget.data.session;

  bool get _isOff => _session != null && _session!.status != SessionStatus.held;

  @override
  void dispose() {
    _topic.dispose();
    super.dispose();
  }

  void _mark(String studentId, AttendanceStatus status) {
    if (_marks[studentId] == status) return;
    setState(() {
      _marks[studentId] = status;
      _dirty = true;
    });
  }

  void _markAllPresent() {
    setState(() {
      for (final id in _marks.keys) {
        _marks[id] = AttendanceStatus.present;
      }
      _dirty = true;
    });
  }

  Future<bool> _save() async {
    if (_saving) return false;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final repo = await ref.read(attendanceRepositoryProvider.future);
      await repo.saveAttendance(
        owner: widget.args.owner,
        date: widget.args.date,
        startTime: widget.args.time,
        topic: _topic.text,
        marks: Map.of(_marks),
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.attSaved)));
      return true;
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.genericError)));
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveAndClose() async {
    final router = GoRouter.of(context);
    if (await _save()) {
      _dirty = false;
      if (router.canPop()) router.pop();
    }
  }

  /// Asks what to do with unsaved changes when the tutor goes back.
  Future<void> _confirmLeave() async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final choice = await showDialog<_Leave>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.attDiscardTitle),
        content: Text(l10n.attDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _Leave.stay),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _Leave.discard),
            child: Text(l10n.attDiscard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _Leave.save),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    switch (choice) {
      case _Leave.save:
        if (await _save()) {
          _dirty = false;
          if (router.canPop()) router.pop();
        }
      case _Leave.discard:
        _dirty = false;
        if (router.canPop()) router.pop();
      case _Leave.stay || null:
        break;
    }
  }

  Future<void> _markOff(SessionStatus status) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final result = await showDialog<FieldsResult>(
      context: context,
      builder: (_) => FieldsDialog(
        title: status == SessionStatus.cancelled
            ? l10n.attCancelClass
            : l10n.attHoliday,
        fields: [
          DialogField(key: 'reason', label: l10n.attReason, required: false),
        ],
      ),
    );
    if (result == null) return;
    final repo = await ref.read(attendanceRepositoryProvider.future);
    await repo.markOff(
      owner: widget.args.owner,
      date: widget.args.date,
      startTime: widget.args.time,
      status: status,
      reason: result.values['reason'],
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          status == SessionStatus.cancelled
              ? l10n.classCancelled
              : l10n.classHoliday,
        ),
      ),
    );
    _dirty = false;
    if (router.canPop()) router.pop();
  }

  Future<void> _restore() async {
    final repo = await ref.read(attendanceRepositoryProvider.future);
    await repo.reopen(_session!.id);
    ref.invalidate(sheetDataProvider(widget.args));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final args = widget.args;
    final roster = widget.data.roster;
    final counts = AttendanceCounts.from(_marks.values);

    final clock = args.time == null
        ? null
        : formatClockParts(args.time!, language: language, numerals: numerals);
    final time = clock == null ? '' : ' · ${clock.time} ${clock.period}';
    final subtitle =
        '${weekdayName(args.date.isoWeekday, language)}, ${formatDate(args.date, language: language, numerals: numerals, calendar: watchCalendar(ref))}$time';

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data.ownerName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
          actions: [
            if (!_isOff && roster.isNotEmpty)
              IconButton(
                tooltip: l10n.attMarkAllPresent,
                icon: const Icon(Icons.done_all_rounded),
                onPressed: _markAllPresent,
              ),
            PopupMenuButton<String>(
              onSelected: (v) {
                switch (v) {
                  case 'cancel':
                    _markOff(SessionStatus.cancelled);
                  case 'holiday':
                    _markOff(SessionStatus.holiday);
                  case 'restore':
                    _restore();
                }
              },
              itemBuilder: (context) => [
                if (!_isOff) ...[
                  PopupMenuItem(
                    value: 'cancel',
                    child: Text(l10n.attCancelClass),
                  ),
                  PopupMenuItem(value: 'holiday', child: Text(l10n.attHoliday)),
                ] else
                  PopupMenuItem(value: 'restore', child: Text(l10n.attRestore)),
              ],
            ),
          ],
        ),
        body: _isOff ? _offBody(context) : _marksBody(context, counts),
        bottomNavigationBar: _isOff || roster.isEmpty
            ? null
            : DecoratedBox(
                // The handoff's raised footer: summary over a full-width save.
                decoration: BoxDecoration(
                  color: Organic.of(context).raised,
                  border: Border(
                    top: BorderSide(color: Organic.of(context).divider),
                  ),
                ),
                child: SafeArea(
                  minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${l10n.attStatusPresent} ${formatCount(counts.present, numerals)} · '
                        '${l10n.attStatusAbsent} ${formatCount(counts.absent, numerals)} · '
                        '${l10n.attStatusLate} ${formatCount(counts.late, numerals)} · '
                        '${l10n.attStatusExcused} ${formatCount(counts.excused, numerals)}',
                        style: theme.textTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                          ),
                          onPressed: _saving ? null : _saveAndClose,
                          child: Text(l10n.actionSave),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _offBody(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final holiday = _session!.status == SessionStatus.holiday;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              holiday ? Icons.beach_access_rounded : Icons.event_busy_rounded,
              size: 64,
              color: Organic.of(context).accentDecor,
            ),
            const SizedBox(height: 16),
            Text(
              holiday ? l10n.attHolidayBanner : l10n.attCancelledBanner,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (_session!.note != null) ...[
              const SizedBox(height: 8),
              Text(_session!.note!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: _restore,
              child: Text(l10n.attRestore),
            ),
          ],
        ),
      ),
    );
  }

  Widget _marksBody(BuildContext context, AttendanceCounts counts) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final o = Organic.of(context);
    final roster = widget.data.roster;
    if (roster.isEmpty) {
      return Center(child: Text(l10n.attNoStudents));
    }

    // The handoff's attendance colours: present sage, absent deep
    // terracotta, late neutral; excused is a soft terracotta tint.
    (String, Color, Color) style(AttendanceStatus s) => switch (s) {
      AttendanceStatus.present => (
        l10n.attStatusPresent,
        o.sageSoft,
        o.onSageSoft,
      ),
      AttendanceStatus.absent => (
        l10n.attStatusAbsent,
        o.accentStrong,
        Colors.white,
      ),
      AttendanceStatus.late => (
        l10n.attStatusLate,
        o.neutralSoft,
        o.onNeutralSoft,
      ),
      AttendanceStatus.excused => (
        l10n.attStatusExcused,
        o.accentSoft,
        o.onAccentSoft,
      ),
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      children: [
        Text(l10n.attMarkHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 10),
        TextField(
          controller: _topic,
          decoration: InputDecoration(labelText: l10n.attTopic),
          onChanged: (_) {
            if (!_dirty) setState(() => _dirty = true);
          },
        ),
        const SizedBox(height: 8),
        for (final entry in roster)
          Card(
            child: ListTile(
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                12,
                6,
                12,
                6,
              ),
              leading: StudentAvatar(
                name: entry.student.name,
                photoPath: entry.student.photoPath,
              ),
              // Tapping the name flips present and absent: one tap per
              // absentee.
              title: Text(
                entry.student.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _mark(
                entry.student.id,
                _marks[entry.student.id] == AttendanceStatus.absent
                    ? AttendanceStatus.present
                    : AttendanceStatus.absent,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in AttendanceStatus.values)
                      ChoiceChip(
                        label: Text(style(s).$1),
                        selected: _marks[entry.student.id] == s,
                        backgroundColor: o.bg,
                        selectedColor: style(s).$2,
                        labelStyle: theme.textTheme.labelMedium?.copyWith(
                          color: _marks[entry.student.id] == s
                              ? style(s).$3
                              : o.text,
                        ),
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) => _mark(entry.student.id, s),
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
