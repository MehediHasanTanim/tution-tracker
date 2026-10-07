import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/messaging/data/messaging_providers.dart';
import 'package:tution_tracker/features/messaging/domain/message_template.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Edit the guardian fee-reminder text in Bangla and English, with a live
/// preview filled in with sample data (spec 3.9).
class TemplateEditorScreen extends StatelessWidget {
  const TemplateEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${l10n.tplTitle} · ${l10n.tplFeeReminder}'),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.languageBangla),
              Tab(text: l10n.languageEnglish),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EditorTab(language: AppLanguage.bn),
            _EditorTab(language: AppLanguage.en),
          ],
        ),
      ),
    );
  }
}

class _EditorTab extends ConsumerStatefulWidget {
  const _EditorTab({required this.language});

  final AppLanguage language;

  @override
  ConsumerState<_EditorTab> createState() => _EditorTabState();
}

class _EditorTabState extends ConsumerState<_EditorTab>
    with AutomaticKeepAliveClientMixin {
  final _controller = TextEditingController();
  bool _loaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = await ref.read(messageTemplateRepositoryProvider.future);
    _controller.text = await repo.body(
      MessageKind.feeReminder,
      widget.language,
    );
    if (mounted) setState(() => _loaded = true);
  }

  void _insert(MessageVariable variable) {
    final text = _controller.text;
    final sel = _controller.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    _controller.value = TextEditingValue(
      text: text.replaceRange(start, end, variable.token),
      selection: TextSelection.collapsed(offset: start + variable.token.length),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = await ref.read(messageTemplateRepositoryProvider.future);
    try {
      await repo.save(
        MessageKind.feeReminder,
        widget.language,
        _controller.text,
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.tplSaved)));
    } on ArgumentError {
      messenger.showSnackBar(SnackBar(content: Text(l10n.tplEmpty)));
    }
  }

  Future<void> _reset() async {
    final repo = await ref.read(messageTemplateRepositoryProvider.future);
    await repo.reset(MessageKind.feeReminder, widget.language);
    _controller.text = defaultTemplate(
      MessageKind.feeReminder,
      widget.language,
    );
  }

  String _label(AppLocalizations l10n, MessageVariable v) => switch (v) {
    MessageVariable.student => l10n.tplVarStudent,
    MessageVariable.guardian => l10n.tplVarGuardian,
    MessageVariable.month => l10n.tplVarMonth,
    MessageVariable.amount => l10n.tplVarAmount,
    MessageVariable.due => l10n.tplVarDue,
    MessageVariable.months => l10n.tplVarMonths,
    MessageVariable.tutor => l10n.tplVarTutor,
    MessageVariable.institution => l10n.tplVarInstitution,
    MessageVariable.signature => l10n.tplVarSignature,
  };

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(messagePreviewSettingsProvider).value;
    final tutorName = ref.watchSetting(SettingKeys.tutorName);
    final thisMonth = YearMonth.from(todayFrom(ref.watch(clockProvider)));

    // Sample data in the language of the tab, so the preview reads as the
    // guardian will see it.
    final preview = settings == null
        ? ''
        : renderTemplate(
            _controller.text,
            facts: FeeReminderFacts(
              studentName: l10n.tplSampleStudent,
              balance: 1500,
              oldestMonth: thisMonth,
              oldestDueDate: thisMonth.dayClamped(10),
            ),
            tutor: TutorSignature(
              name: tutorName.isEmpty ? l10n.tplVarTutor : tutorName,
            ),
            language: widget.language,
            numerals: settings.numerals,
            grouping: settings.grouping,
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            enabled: _loaded,
            minLines: 4,
            maxLines: 10,
            decoration: InputDecoration(
              labelText: l10n.tplBodyLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.tplVariables, style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final v in MessageVariable.values)
                ActionChip(
                  label: Text(_label(l10n, v)),
                  onPressed: _loaded ? () => _insert(v) : null,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.tplPreview, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                preview,
                key: const Key('template-preview'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loaded ? _reset : null,
                  child: Text(l10n.tplReset),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _loaded ? _save : null,
                  child: Text(l10n.actionSave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
