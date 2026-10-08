import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/database_provider.dart';
import 'package:tution_tracker/core/i18n/date_format.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/platform/url_launcher_service.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/utils/contact_links.dart';
import 'package:tution_tracker/core/utils/phone.dart';
import 'package:tution_tracker/features/fees/data/fee_repository.dart';
import 'package:tution_tracker/features/messaging/data/message_template_repository.dart';
import 'package:tution_tracker/features/messaging/data/reminder_log.dart';
import 'package:tution_tracker/features/messaging/domain/message_template.dart';

final messageTemplateRepositoryProvider =
    FutureProvider<MessageTemplateRepository>((ref) async {
      return MessageTemplateRepository(
        await ref.watch(databaseProvider.future),
      );
    });

final reminderLogProvider = FutureProvider<ReminderLog>((ref) async {
  return ReminderLog(await ref.watch(settingsStoreProvider.future));
});

final reminderLogEntriesProvider = StreamProvider.autoDispose
    .family<Map<String, LocalDate>, int>((ref, _) async* {
      final log = await ref.watch(reminderLogProvider.future);
      yield* log.watch();
    });

/// The facts a fee reminder states about [entry].
FeeReminderFacts factsFor(DueListEntry entry) {
  final oldest = entry.dues.reduce(
    (a, b) => a.dueDate.compareTo(b.dueDate) <= 0 ? a : b,
  );
  return FeeReminderFacts(
    studentName: entry.student.name,
    guardianName: entry.student.guardianName ?? '',
    balance: entry.totalBalance,
    oldestMonth: YearMonth.parse(oldest.month),
    oldestDueDate: entry.oldestDueDate,
    openMonths: entry.openCount,
  );
}

/// Where a message to a student's family goes: the guardian's phone, or the
/// student's own when there is no guardian number.
BdPhone? contactPhone(Student student) =>
    parseBdPhone(student.guardianPhone ?? '') ??
    parseBdPhone(student.studentPhone ?? '');

/// Writes fee reminders in the app's language, from the tutor's template.
class FeeReminderComposer {
  FeeReminderComposer(this._ref);

  final Ref _ref;

  Future<String> compose(FeeReminderFacts facts) async {
    final settings = await _ref.read(settingsStoreProvider.future);
    final language = await settings.get(SettingKeys.language);
    final templates = await _ref.read(messageTemplateRepositoryProvider.future);
    return renderTemplate(
      await templates.body(MessageKind.feeReminder, language),
      facts: facts,
      tutor: TutorSignature(
        name: await settings.get(SettingKeys.tutorName),
        institution: await settings.get(SettingKeys.institutionName),
      ),
      language: language,
      numerals: await settings.get(SettingKeys.numerals),
      grouping: await settings.get(SettingKeys.grouping),
    );
  }
}

final feeReminderComposerProvider = Provider<FeeReminderComposer>(
  FeeReminderComposer.new,
);

enum MessageChannel { sms, whatsapp }

/// Opens the messaging app with [text] filled in. The tutor taps send, so no
/// SMS permission is needed (design 9.4). False when nothing could open.
Future<bool> openMessage(
  UrlLauncherService launcher, {
  required MessageChannel channel,
  required BdPhone phone,
  required String text,
}) {
  final uri = switch (channel) {
    MessageChannel.sms => ContactLinks.sms(phone, body: text),
    MessageChannel.whatsapp => ContactLinks.whatsapp(phone, text: text),
  };
  return launcher.open(uri);
}

/// The language and numeral settings the editor's preview needs.
final messagePreviewSettingsProvider =
    FutureProvider.autoDispose<
      ({NumeralStyle numerals, GroupingStyle grouping, AppLanguage language})
    >((ref) async {
      final settings = await ref.watch(settingsStoreProvider.future);
      return (
        numerals: await settings.get(SettingKeys.numerals),
        grouping: await settings.get(SettingKeys.grouping),
        language: await settings.get(SettingKeys.language),
      );
    });
