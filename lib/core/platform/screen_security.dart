import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Blocks screenshots, screen recording and the recent-apps thumbnail while
/// on (Android `FLAG_SECURE`). Wrapped so tests do not need the channel.
abstract interface class ScreenSecurity {
  Future<void> setProtected({required bool enabled});
}

class ChannelScreenSecurity implements ScreenSecurity {
  const ChannelScreenSecurity();

  static const _channel = MethodChannel(
    'com.nextgenai.tution_tracker/screen_security',
  );

  @override
  Future<void> setProtected({required bool enabled}) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('setSecure', enabled);
    } on Object {
      // Best effort: the app works the same without it.
    }
  }
}

final screenSecurityProvider = Provider<ScreenSecurity>(
  (ref) => const ChannelScreenSecurity(),
);
