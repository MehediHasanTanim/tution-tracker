import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
import 'package:tution_tracker/core/ui/time_chips.dart';
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
  ClassOwner? _owner;

  Future<void> _add() async {
    final owner = _owner;
    if (owner == null) return;
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
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final date = ref.watch(selectedDateProvider);
    final batches = ref.watch(batchSummariesProvider).value ?? const [];
    final students = ref.watch(studentChoicesProvider('')).value ?? const [];

    final entries = _students
        ? [for (final s in students) ClassOwner.student(s.id, s.name)]
        : [for (final b in batches) ClassOwner.batch(b.batch.id, b.batch.name)];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        28 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: BlockStack(
        children: [
          BlockSubheading(l10n.homeExtraTitle),
          BlockText(
            l10n.homeExtraWhen(
              '${weekdayName(date.isoWeekday, language)}, '
              '${formatDate(date, language: language, numerals: numerals)}',
            ),
          ),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(l10n.homeExtraBatches)),
              ButtonSegment(value: true, label: Text(l10n.homeExtraStudents)),
            ],
            selected: {_students},
            onSelectionChanged: (v) => setState(() {
              _students = v.first;
              _owner = null;
            }),
          ),
          if (entries.isEmpty)
            BlockText(l10n.homeExtraNone)
          else
            BlockChips<ClassOwner>(
              options: [for (final e in entries) (e, e.name)],
              isSelected: (e) => e == _owner,
              onTap: (e) => setState(() => _owner = e),
            ),
          BlockText(l10n.homeExtraTime),
          ClassTimeChips(
            value: _time,
            language: language,
            numerals: numerals,
            onChanged: (t) => setState(() => _time = t),
          ),
          BlockButton(
            l10n.homeExtraAdd,
            onPressed: _owner == null ? null : _add,
          ),
        ],
      ),
    );
  }
}
