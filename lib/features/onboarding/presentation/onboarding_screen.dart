import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/i18n/locale_provider.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/core/settings/settings_provider.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/core/ui/organic_blocks.dart';
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
      1 => (Icons.groups_rounded, l10n.obIntro1Title, l10n.obIntro1Body),
      2 => (Icons.fact_check_rounded, l10n.obIntro2Title, l10n.obIntro2Body),
      3 => (
        Icons.account_balance_wallet_rounded,
        l10n.obIntro3Title,
        l10n.obIntro3Body,
      ),
      4 => (Icons.auto_awesome_rounded, l10n.obSampleTitle, l10n.obSampleBody),
      _ => (Icons.language_rounded, l10n.obWelcome, l10n.obPrivacy),
    };
    final bn = locale.languageCode == 'bn';

    return Scaffold(
      body: SafeArea(
        // Scrolls when the text is large and the screen small, so nothing is
        // ever cut off; otherwise it fills the screen.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 40,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    // The design's soft circles, alternating sage and
                    // terracotta from step to step.
                    BlockIllustration(icon: icon, sage: _step.isEven),
                    const SizedBox(height: 12),
                    if (_step == 0)
                      Text(
                        l10n.appTitle,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Organic.of(context).accentStrong,
                        ),
                      ),
                    BlockHeading(title),
                    const SizedBox(height: 8),
                    BlockText(body),
                    if (_step == 0) ...[
                      const SizedBox(height: 20),
                      BlockSubheading(l10n.obPickLanguage),
                      const SizedBox(height: 10),
                      BlockButton(
                        'বাংলা',
                        kind: bn
                            ? BlockButtonKind.primary
                            : BlockButtonKind.outlined,
                        onPressed: () => ref
                            .read(localeProvider.notifier)
                            .setLocale(const Locale('bn')),
                      ),
                      const SizedBox(height: 10),
                      BlockButton(
                        'English',
                        kind: bn
                            ? BlockButtonKind.outlined
                            : BlockButtonKind.primary,
                        onPressed: () => ref
                            .read(localeProvider.notifier)
                            .setLocale(const Locale('en')),
                      ),
                    ],
                    const Spacer(),
                    const SizedBox(height: 16),
                    BlockDots(count: 5, current: _step),
                    const SizedBox(height: 12),
                    if (_step < 4) ...[
                      BlockButton(
                        l10n.obNext,
                        onPressed: () => setState(() => _step++),
                      ),
                      if (_step >= 1)
                        BlockButton(
                          l10n.obSkip,
                          kind: BlockButtonKind.ghost,
                          onPressed: () => setState(() => _step = 4),
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
                      BlockButton(
                        l10n.obSampleYes,
                        onPressed: () => _finish(withSample: true),
                      ),
                      const SizedBox(height: 10),
                      BlockButton(
                        l10n.obSampleNo,
                        kind: BlockButtonKind.outlined,
                        onPressed: () => _finish(withSample: false),
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
