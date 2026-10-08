enum StudentStatus {
  active,
  paused,

  /// Also how "archived" is represented: the student stays in the database
  /// with full history but is hidden from the default list (spec ST-6).
  left,
}
