import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/dates/year_month.dart';
import 'package:tution_tracker/core/db/app_database.dart';
import 'package:tution_tracker/core/db/connection.dart';
import 'package:tution_tracker/core/settings/settings_store.dart';
import 'package:tution_tracker/features/batches/data/batch_repository.dart';
import 'package:tution_tracker/features/fees/data/due_service.dart';
import 'package:tution_tracker/features/fees/data/fee_repository.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';
import 'package:tution_tracker/features/fees/domain/allocation.dart';
import 'package:tution_tracker/features/students/data/student_repository.dart';
import 'package:tution_tracker/features/students/domain/student_draft.dart';

/// Every fee repository wired together on an in-memory database, with a clock
/// the test controls. Students created through [addStudent] get their dues
/// immediately, as in the app.
class FeeHarness {
  FeeHarness({DateTime? start}) : now = start ?? DateTime(2026, 3, 15, 10) {
    db = openInMemoryDatabase();
    settings = SettingsStore(db);
    payments = PaymentRepository(db, settings, now: () => now);
    dues = DueService(db, settings, payments, now: () => now);
    fees = FeeRepository(db, payments, dues, now: () => now);
    students = StudentRepository(
      db,
      now: () => now,
      onStudentChanged: (id) async {
        await dues.generateForStudent(id);
      },
    );
    batches = BatchRepository(db, now: () => now);
  }

  /// The pretend current time. Move it to simulate days passing.
  DateTime now;

  late final AppDatabase db;
  late final SettingsStore settings;
  late final PaymentRepository payments;
  late final DueService dues;
  late final FeeRepository fees;
  late final StudentRepository students;
  late final BatchRepository batches;

  LocalDate get today => LocalDate.fromDateTime(now);
  YearMonth get thisMonth => YearMonth.from(today);

  Future<void> close() => db.close();

  Future<Student> addStudent({
    String name = 'Rahim',
    int fee = 1500,
    LocalDate? joinedOn,
    int dueDay = 10,
  }) => students.create(
    StudentDraft.quick(
      name: name,
      monthlyFee: fee,
      joinedOn: joinedOn ?? const LocalDate(2026, 1, 1),
      feeDueDay: dueDay,
    ),
  );

  Future<List<FeeBalance>> ledger(String studentId) =>
      fees.watchLedger(studentId).first;

  Future<FeeBalance> dueFor(String studentId, YearMonth month) async =>
      (await ledger(studentId))
          .firstWhere((b) => b.month == month.toKey() && b.kind == 'monthly');

  Future<int> balanceOf(String studentId) async =>
      (await ledger(studentId))
          .where((b) => b.waived == 0)
          .fold<int>(0, (sum, b) => sum + b.balance);

  Future<RecordedPayment> pay(
    String studentId,
    int amount, {
    AllocationTarget target = const OldestFirst(),
    LocalDate? on,
  }) => payments.record(
    PaymentInput(
      studentId: studentId,
      amount: amount,
      receivedOn: on ?? today,
      target: target,
    ),
  );

  /// Moves the clock to the 15th of [month].
  Future<void> advanceTo(YearMonth month) async {
    now = DateTime(month.year, month.month, 15, 10);
    await dues.generateForAll();
  }
}
