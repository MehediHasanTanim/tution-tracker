import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/features/attendance/data/attendance_providers.dart';
import 'package:tution_tracker/features/attendance/domain/session_models.dart';
import 'package:tution_tracker/features/batches/data/batch_providers.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Lets the tutor pick a batch or a one-to-one student for a class that is
/// not on the schedule (spec AT-3), then opens its attendance sheet.
Future<void> showExtraClassSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _ExtraClassSheet(),
  );
}

class _ExtraClassSheet extends ConsumerStatefulWidget {
  const _ExtraClassSheet();

  @override
  ConsumerState<_ExtraClassSheet> createState() => _ExtraClassSheetState();
}

class _ExtraClassSheetState extends ConsumerState<_ExtraClassSheet> {
  bool _students = false;
  ClockTime? _time;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 16, minute: 0),
    );
    if (picked != null) {
      setState(() => _time = ClockTime(picked.hour, picked.minute));
    }
  }

  Future<void> _choose(ClassOwner owner) async {
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    final date = ref.read(selectedDateProvider);
    final repo = await ref.read(attendanceRepositoryProvider.future);
    final session = await repo.addExtraClass(
      owner: owner,
      date: date,
      startTime: _time,
    );
    navigator.pop();
    await router.push(attendanceLocation(owner, date, session.startTime));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final batches = ref.watch(batchSummariesProvider).value ?? const [];
    final students = ref.watch(studentChoicesProvider('')).value ?? const [];

    final entries = _students
        ? [
            for (final s in students)
              (name: s.name, owner: ClassOwner.student(s.id, s.name)),
          ]
        : [
            for (final b in batches)
              (
                name: b.batch.name,
                owner: ClassOwner.batch(b.batch.id, b.batch.name),
              ),
          ];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.homeExtraTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.homeExtraBatches)),
                ButtonSegment(value: true, label: Text(l10n.homeExtraStudents)),
              ],
              selected: {_students},
              onSelectionChanged: (v) => setState(() => _students = v.first),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(l10n.homeExtraTime),
            subtitle: _time == null
                ? null
                : Text(applyNumerals(_time!.toKey(), numerals)),
            trailing: _time == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _time = null),
                  ),
            onTap: _pickTime,
          ),
          const Divider(height: 1),
          Flexible(
            child: entries.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(l10n.homeExtraNone)),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      for (final e in entries)
                        ListTile(
                          title: Text(e.name),
                          onTap: () => _choose(e.owner),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
