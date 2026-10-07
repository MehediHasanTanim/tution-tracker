import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_status.dart';
import 'package:tution_tracker/features/students/presentation/student_avatar.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearAll() {
    _search.clear();
    ref.read(studentFilterProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final students = ref.watch(studentListProvider);
    final filterActive = ref.watch(studentFilterActiveProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navStudents)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/students/new'),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.studentsAdd),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.studentsSearchHint,
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _search,
                  builder: (context, value, _) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: l10n.studentsClearSearch,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _search.clear();
                            ref
                                .read(studentFilterProvider.notifier)
                                .setQuery('');
                          },
                        ),
                ),
              ),
              onChanged: ref.read(studentFilterProvider.notifier).setQuery,
            ),
          ),
          const _FilterBar(),
          Expanded(
            child: students.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) {
                if (list.isEmpty) {
                  return _EmptyState(
                    filtered: filterActive,
                    onClear: _clearAll,
                  );
                }
                return Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Text(
                          l10n.studentsCount(
                            formatCount(list.length, numerals),
                          ),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: list.length,
                        itemBuilder: (context, i) => _StudentTile(
                          student: list[i],
                          numerals: numerals,
                          grouping: grouping,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  /// Popup values cannot be null, so "all" uses this sentinel.
  static const _all = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(studentFilterProvider);
    final notifier = ref.read(studentFilterProvider.notifier);
    final classes = ref.watch(classLevelsProvider).value ?? const <String>[];
    final batches = ref.watch(batchOptionsProvider).value ?? const [];

    final statusLabels = {
      StudentStatus.active: l10n.statusActive,
      StudentStatus.paused: l10n.statusPaused,
      StudentStatus.left: l10n.statusArchived,
    };

    String? batchName;
    for (final b in batches) {
      if (b.id == filter.batchId) batchName = b.name;
    }

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          for (final status in StudentStatus.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(statusLabels[status]!),
                selected: filter.statuses.contains(status),
                onSelected: (_) => notifier.toggleStatus(status),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: PopupMenuButton<String>(
              tooltip: l10n.studentsFilterClass,
              onSelected: (v) => notifier.setClassLevel(v == _all ? null : v),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _all,
                  child: Text(l10n.studentsAllClasses),
                ),
                for (final level in classes)
                  PopupMenuItem(value: level, child: Text(level)),
              ],
              child: Chip(
                avatar: const Icon(Icons.school_outlined, size: 18),
                label: Text(filter.classLevel ?? l10n.studentsFilterClass),
                backgroundColor: filter.classLevel == null
                    ? null
                    : Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: PopupMenuButton<String>(
              tooltip: l10n.studentsFilterBatch,
              onSelected: (v) => notifier.setBatch(v == _all ? null : v),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _all,
                  child: Text(l10n.studentsAllBatches),
                ),
                for (final b in batches)
                  PopupMenuItem(value: b.id, child: Text(b.name)),
              ],
              child: Chip(
                avatar: const Icon(Icons.groups_outlined, size: 18),
                label: Text(batchName ?? l10n.studentsFilterBatch),
                backgroundColor: filter.batchId == null
                    ? null
                    : Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({
    required this.student,
    required this.numerals,
    required this.grouping,
  });

  final Student student;
  final NumeralStyle numerals;
  final GroupingStyle grouping;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = student.statusValue;
    final fee = l10n.studentFeePerMonth(
      formatTaka(
        Taka(student.monthlyFee),
        numerals: numerals,
        grouping: grouping,
      ),
    );
    final classLevel = student.classLevel;
    return ListTile(
      leading: StudentAvatar(name: student.name, photoPath: student.photoPath),
      // Long Bangla names wrap rather than truncate (spec section 7).
      title: Text(student.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(classLevel == null ? fee : '$classLevel · $fee'),
      trailing: status == StudentStatus.active
          ? null
          : Chip(
              label: Text(
                status == StudentStatus.paused
                    ? l10n.statusPaused
                    : l10n.statusArchived,
              ),
              visualDensity: VisualDensity.compact,
            ),
      onTap: () => context.push('/students/${student.id}'),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered, required this.onClear});

  final bool filtered;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filtered ? Icons.search_off : Icons.school_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              filtered ? l10n.studentsNoMatch : l10n.studentsEmptyTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (filtered)
              TextButton(
                onPressed: onClear,
                child: Text(l10n.studentsClearFilters),
              )
            else
              Text(
                l10n.studentsEmptyBody,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
