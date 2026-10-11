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
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/input_formatters.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
import 'package:tution_tracker/core/ui/time_chips.dart';
import 'package:tution_tracker/core/utils/phone.dart';
import 'package:tution_tracker/features/batches/data/batch_providers.dart';
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

  /// Batches the student is in. Null until the current ones have loaded
  /// (editing), so saving never removes memberships it has not seen.
  Set<String>? _batchIds;
  Set<String> _initialBatchIds = const {};

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
    _loadBatches(s.id);
  }

  Future<void> _loadBatches(String studentId) async {
    final batches = await ref.read(batchesOfStudentProvider(studentId).future);
    if (!mounted) return;
    setState(() {
      _initialBatchIds = {for (final b in batches) b.id};
      _batchIds = {..._initialBatchIds};
    });
  }

  /// Joins and leaves batches to match the chips (design: batch chips on the
  /// student form).
  Future<void> _saveBatches(Student saved) async {
    final chosen = _batchIds;
    if (chosen == null) return;
    final today = todayFrom(ref.read(clockProvider));
    final repo = await ref.read(batchRepositoryProvider.future);
    for (final id in chosen.difference(_initialBatchIds)) {
      await repo.addMembers(id, [saved.id], today);
    }
    for (final id in _initialBatchIds.difference(chosen)) {
      await repo.removeMember(id, saved.id, today);
    }
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
      await _saveBatches(saved);
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
    return BlockPhoto(
      avatar: StudentAvatar(
        name: _name.text.trim().isEmpty ? '+' : _name.text.trim(),
        photoPath: _removePhoto ? null : _photoPath,
        previewBytes: _newPhoto,
        radius: 44,
      ),
      label: hasPhoto ? l10n.photoChange : l10n.photoAdd,
      onTap: _photoMenu,
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
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: _saving ? null : _save,
          child: Text(l10n.actionSave),
        ),
      ),
      body: Form(
        key: _formKey,
        // A plain scroll view, not a lazy list: the form is short and every
        // field must exist so validation reaches fields that are off-screen.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_full) ...[_photoPicker(l10n), const SizedBox(height: 8)],
              if (!_full && !_editing) ...[
                Text(
                  l10n.studentQuickHint,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: Organic.of(context).subtle),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _name,
                autofocus: !_editing,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: '${l10n.fieldName} *'),
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
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l10n.errorFeeRequired : null,
              ),
              if (!_editing) _firstMonthNote(l10n),
              const SizedBox(height: 8),
              if (!_editing)
                BlockButton(
                  _full ? l10n.fewerDetails : l10n.moreDetails,
                  kind: BlockButtonKind.outlined,
                  icon: _full
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  onPressed: () => setState(() => _full = !_full),
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
    final dueDay = _dueDay ?? defaultDueDay;
    final today = todayFrom(ref.watch(clockProvider));
    final joined = _joinedOn ?? today;
    final batches = ref.watch(batchOptionsProvider).value ?? const [];

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
      BlockSubheading(l10n.fieldClassLevel),
      const SizedBox(height: 8),
      BlockChips<String>(
        options: [for (final level in studentClassLevels) (level, level)],
        isSelected: (v) => v == _classLevel,
        // Tapping the chosen class again clears it.
        onTap: (v) => setState(() => _classLevel = v == _classLevel ? null : v),
      ),
      gap,
      TextFormField(
        controller: _guardianName,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: l10n.fieldGuardianName),
      ),
      gap,
      TextFormField(
        controller: _guardianPhone,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        inputFormatters: const [PhoneInputFormatter()],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(labelText: l10n.fieldGuardianPhone),
        validator: phoneError,
      ),
      gap,
      TextFormField(
        controller: _studentPhone,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        inputFormatters: const [PhoneInputFormatter()],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(labelText: l10n.fieldStudentPhone),
        validator: phoneError,
      ),
      gap,
      TextFormField(
        controller: _school,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: l10n.fieldSchool),
      ),
      gap,
      TextFormField(
        controller: _address,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: l10n.fieldAddress),
      ),
      gap,
      BlockStepper(
        label: l10n.fieldDueDay,
        value: formatCount(dueDay, numerals),
        minusTooltip: l10n.dueDayEarlier,
        plusTooltip: l10n.dueDayLater,
        onMinus: dueDay <= 1
            ? null
            : () => setState(() => _dueDay = dueDay - 1),
        onPlus: dueDay >= 31
            ? null
            : () => setState(() => _dueDay = dueDay + 1),
      ),
      gap,
      BlockSubheading(l10n.fieldSubjects),
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
        trailing: const Icon(Icons.calendar_today_rounded),
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
      gap,
      BlockSubheading(l10n.fieldClassDays),
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
      gap,
      BlockSubheading(l10n.fieldClassTime),
      const SizedBox(height: 8),
      ClassTimeChips(
        value: _classTime,
        language: language,
        numerals: numerals,
        onChanged: (t) => setState(() => _classTime = t),
      ),
      if (batches.isNotEmpty) ...[
        gap,
        BlockSubheading(l10n.tabBatches),
        const SizedBox(height: 8),
        BlockChips<String>(
          multi: true,
          options: [for (final b in batches) (b.id, b.name)],
          isSelected: (id) => (_batchIds ?? const {}).contains(id),
          onTap: (id) => setState(() {
            final set = _batchIds ??= {};
            set.contains(id) ? set.remove(id) : set.add(id);
          }),
        ),
      ],
      gap,
      TextFormField(
        controller: _notes,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: l10n.fieldNotes,
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 16),
    ];
  }
}
