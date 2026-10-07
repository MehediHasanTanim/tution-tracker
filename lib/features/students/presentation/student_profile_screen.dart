import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/platform/url_launcher_service.dart';
import 'package:tution_tracker/core/utils/contact_links.dart';
import 'package:tution_tracker/core/utils/phone.dart';
import 'package:tution_tracker/features/batches/data/batch_providers.dart';
import 'package:tution_tracker/features/students/data/photo_store.dart';
import 'package:tution_tracker/features/students/data/student_form_providers.dart';
import 'package:tution_tracker/features/students/data/student_providers.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_status.dart';
import 'package:tution_tracker/features/students/presentation/student_avatar.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({required this.studentId, super.key});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final student = ref.watch(studentStreamProvider(studentId));

    return student.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('$e')),
      ),
      data: (s) {
        if (s == null) {
          // Deleted (possibly from this very screen).
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.studentsNoMatch)),
          );
        }
        return _ProfileView(student: s);
      },
    );
  }
}

class _ProfileView extends ConsumerWidget {
  const _ProfileView({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final archived = student.statusValue == StudentStatus.left;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            student.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              tooltip: l10n.actionEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/students/${student.id}/edit'),
            ),
            PopupMenuButton<_MenuAction>(
              onSelected: (a) => _onMenu(context, ref, a),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: archived ? _MenuAction.restore : _MenuAction.archive,
                  child: Text(
                    archived ? l10n.actionRestore : l10n.actionArchive,
                  ),
                ),
                PopupMenuItem(
                  value: _MenuAction.delete,
                  child: Text(l10n.actionDelete),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: l10n.tabOverview),
              Tab(text: l10n.tabAttendance),
              Tab(text: l10n.tabFees),
              Tab(text: l10n.tabNotes),
            ],
          ),
        ),
        body: Column(
          children: [
            _Header(student: student),
            Expanded(
              child: TabBarView(
                children: [
                  _OverviewTab(student: student),
                  _Soon(label: l10n.comingSoon),
                  _Soon(label: l10n.comingSoon),
                  _NotesTab(student: student),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    _MenuAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final repo = await ref.read(studentRepositoryProvider.future);

    switch (action) {
      case _MenuAction.archive:
        await repo.archive(student.id);
        messenger.showSnackBar(SnackBar(content: Text(l10n.studentArchived)));
      case _MenuAction.restore:
        await repo.restore(student.id);
        messenger.showSnackBar(SnackBar(content: Text(l10n.studentRestored)));
      case _MenuAction.delete:
        if (!context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteStudentTitle),
            content: Text(l10n.deleteStudentBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.actionDelete),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        final photoPath = await repo.deleteForever(student.id);
        final photos = await ref.read(photoStoreProvider.future);
        await photos.delete(photoPath);
        messenger.showSnackBar(SnackBar(content: Text(l10n.studentDeleted)));
        if (router.canPop()) router.pop();
    }
  }
}

enum _MenuAction { archive, restore, delete }

class _Header extends ConsumerWidget {
  const _Header({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = student.statusValue;
    final subtitle = [?student.classLevel, ?student.school].join(' · ');

    // Call the guardian first (spec ST-5); fall back to the student's own.
    final phone =
        parseBdPhone(student.guardianPhone ?? '') ??
        parseBdPhone(student.studentPhone ?? '');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StudentAvatar(
                name: student.name,
                photoPath: student.photoPath,
                radius: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: theme.textTheme.titleLarge),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, style: theme.textTheme.bodyMedium),
                    if (status != StudentStatus.active)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Chip(
                          label: Text(
                            status == StudentStatus.paused
                                ? l10n.statusPaused
                                : l10n.statusArchived,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ContactButtons(phone: phone),
        ],
      ),
    );
  }
}

class _ContactButtons extends ConsumerWidget {
  const _ContactButtons({required this.phone});

  final BdPhone? phone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final p = phone;

    Future<void> open(Uri uri) async {
      final messenger = ScaffoldMessenger.of(context);
      final ok = await ref.read(urlLauncherProvider).open(uri);
      if (!ok) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.contactLaunchFailed)),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p == null ? l10n.noPhoneNumber : applyNumerals(p.local, numerals),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: p == null ? null : () => open(ContactLinks.call(p)),
                icon: const Icon(Icons.call),
                label: Text(l10n.actionCall),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: p == null ? null : () => open(ContactLinks.sms(p)),
                icon: const Icon(Icons.sms),
                label: Text(l10n.actionSms),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: p == null
                    ? null
                    : () => open(ContactLinks.whatsapp(p)),
                icon: const Icon(Icons.chat),
                label: Text(l10n.actionWhatsapp),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;

    final days = [
      for (final d in student.classDayList) weekdayName(d, language),
    ];
    final time = student.classTimeValue;
    final batches =
        ref.watch(batchesOfStudentProvider(student.id)).value ?? const [];

    final rows = <(String, String)>[
      (
        l10n.profileMonthlyFee,
        formatTaka(
          Taka(student.monthlyFee),
          numerals: numerals,
          grouping: grouping,
        ),
      ),
      (l10n.profileDueDay, formatCount(student.feeDueDay, numerals)),
      (
        l10n.fieldJoinedOn,
        formatDate(
          LocalDate.parse(student.joinedOn),
          language: language,
          numerals: numerals,
        ),
      ),
      if (student.guardianName != null)
        (l10n.fieldGuardianName, student.guardianName!),
      if (student.guardianPhone != null)
        (
          l10n.fieldGuardianPhone,
          applyNumerals(student.guardianPhone!, numerals),
        ),
      if (student.studentPhone != null)
        (
          l10n.fieldStudentPhone,
          applyNumerals(student.studentPhone!, numerals),
        ),
      if (batches.isNotEmpty)
        (l10n.profileBatches, batches.map((b) => b.name).join(', ')),
      if (student.address != null) (l10n.fieldAddress, student.address!),
      if (student.subjectList.isNotEmpty)
        (l10n.fieldSubjects, student.subjectList.join(', ')),
      if (days.isNotEmpty) (l10n.fieldClassDays, days.join(', ')),
      if (time != null)
        (l10n.fieldClassTime, applyNumerals(time.toKey(), numerals)),
    ];

    // A short fixed list, so a plain scroll view rather than a lazy one.
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final (label, value) in rows)
            ListTile(
              dense: true,
              title: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              subtitle: Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
        ],
      ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final notes = student.notes;
    if (notes == null) return _Soon(label: AppLocalizations.of(context).none);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(notes),
    );
  }
}

class _Soon extends StatelessWidget {
  const _Soon({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(label, style: Theme.of(context).textTheme.bodyLarge));
}
