import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [appFlavorProvider.overrideWithValue(AppFlavor.prod)],
      child: const TuitionTrackerApp(flavor: AppFlavor.prod),
    ),
  );
}
