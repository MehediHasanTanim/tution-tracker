import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/features/backup/data/backup_status_provider.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Asks the tutor to back up when it has been too long (spec 3.10). Shows
/// nothing when the last backup is recent or there is no data yet.
class BackupBanner extends ConsumerWidget {
  const BackupBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(backupStatusProvider);
    if (!status.show) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final days = status.daysAgo;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        color: Organic.of(context).accentSoft,
        child: ListTile(
          iconColor: Organic.of(context).onAccentSoft,
          textColor: Organic.of(context).onAccentSoft,
          leading: const Icon(Icons.backup_rounded),
          title: Text(
            days == null
                ? l10n.bkBannerNever
                : l10n.bkBannerOld(formatCount(days, numerals)),
          ),
          trailing: TextButton(
            onPressed: () => context.push('/settings/backup'),
            child: Text(l10n.bkBannerAction),
          ),
        ),
      ),
    );
  }
}
