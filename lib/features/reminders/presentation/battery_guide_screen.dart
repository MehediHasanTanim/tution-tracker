import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/i18n/number_format.dart';
import 'package:tution_tracker/core/platform/battery_guide_service.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
import 'package:tution_tracker/features/students/presentation/student_list_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// Steps for letting the app run in the background on phones whose battery
/// manager would otherwise stop reminders (design 9.3). Shown once after
/// reminders are first enabled, and reachable later from Settings.
class BatteryGuideScreen extends ConsumerStatefulWidget {
  const BatteryGuideScreen({super.key});

  @override
  ConsumerState<BatteryGuideScreen> createState() => _BatteryGuideScreenState();
}

class _BatteryGuideScreenState extends ConsumerState<BatteryGuideScreen> {
  PhoneMaker? _detected;
  PhoneMaker? _chosen;

  @override
  void initState() {
    super.initState();
    _detect();
  }

  Future<void> _detect() async {
    final maker = await ref.read(batteryGuideServiceProvider).maker();
    if (mounted) setState(() => _detected = maker);
  }

  Future<void> _done() async {
    final router = GoRouter.of(context);
    await writeSetting(ref, SettingKeys.oemGuideShown, true);
    if (router.canPop()) router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final numerals =
        ref.watch(numeralStyleProvider).value ?? NumeralStyle.bangla;
    final maker = _chosen ?? _detected;
    String name(PhoneMaker m) => switch (m) {
      PhoneMaker.xiaomi => l10n.oemMakerXiaomi,
      PhoneMaker.oppo => l10n.oemMakerOppo,
      PhoneMaker.vivo => l10n.oemMakerVivo,
      PhoneMaker.realme => l10n.oemMakerRealme,
      PhoneMaker.samsung => l10n.oemMakerSamsung,
      PhoneMaker.other => l10n.oemMakerOther,
    };
    String steps(PhoneMaker m) => switch (m) {
      PhoneMaker.xiaomi => l10n.oemStepsXiaomi,
      PhoneMaker.oppo => l10n.oemStepsOppo,
      PhoneMaker.vivo => l10n.oemStepsVivo,
      PhoneMaker.realme => l10n.oemStepsRealme,
      PhoneMaker.samsung => l10n.oemStepsSamsung,
      PhoneMaker.other => l10n.oemStepsOther,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.oemTitle)),
      body: maker == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                BlockStack(
                  children: [
                    BlockText(l10n.oemIntro),
                    BlockChips<PhoneMaker>(
                      options: [
                        for (final m in PhoneMaker.values) (m, name(m)),
                      ],
                      isSelected: (m) => m == maker,
                      onTap: (m) => setState(() => _chosen = m),
                    ),
                    BlockSubheading(l10n.oemDetected(name(maker))),
                    for (final (i, step) in steps(maker).split('\n').indexed)
                      BlockStep(
                        number: applyNumerals('${i + 1}', numerals),
                        text: step,
                      ),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: maker == null
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(
                color: Organic.of(context).raised,
                border: Border(
                  top: BorderSide(color: Organic.of(context).divider),
                ),
              ),
              child: SafeArea(
                minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: BlockStack(
                  children: [
                    BlockButton(
                      l10n.oemOpenBattery,
                      icon: Icons.battery_saver_rounded,
                      onPressed: () => ref
                          .read(batteryGuideServiceProvider)
                          .openBatterySettings(maker),
                    ),
                    BlockButton(
                      l10n.oemDone,
                      kind: BlockButtonKind.outlined,
                      onPressed: _done,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
