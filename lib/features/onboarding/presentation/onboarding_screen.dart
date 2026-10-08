import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/features/onboarding/data/onboarding_providers.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

/// First launch: pick a language, glance at three intro screens (skippable),
/// and optionally load sample data (spec ON-1, ON-4, ON-5). No sign-up and no
/// permission prompts (ON-3).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  /// 0 language, 1 to 3 intro, 4 sample data.
  int _step = 0;
  bool _busy = false;

  Future<void> _finish({required bool withSample}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (withSample) {
        final service = await ref.read(sampleDataServiceProvider.future);
        await service.load(ref.read(appLanguageProvider));
      }
    } finally {
      await writeSetting(ref, SettingKeys.onboardingDone, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    final (icon, title, body) = switch (_step) {
      1 => (Icons.groups_outlined, l10n.obIntro1Title, l10n.obIntro1Body),
      2 => (Icons.fact_check_outlined, l10n.obIntro2Title, l10n.obIntro2Body),
      3 => (Icons.payments_outlined, l10n.obIntro3Title, l10n.obIntro3Body),
      4 => (Icons.auto_awesome_outlined, l10n.obSampleTitle, l10n.obSampleBody),
      _ => (Icons.school_outlined, l10n.obWelcome, l10n.obPrivacy),
    };

    return Scaffold(
      body: SafeArea(
        // Scrolls when the text is large and the screen small, so nothing is
        // ever cut off; otherwise it fills the screen.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: _step >= 1 && _step <= 3
                          ? TextButton(
                              onPressed: () => setState(() => _step = 4),
                              child: Text(l10n.obSkip),
                            )
                          : const SizedBox(height: 48),
                    ),
                    const Spacer(),
                    Icon(icon, size: 88, color: theme.colorScheme.primary),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      body,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    if (_step == 0) ...[
                      const SizedBox(height: 32),
                      Text(
                        l10n.obPickLanguage,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<Locale>(
                        segments: const [
                          ButtonSegment(
                            value: Locale('bn'),
                            label: Text('বাংলা'),
                          ),
                          ButtonSegment(
                            value: Locale('en'),
                            label: Text('English'),
                          ),
                        ],
                        selected: {locale},
                        onSelectionChanged: (s) => ref
                            .read(localeProvider.notifier)
                            .setLocale(s.first),
                      ),
                    ],
                    const Spacer(),
                    if (_step < 4) ...[
                      _Dots(current: _step, count: 5),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => setState(() => _step++),
                        child: Text(l10n.obNext),
                      ),
                    ] else if (_busy)
                      Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 8),
                          Text(l10n.obLoading),
                        ],
                      )
                    else ...[
                      FilledButton(
                        onPressed: () => _finish(withSample: true),
                        child: Text(l10n.obSampleYes),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => _finish(withSample: false),
                        child: Text(l10n.obSampleNo),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.current, required this.count});

  final int current;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == current ? scheme.primary : scheme.outlineVariant,
            ),
          ),
      ],
    );
  }
}
