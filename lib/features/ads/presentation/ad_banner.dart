import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/navigation/app_gate.dart';
import 'package:tution_tracker/features/ads/data/ad_providers.dart';
import 'package:tution_tracker/features/ads/data/ad_service.dart';
import 'package:tution_tracker/features/ads/domain/ad_policy.dart';

/// The banner under every browsing screen. It takes no room until an ad has
/// loaded, so offline, with ads off, or on a screen where ads are not allowed
/// the layout is exactly what it was without ads.
class AdBannerSlot extends ConsumerStatefulWidget {
  const AdBannerSlot({required this.location, super.key});

  /// The current route, e.g. `/students/abc`.
  final String location;

  @override
  ConsumerState<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends ConsumerState<AdBannerSlot> {
  static const _refresh = Duration(seconds: 60);
  static const _retrySteps = [30, 60, 120, 300];

  AdBannerHandle? _handle;
  Timer? _timer;
  bool _loading = false;
  int _failures = 0;
  int _width = 0;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _handle?.dispose();
    super.dispose();
  }

  void _hide() {
    _timer?.cancel();
    _timer = null;
    final old = _handle;
    if (old == null) return;
    _handle = null;
    // Leave the old ad in the tree for this frame, then drop it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      old.dispose();
      if (mounted) setState(() {});
    });
  }

  Future<void> _load() async {
    if (_loading || _disposed || _width <= 0) return;
    _loading = true;
    final service = ref.read(adServiceProvider);
    final next = await service.loadBanner(_width);
    _loading = false;
    if (_disposed) {
      next?.dispose();
      return;
    }
    final stillWanted = _wanted();
    if (!stillWanted) {
      next?.dispose();
      return;
    }
    final old = _handle;
    setState(() => _handle = next ?? old);
    if (next != null) {
      _failures = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => old?.dispose());
      _schedule(_refresh);
    } else {
      final step = _retrySteps[_failures.clamp(0, _retrySteps.length - 1)];
      _failures++;
      _schedule(Duration(seconds: step));
    }
  }

  void _schedule(Duration after) {
    _timer?.cancel();
    _timer = Timer(after, () {
      if (!_disposed && _wanted()) _load();
    });
  }

  bool _wanted() =>
      (ref.read(adsReadyProvider).value ?? false) &&
      AdPolicy.bannerAllowedOn(widget.location) &&
      !isAppCovered(ref);

  @override
  Widget build(BuildContext context) {
    final ready = ref.watch(adsReadyProvider).value ?? false;
    final allowed = AdPolicy.bannerAllowedOn(widget.location);
    final covered = isAppCovered(ref);
    final visible = ready && allowed && !covered;

    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.floor()
            : 0;
        if (!visible) {
          _hide();
          return const SizedBox.shrink();
        }
        if (_handle == null && !_loading && _timer == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _wanted()) _load();
          });
        }
        final handle = _handle;
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: handle == null
              ? const SizedBox(width: double.infinity)
              : Align(
                  heightFactor: 1,
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    width: double.infinity,
                    height: handle.height,
                    alignment: Alignment.center,
                    child: handle.widget,
                  ),
                ),
        );
      },
    );
  }
}
