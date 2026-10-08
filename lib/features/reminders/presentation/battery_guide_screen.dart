import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/platform/battery_guide_service.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
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
    final theme = Theme.of(context);
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
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.oemIntro, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in PhoneMaker.values)
                      ChoiceChip(
                        label: Text(name(m)),
                        selected: m == maker,
                        onSelected: (_) => setState(() => _chosen = m),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.oemDetected(name(maker)),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final (i, step) in steps(maker).split('\n').indexed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
                    title: Text(step),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.battery_saver),
                  onPressed: () => ref
                      .read(batteryGuideServiceProvider)
                      .openBatterySettings(maker),
                  label: Text(l10n.oemOpenBattery),
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: _done, child: Text(l10n.oemDone)),
              ],
            ),
    );
  }
}
