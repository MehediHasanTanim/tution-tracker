import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/digits.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/i18n/text_normalizer.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/input_formatters.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
import 'package:tution_tracker/features/batches/data/batch_providers.dart';
import 'package:tution_tracker/features/batches/data/batch_repository.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';
import 'package:tution_tracker/features/students/domain/student_options.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';
import 'package:tution_tracker/router.dart';

/// Create a batch or, with [batchId], edit one.
class BatchFormScreen extends ConsumerStatefulWidget {
  const BatchFormScreen({this.batchId, super.key});

  final String? batchId;

  @override
  ConsumerState<BatchFormScreen> createState() => _BatchFormScreenState();
}

class _BatchFormScreenState extends ConsumerState<BatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _subject = TextEditingController();
  final _duration = TextEditingController();
  final _fee = TextEditingController(text: '0');

  bool get _editing => widget.batchId != null;

  bool _loaded = false;
  bool _saving = false;
  bool _scheduleError = false;
  String? _classLevel;
  final Set<int> _days = {};
  ClockTime? _startTime;

  @override
  void dispose() {
    for (final c in [_name, _subject, _duration, _fee]) {
      c.dispose();
    }
    super.dispose();
  }

  void _populate(Batch b) {
    _name.text = b.name;
    _subject.text = b.subject ?? '';
    _duration.text = b.durationMin?.toString() ?? '';
    _fee.text = b.defaultFee.toString();
    _classLevel = b.classLevel;
    _days.addAll(b.scheduleDayList);
    _startTime = b.startTimeValue;
    _loaded = true;
  }

  Future<void> _save() async {
    final valid = _formKey.currentState!.validate();
    setState(() => _scheduleError = _days.isEmpty);
    if (!valid || _days.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final durationText = _duration.text.trim();
    final draft = BatchDraft(
      name: _name.text,
      scheduleDays: _days.toList(),
      subject: _subject.text,
      classLevel: _classLevel,
      startTime: _startTime,
      durationMin: durationText.isEmpty
          ? null
          : int.parse(toWesternDigits(durationText)),
      defaultFee: int.parse(
        toWesternDigits(_fee.text.trim().isEmpty ? '0' : _fee.text.trim()),
      ),
    );

    setState(() => _saving = true);
    try {
      final repo = await ref.read(batchRepositoryProvider.future);
      if (_editing) {
        await repo.update(widget.batchId!, draft);
      } else {
        await repo.create(draft);
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.batchSaved)));
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(AppRoutes.batches);
      }
    } on BatchValidationException {
      if (mounted) _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// The design's "delete batch": students stay, the batch and its schedule
  /// go. Stored as an archive (spec 5.2: soft delete), so the archived
  /// filter can still bring it back.
  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final yes = await showBlockSheet<bool>(
      context,
      builder: (context) => BlockStack(
        children: [
          BlockSubheading(l10n.batchDeleteTitle),
          BlockText(l10n.batchDeleteBody),
          BlockButton(
            l10n.batchDeleteYes,
            kind: BlockButtonKind.danger,
            onPressed: () => Navigator.pop(context, true),
          ),
          BlockButton(
            l10n.batchDeleteNo,
            kind: BlockButtonKind.ghost,
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
    if (yes != true) return;
    final repo = await ref.read(batchRepositoryProvider.future);
    await repo.archive(widget.batchId!);
    messenger.showSnackBar(SnackBar(content: Text(l10n.batchDeleted)));
    router.go(AppRoutes.batches);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_editing && !_loaded) {
      final batch = ref.watch(batchStreamProvider(widget.batchId!));
      return Scaffold(
        appBar: AppBar(title: Text(l10n.batchEditTitle)),
        body: batch.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (b) {
            if (b == null) return Center(child: Text(l10n.studentsNoMatch));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_loaded) setState(() => _populate(b));
            });
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }

    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    const gap = SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? l10n.batchEditTitle : l10n.batchesAdd),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Organic.of(context).raised,
          border: Border(top: BorderSide(color: Organic.of(context).divider)),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: BlockButton(
            l10n.actionSave,
            onPressed: _saving ? null : _save,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                autofocus: !_editing,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: '${l10n.batchFieldName} *',
                ),
                validator: (v) => normalizeText(v ?? '').isEmpty
                    ? l10n.errorNameRequired
                    : null,
              ),
              gap,
              TextFormField(
                controller: _subject,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.batchFieldSubject),
              ),
              gap,
              DropdownButtonFormField<String>(
                initialValue: _classLevel,
                decoration: InputDecoration(labelText: l10n.fieldClassLevel),
                items: [
                  for (final level in studentClassLevels)
                    DropdownMenuItem(value: level, child: Text(level)),
                ],
                onChanged: (v) => setState(() => _classLevel = v),
              ),
              gap,
              BlockSubheading('${l10n.fieldClassDays} *'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final day in studentWeekOrder)
                    FilterChip(
                      label: Text(weekdayName(day, language)),
                      selected: _days.contains(day),
                      onSelected: (on) => setState(() {
                        on ? _days.add(day) : _days.remove(day);
                        _scheduleError = false;
                      }),
                    ),
                ],
              ),
              if (_scheduleError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.errorScheduleRequired,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              BlockSubheading(l10n.fieldClassTime),
              const SizedBox(height: 8),
              _TimeChips(
                value: _startTime,
                language: language,
                numerals: numerals,
                onChanged: (t) => setState(() => _startTime = t),
              ),
              gap,
              TextFormField(
                controller: _duration,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  const DigitsOnlyFormatter(),
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(labelText: l10n.batchFieldDuration),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return null;
                  return int.parse(t) < 1 ? l10n.errorDurationInvalid : null;
                },
              ),
              gap,
              TextFormField(
                controller: _fee,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  const DigitsOnlyFormatter(),
                  LengthLimitingTextInputFormatter(7),
                ],
                decoration: InputDecoration(
                  labelText: l10n.batchFieldDefaultFee,
                ),
              ),
              if (_editing) ...[
                const SizedBox(height: 20),
                BlockButton(
                  l10n.batchDelete,
                  kind: BlockButtonKind.outlined,
                  onPressed: _confirmDelete,
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// The design's time chips: common class times, plus any other time and no
/// time at all.
class _TimeChips extends StatelessWidget {
  const _TimeChips({
    required this.value,
    required this.language,
    required this.numerals,
    required this.onChanged,
  });

  final ClockTime? value;
  final AppLanguage language;
  final NumeralStyle numerals;
  final ValueChanged<ClockTime?> onChanged;

  static const presets = [
    ClockTime(8, 0),
    ClockTime(10, 0),
    ClockTime(15, 30),
    ClockTime(17, 0),
    ClockTime(18, 30),
    ClockTime(19, 0),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String label(ClockTime t) {
      final p = formatClockParts(t, language: language, numerals: numerals);
      return '${p.time} ${p.period}';
    }

    final custom = value != null && !presets.contains(value);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final t in presets)
          ChoiceChip(
            label: Text(label(t)),
            selected: value == t,
            onSelected: (_) => onChanged(t),
          ),
        ChoiceChip(
          label: Text(custom ? label(value!) : l10n.timeOther),
          selected: custom,
          onSelected: (_) async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: value?.hour ?? 17,
                minute: value?.minute ?? 0,
              ),
            );
            if (picked != null) {
              onChanged(ClockTime(picked.hour, picked.minute));
            }
          },
        ),
        ChoiceChip(
          label: Text(l10n.none),
          selected: value == null,
          onSelected: (_) => onChanged(null),
        ),
      ],
    );
  }
}
