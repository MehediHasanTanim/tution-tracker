import 'package:tution_tracker/core/dates/clock_time.dart';
import 'package:tution_tracker/core/i18n/text_normalizer.dart';

enum BatchFieldError {
  nameRequired,
  scheduleRequired,
  feeInvalid,
  durationInvalid,
}

/// The editable fields of a batch, before they are saved.
class BatchDraft {
  const BatchDraft({
    required this.name,
    required this.scheduleDays,
    this.subject,
    this.classLevel,
    this.startTime,
    this.durationMin,
    this.defaultFee = 0,
  });

  final String name;

  /// ISO weekdays (1 = Monday .. 7 = Sunday). At least one is required, or
  /// the batch would never appear on the Today screen.
  final List<int> scheduleDays;
  final String? subject;
  final String? classLevel;
  final ClockTime? startTime;
  final int? durationMin;
  final int defaultFee;

  List<BatchFieldError> validate() => [
    if (normalizeText(name).isEmpty) BatchFieldError.nameRequired,
    if (scheduleDays.where((d) => d >= 1 && d <= 7).isEmpty)
      BatchFieldError.scheduleRequired,
    if (defaultFee < 0) BatchFieldError.feeInvalid,
    if (durationMin != null && durationMin! < 1)
      BatchFieldError.durationInvalid,
  ];
}

class BatchValidationException implements Exception {
  const BatchValidationException(this.errors);

  final List<BatchFieldError> errors;

  @override
  String toString() => 'BatchValidationException($errors)';
}
