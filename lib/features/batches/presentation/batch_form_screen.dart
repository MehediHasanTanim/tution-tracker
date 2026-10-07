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
import 'package:tution_tracker/core/ui/input_formatters.dart';
import 'package:tution_tracker/features/batches/data/batch_providers.dart';
import 'package:tution_tracker/features/batches/data/batch_repository.dart';
import 'package:tution_tracker/features/batches/domain/batch_draft.dart';
import 'package:tution_tracker/features/students/domain/student_options.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

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
        router.go('/students');
      }
    } on BatchValidationException {
      if (mounted) _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(l10n.actionSave),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => normalizeText(v ?? '').isEmpty
                    ? l10n.errorNameRequired
                    : null,
              ),
              gap,
              TextFormField(
                controller: _subject,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.batchFieldSubject,
                  border: const OutlineInputBorder(),
                ),
              ),
              gap,
              DropdownButtonFormField<String>(
                initialValue: _classLevel,
                decoration: InputDecoration(
                  labelText: l10n.fieldClassLevel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final level in studentClassLevels)
                    DropdownMenuItem(value: level, child: Text(level)),
                ],
                onChanged: (v) => setState(() => _classLevel = v),
              ),
              gap,
              Text(
                '${l10n.fieldClassDays} *',
                style: Theme.of(context).textTheme.titleSmall,
              ),
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
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.fieldClassTime),
                subtitle: Text(
                  _startTime == null
                      ? l10n.none
                      : applyNumerals(_startTime!.toKey(), numerals),
                ),
                trailing: _startTime == null
                    ? const Icon(Icons.access_time)
                    : IconButton(
                        tooltip: l10n.actionClear,
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _startTime = null),
                      ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: _startTime?.hour ?? 17,
                      minute: _startTime?.minute ?? 0,
                    ),
                  );
                  if (picked != null) {
                    setState(
                      () => _startTime = ClockTime(picked.hour, picked.minute),
                    );
                  }
                },
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
                decoration: InputDecoration(
                  labelText: l10n.batchFieldDuration,
                  border: const OutlineInputBorder(),
                ),
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
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
