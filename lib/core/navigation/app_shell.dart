import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tution_tracker/core/theme/organic_tokens.dart';
import 'package:tution_tracker/features/ads/presentation/ad_banner.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.shell, this.location = '', super.key});

  final StatefulNavigationShell shell;

  /// The current route, which decides whether a banner may show.
  final String location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      // The handoff's tab bar: a raised strip with a hairline on top and a
      // pill behind the active icon.
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdBannerSlot(location: location),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Organic.of(context).divider),
              ),
            ),
            child: NavigationBar(
              selectedIndex: shell.currentIndex,
              // Tapping the active tab returns to that tab's root.
              onDestinationSelected: (i) =>
                  shell.goBranch(i, initialLocation: i == shell.currentIndex),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: l10n.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.groups_outlined),
                  selectedIcon: const Icon(Icons.groups_rounded),
                  label: l10n.navStudents,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.layers_outlined),
                  selectedIcon: const Icon(Icons.layers_rounded),
                  label: l10n.navBatches,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: const Icon(
                    Icons.account_balance_wallet_rounded,
                  ),
                  label: l10n.navFees,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.bar_chart_outlined),
                  selectedIcon: const Icon(Icons.bar_chart_rounded),
                  label: l10n.navReports,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.tune_outlined),
                  selectedIcon: const Icon(Icons.tune_rounded),
                  label: l10n.navSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
