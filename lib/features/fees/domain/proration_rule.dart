/// How the joining month's fee is charged (design section 7.2).
enum ProrationRule {
  /// Charge the full monthly fee. The default.
  fullMonth,

  /// `round(base * remainingDays / daysInMonth)`, counting the joining day.
  byDays,

  /// No due for the joining month; billing starts the next month.
  nextMonth,
}
