import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/digits.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/i18n/text_normalizer.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/platform/photo_picker.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/ui/input_formatters.dart';
import 'package:tution_tracker/core/utils/phone.dart';
import 'package:tution_tracker/features/fees/domain/due_generation.dart';
import 'package:tution_tracker/features/students/data/photo_processing.dart';
import 'package:tution_tracker/features/students/data/photo_store.dart';
import 'package:tution_tracker/features/students/data/student_form_providers.dart';
import 'package:tution_tracker/features/students/data/student_providers.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';
import 'package:tution_tracker/features/students/domain/student_options.dart';
import 'package:tution_tracker/features/students/presentation/student_avatar.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Add a student (quick or full) or, with [studentId], edit one.
class StudentFormScreen extends ConsumerStatefulWidget {
  const StudentFormScreen({this.studentId, super.key});

  final String? studentId;

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _fee = TextEditingController();
  final _school = TextEditingController();
  final _guardianName = TextEditingController();
  final _guardianPhone = TextEditingController();
  final _studentPhone = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  final _otherSubject = TextEditingController();

  bool get _editing => widget.studentId != null;

  /// New students start in quick-add; editing shows everything.
  late bool _full = _editing;

  bool _loaded = false;
  bool _saving = false;
  String? _classLevel;
  String? _photoPath; // already saved
  Uint8List? _newPhoto; // compressed, picked, not saved yet
  bool _removePhoto = false;
  int? _dueDay; // null = use the settings default
  LocalDate? _joinedOn; // null = today
  final Set<String> _subjects = {};
  final Set<int> _classDays = {};
  ClockTime? _classTime;

