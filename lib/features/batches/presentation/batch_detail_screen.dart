import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/i18n/digits.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/money/taka.dart';
import 'package:tution_tracker/core/ui/input_formatters.dart';
import 'package:tution_tracker/features/batches/data/batch_providers.dart';
import 'package:tution_tracker/features/batches/data/batch_repository.dart';
import 'package:tution_tracker/features/batches/presentation/batch_list_view.dart';
import 'package:tution_tracker/features/students/presentation/student_avatar.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

class BatchDetailScreen extends ConsumerWidget {
  const BatchDetailScreen({required this.batchId, super.key});

  final String batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final batch = ref.watch(batchStreamProvider(batchId));
    return batch.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('$e')),
      ),
      data: (b) => b == null
          ? Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(l10n.studentsNoMatch)),
            )
          : _BatchView(batch: b),
    );
  }
}

enum _BatchMenu { archive, restore }

class _BatchView extends ConsumerWidget {
  const _BatchView({required this.batch});

  final Batch batch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = ref.watch(appLanguageProvider);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final grouping =
        ref.watch(groupingStyleProvider).value ?? GroupingStyle.lakh;
    final members = ref.watch(batchMembersProvider(batch.id));

    String money(int amount) =>
        formatTaka(Taka(amount), numerals: numerals, grouping: grouping);

    final subtitle = [?batch.subject, ?batch.classLevel].join(' · ');

    return Scaffold(
      appBar: AppBar(
        title: Text(batch.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: l10n.actionEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/batches/${batch.id}/edit'),
          ),
          PopupMenuButton<_BatchMenu>(
            onSelected: (a) async {
              final messenger = ScaffoldMessenger.of(context);
              final repo = await ref.read(batchRepositoryProvider.future);
              if (a == _BatchMenu.archive) {
                await repo.archive(batch.id);
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.batchArchived)),
                );
              } else {
                await repo.restore(batch.id);
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.batchRestored)),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: batch.isArchived
                    ? _BatchMenu.restore
                    : _BatchMenu.archive,
                child: Text(
                  batch.isArchived ? l10n.actionRestore : l10n.actionArchive,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: batch.isArchived
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddMembers(context, batch.id),
              icon: const Icon(Icons.person_add),
              label: Text(l10n.batchAddMembers),
            ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: theme.textTheme.titleMedium),
                Text(
                  batchScheduleText(
                    batch,
                    language: language,
                    numerals: numerals,
                  ),
                ),
                Text('${l10n.batchDefaultFee}: ${money(batch.defaultFee)}'),
                if (batch.isArchived)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Chip(
                      label: Text(l10n.statusArchived),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          members.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    '${l10n.batchMembersTitle} · ${formatCount(list.length, numerals)}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.batchNoMembers),
                  ),
                for (final m in list)
                  ListTile(
                    leading: StudentAvatar(
                      name: m.student.name,
                      photoPath: m.student.photoPath,
                    ),
                    title: Text(
                      m.student.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      [
                        l10n.batchMemberFee(money(m.effectiveFee(batch))),
                        if (m.member.feeOverride != null)
                          l10n.batchMemberCustomFee,
                      ].join(' · '),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) => v == 'fee'
                          ? _editFee(context, ref, batch, m)
                          : _remove(context, ref, m),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'fee',
                          child: Text(l10n.batchSetCustomFee),
                        ),
                        PopupMenuItem(
                          value: 'remove',
                          child: Text(l10n.batchRemoveMember),
                        ),
                      ],
                    ),
                    onTap: () => context.push('/students/${m.student.id}'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    BatchMemberView m,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final today = todayFrom(ref.read(clockProvider));
    final repo = await ref.read(batchRepositoryProvider.future);
    await repo.removeMember(batch.id, m.student.id, today);
    messenger.showSnackBar(SnackBar(content: Text(l10n.batchMemberRemoved)));
  }

  Future<void> _editFee(
    BuildContext context,
    WidgetRef ref,
    Batch batch,
    BatchMemberView m,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _CustomFeeDialog(
        studentName: m.student.name,
        current: m.member.feeOverride,
      ),
    );
    if (result == null) return; // cancelled
    final fee = result.isEmpty ? null : int.parse(toWesternDigits(result));
    final repo = await ref.read(batchRepositoryProvider.future);
    await repo.setFeeOverride(batch.id, m.student.id, fee);
  }

  Future<void> _showAddMembers(BuildContext context, String batchId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (context, controller) =>
            _AddMembersSheet(batchId: batchId, scrollController: controller),
      ),
    );
  }
}

class _AddMembersSheet extends ConsumerStatefulWidget {
  const _AddMembersSheet({
    required this.batchId,
    required this.scrollController,
  });

  final String batchId;
  final ScrollController scrollController;

  @override
  ConsumerState<_AddMembersSheet> createState() => _AddMembersSheetState();
}

class _AddMembersSheetState extends ConsumerState<_AddMembersSheet> {
  String _query = '';
  final Set<String> _selected = {};

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final today = todayFrom(ref.read(clockProvider));
    final repo = await ref.read(batchRepositoryProvider.future);
    await repo.addMembers(widget.batchId, _selected.toList(), today);
    messenger.showSnackBar(SnackBar(content: Text(l10n.batchMembersAdded)));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final addable = ref.watch(
      addableStudentsProvider((batchId: widget.batchId, query: _query)),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.studentsSearchHint,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: addable.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) => list.isEmpty
                ? Center(child: Text(l10n.batchNoAddable))
                : ListView.builder(
                    controller: widget.scrollController,
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final s = list[i];
                      return CheckboxListTile(
                        secondary: StudentAvatar(
                          name: s.name,
                          photoPath: s.photoPath,
                        ),
                        title: Text(s.name),
                        value: _selected.contains(s.id),
                        onChanged: (on) => setState(
                          () => on == true
                              ? _selected.add(s.id)
                              : _selected.remove(s.id),
                        ),
                      );
                    },
                  ),
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selected.isEmpty ? null : _add,
              child: Text(
                l10n.batchAddSelected(formatCount(_selected.length, numerals)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Asks for a student's own fee. Owns its controller so it is disposed only
/// after the dialog has fully left the screen.
class _CustomFeeDialog extends StatefulWidget {
  const _CustomFeeDialog({required this.studentName, required this.current});

  final String studentName;
  final int? current;

  @override
  State<_CustomFeeDialog> createState() => _CustomFeeDialogState();
}

class _CustomFeeDialogState extends State<_CustomFeeDialog> {
  late final _controller = TextEditingController(
    text: widget.current?.toString() ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.studentName),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          const DigitsOnlyFormatter(),
          LengthLimitingTextInputFormatter(7),
        ],
        decoration: InputDecoration(
          labelText: l10n.batchCustomFeeLabel,
          helperText: l10n.batchCustomFeeHint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
