import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tution_tracker/core/dates/local_date.dart';

/// The current time, overridable in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Today's date on the device calendar.
LocalDate todayFrom(DateTime Function() clock) =>
    LocalDate.fromDateTime(clock());