  @override
  void dispose() {
    for (final c in [
      _name,
      _fee,
      _school,
      _guardianName,
      _guardianPhone,
      _studentPhone,
      _address,
      _notes,
      _otherSubject,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _populate(Student s) {
    _name.text = s.name;
    _fee.text = s.monthlyFee.toString();
    _school.text = s.school ?? '';
    _guardianName.text = s.guardianName ?? '';
    _guardianPhone.text = s.guardianPhone ?? '';
    _studentPhone.text = s.studentPhone ?? '';
    _address.text = s.address ?? '';
    _notes.text = s.notes ?? '';
    _classLevel = s.classLevel;
    _photoPath = s.photoPath;
    _dueDay = s.feeDueDay;
    _joinedOn = LocalDate.parse(s.joinedOn);
    _subjects.addAll(s.subjectList);
    _classDays.addAll(s.classDayList);
    _classTime = s.classTimeValue;
    _loaded = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final clock = ref.read(clockProvider);
    // Quick-add never watches this provider, so load it here.
    final defaultDueDay = await ref.read(defaultDueDayProvider.future);

    final draft = StudentDraft(
      name: _name.text,
      monthlyFee: int.parse(toWesternDigits(_fee.text.trim())),
      joinedOn: _joinedOn ?? todayFrom(clock),
      feeDueDay: _dueDay ?? defaultDueDay,
      classLevel: _classLevel,
      school: _school.text,
      guardianName: _guardianName.text,
      guardianPhone: _guardianPhone.text,
      studentPhone: _studentPhone.text,
      address: _address.text,
      photoPath: _removePhoto ? null : _photoPath,
      subjects: _subjects.toList(),
      classDays: _classDays.toList(),
      classTime: _classTime,
      notes: _notes.text,
    );

    setState(() => _saving = true);
    try {
      final repo = await ref.read(studentRepositoryProvider.future);
      final saved = _editing
          ? await repo.update(widget.studentId!, draft)
          : await repo.create(draft);
      await _savePhoto(repo, saved);
      messenger.showSnackBar(SnackBar(content: Text(l10n.studentSaved)));
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/students');
      }
    } on StudentValidationException {
      // The form validators cover the same rules; show them again.
      if (mounted) _formKey.currentState!.validate();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Writes or removes the photo file and updates the student's path.
  Future<void> _savePhoto(StudentRepository repo, Student saved) async {
    final newPhoto = _newPhoto;
    if (newPhoto == null && !_removePhoto) return;
    final photos = await ref.read(photoStoreProvider.future);
    // Not saved.photoPath: when removing, the draft already cleared it.
    final oldPath = _photoPath;
    final newPath = newPhoto == null
        ? null
        : await photos.save(saved.id, newPhoto);
    await repo.setPhotoPath(saved.id, newPath);
    await photos.delete(oldPath);
  }

  Future<void> _pickPhoto(PhotoSource source) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final raw = await ref.read(photoPickerProvider).pick(source);
      if (raw == null) return; // cancelled
      final compressed = await ref.read(photoCompressorProvider)(raw);
      if (!mounted) return;
      setState(() {
        _newPhoto = compressed;
        _removePhoto = false;
      });
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoFailed)));
    }
  }

  Future<void> _photoMenu() async {
    final l10n = AppLocalizations.of(context);
    final hasPhoto = _newPhoto != null || (_photoPath != null && !_removePhoto);
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(l10n.photoTake),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.photoChoose),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.photoRemove),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
      ),
    );
    switch (choice) {
      case 'camera':
        await _pickPhoto(PhotoSource.camera);
      case 'gallery':
        await _pickPhoto(PhotoSource.gallery);
      case 'remove':
        setState(() {
          _newPhoto = null;
          _removePhoto = true;
        });
    }
  }

  Widget _photoPicker(AppLocalizations l10n) {
    final hasPhoto = _newPhoto != null || (_photoPath != null && !_removePhoto);
    return Center(
      child: Column(
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: _photoMenu,
            child: Stack(
              children: [
                StudentAvatar(
                  name: _name.text.trim().isEmpty ? '?' : _name.text.trim(),
                  photoPath: _removePhoto ? null : _photoPath,
                  previewBytes: _newPhoto,
                  radius: 44,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.photo_camera,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _photoMenu,
            child: Text(hasPhoto ? l10n.photoChange : l10n.photoAdd),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_editing && !_loaded) {
      final student = ref.watch(studentByIdProvider(widget.studentId!));
      return Scaffold(
        appBar: AppBar(title: Text(l10n.studentEditTitle)),
        body: student.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (s) {
            if (s == null) return Center(child: Text(l10n.studentsNoMatch));
            // Populate once, then rebuild with the form.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_loaded) setState(() => _populate(s));
            });
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? l10n.studentEditTitle : l10n.studentsAdd),
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
        // A plain scroll view, not a lazy list: the form is short and every
        // field must exist so validation reaches fields that are off-screen.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_full) ...[_photoPicker(l10n), const SizedBox(height: 8)],
              TextFormField(
                controller: _name,
                autofocus: !_editing,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: '${l10n.fieldName} *',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => normalizeText(v ?? '').isEmpty
                    ? l10n.errorNameRequired
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fee,
                enabled: !_editing,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  const DigitsOnlyFormatter(),
                  LengthLimitingTextInputFormatter(7),
                ],
                decoration: InputDecoration(
                  labelText: '${l10n.fieldMonthlyFee} *',
                  helperText: _editing ? l10n.feeLockedHint : null,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l10n.errorFeeRequired : null,
              ),
              if (!_editing) _firstMonthNote(l10n),
              const SizedBox(height: 8),
              if (!_editing)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _full = !_full),
                    icon: Icon(_full ? Icons.expand_less : Icons.expand_more),
                    label: Text(_full ? l10n.fewerDetails : l10n.moreDetails),
                  ),
                ),
              if (_full) ..._fullFields(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  /// What the first month will cost, before saving (edge case 1): the full
  /// fee, a pro-rated part of it, or nothing, by the proration setting.
  Widget _firstMonthNote(AppLocalizations l10n) {
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;
    final rule = ref.watchSetting(SettingKeys.proration);
    final today = todayFrom(ref.watch(clockProvider));
    final joined = _joinedOn ?? today;
    return ListenableBuilder(
      listenable: _fee,
      builder: (context, _) {
        final fee = int.tryParse(toWesternDigits(_fee.text.trim()));
        if (fee == null || fee == 0) return const SizedBox.shrink();
        final first = prorate(fee, joined, rule);
        final String text;
        if (first == null) {
          text = l10n.firstMonthNone;
        } else {
          final amount = formatTaka(
            Taka(first),
            numerals: numerals,
            grouping: grouping,
          );
          text = first == fee
              ? l10n.firstMonthFee(amount)
              : l10n.firstMonthProrated(amount);
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            text,
            key: const Key('first-month-note'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      },
    );
  }

  List<Widget> _fullFields(BuildContext context, AppLocalizations l10n) {
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final defaultDueDay = ref.watch(defaultDueDayProvider).value ?? 10;
    final today = todayFrom(ref.watch(clockProvider));
    final joined = _joinedOn ?? today;

    const gap = SizedBox(height: 16);

    String? phoneError(String? v) =>
        isValidOptionalPhone(v ?? '') ? null : l10n.errorPhoneInvalid;

    // Suggestions in the current language, plus anything already chosen.
    final suggested = [
      for (final s in studentSubjectSuggestions)
        language == AppLanguage.bn ? s.$1 : s.$2,
    ];
    final subjectChips = [
      ...suggested,
      ..._subjects.where((s) => !suggested.contains(s)),
    ];

    return [
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
      TextFormField(
        controller: _school,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: l10n.fieldSchool,
          border: const OutlineInputBorder(),
        ),
      ),
      gap,
      TextFormField(
        controller: _guardianName,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: l10n.fieldGuardianName,
          border: const OutlineInputBorder(),
        ),
      ),
      gap,
      TextFormField(
        controller: _guardianPhone,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        inputFormatters: const [PhoneInputFormatter()],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: l10n.fieldGuardianPhone,
          border: const OutlineInputBorder(),
        ),
        validator: phoneError,
      ),
      gap,
      TextFormField(
        controller: _studentPhone,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        inputFormatters: const [PhoneInputFormatter()],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: l10n.fieldStudentPhone,
          border: const OutlineInputBorder(),
        ),
        validator: phoneError,
      ),
      gap,
      TextFormField(
        controller: _address,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: l10n.fieldAddress,
          border: const OutlineInputBorder(),
        ),
      ),
      gap,
      Text(l10n.fieldSubjects, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final subject in subjectChips)
            FilterChip(
              label: Text(subject),
              selected: _subjects.contains(subject),
              onSelected: (on) => setState(
                () => on ? _subjects.add(subject) : _subjects.remove(subject),
              ),
            ),
        ],
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _otherSubject,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: l10n.fieldOtherSubject,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onSubmitted: (v) {
          final subject = normalizeText(v);
          if (subject.isEmpty) return;
          setState(() => _subjects.add(subject));
          _otherSubject.clear();
        },
      ),
      gap,
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.fieldJoinedOn),
        subtitle: Text(
          formatDate(
            joined,
            language: language,
            numerals: numerals,
            calendar: watchCalendar(ref),
          ),
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(joined.year, joined.month, joined.day),
            firstDate: DateTime(2000),
            lastDate: DateTime(today.year + 1, today.month, today.day),
          );
          if (picked != null) {
            setState(() => _joinedOn = LocalDate.fromDateTime(picked));
          }
        },
      ),
      DropdownButtonFormField<int>(
        initialValue: _dueDay ?? defaultDueDay,
        decoration: InputDecoration(
          labelText: l10n.fieldDueDay,
          border: const OutlineInputBorder(),
        ),
        items: [
          for (var d = 1; d <= 31; d++)
            DropdownMenuItem(value: d, child: Text(formatCount(d, numerals))),
        ],
        onChanged: (v) => setState(() => _dueDay = v),
      ),
      gap,
      Text(l10n.fieldClassDays, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final day in studentWeekOrder)
            FilterChip(
              label: Text(weekdayName(day, language)),
              selected: _classDays.contains(day),
              onSelected: (on) => setState(
                () => on ? _classDays.add(day) : _classDays.remove(day),
              ),
            ),
        ],
      ),
      const SizedBox(height: 8),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.fieldClassTime),
        subtitle: Text(
          _classTime == null
              ? l10n.none
              : applyNumerals(_classTime!.toKey(), numerals),
        ),
        trailing: _classTime == null
            ? const Icon(Icons.access_time)
            : IconButton(
                tooltip: l10n.actionClear,
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _classTime = null),
              ),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
              hour: _classTime?.hour ?? 17,
              minute: _classTime?.minute ?? 0,
            ),
          );
          if (picked != null) {
            setState(() => _classTime = ClockTime(picked.hour, picked.minute));
          }
        },
      ),
      gap,
      TextFormField(
        controller: _notes,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: l10n.fieldNotes,
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 16),
    ];
  }
}
