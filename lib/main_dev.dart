import 'package:flutter/widgets.dart';
import 'package:tution_tracker/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TuitionTrackerApp(flavor: AppFlavor.dev));
}
