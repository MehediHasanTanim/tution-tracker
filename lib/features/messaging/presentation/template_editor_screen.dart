import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/clock.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: Organic.of(context).surface,
                  shape: const StadiumBorder(),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    tabs: [
                      Tab(height: 44, text: l10n.languageBangla),
                      Tab(height: 44, text: l10n.languageEnglish),
                    ],
                  ),
                ),
              ),
            ),
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

    final o = Organic.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        BlockStack(
          children: [
            BlockText(l10n.tplIntro),
            TextField(
              controller: _controller,
              enabled: _loaded,
              minLines: 4,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: l10n.tplBodyLabel,
                alignLabelWithHint: true,
              ),
            ),
            BlockSubheading(l10n.tplVariables),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in MessageVariable.values)
                  ActionChip(
                    label: Text(_label(l10n, v)),
                    backgroundColor: o.sageSoft,
                    labelStyle: theme.textTheme.labelLarge?.copyWith(
                      color: o.onSageSoft,
                    ),
                    onPressed: _loaded ? () => _insert(v) : null,
                  ),
              ],
            ),
            BlockSubheading(l10n.tplPreview),
            BlockMessage(
              preview,
              selectable: true,
              textKey: const Key('template-preview'),
            ),
            Row(
              children: [
                Expanded(
                  child: BlockButton(
                    l10n.tplReset,
                    kind: BlockButtonKind.outlined,
                    onPressed: _loaded ? _reset : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BlockButton(
                    l10n.actionSave,
                    onPressed: _loaded ? _save : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
