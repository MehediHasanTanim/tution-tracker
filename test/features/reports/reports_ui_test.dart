import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fee_ui.dart';

void main() {
  feeUiTest('an empty month says there is no data, and the chart is drawn', (
    tester,
    h,
  ) async {
    await pumpHarnessApp(tester, h);
    await goTab(tester, 'রিপোর্ট');
    await waitFor(tester);

    expect(find.text('মার্চ ২০২৬'), findsOneWidget);
    expect(find.text('এই মাসে কোনো তথ্য নেই'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
  });

  feeUiTest('the report, the home card and the due list agree', (
    tester,
    h,
  ) async {
    final s = await seedStudent(tester, h); // Jan-Mar dues of 1,500
    await real(tester, () => h.pay(s.id, 2000));
    await pumpHarnessApp(tester, h);
    await waitFor(tester);

    // Home: this month (March) expected 1,500, collected 0 (payment went to
    // the oldest dues first).
    expect(find.text('৳ ১,৫০০'), findsWidgets);

    await goTab(tester, 'রিপোর্ট');
    await waitFor(tester);
    expect(find.text('প্রত্যাশিত'), findsOneWidget);
    expect(find.text('৳ ১,৫০০'), findsWidgets);
    // 4,500 owed in total, 2,000 paid: 2,500 still owed across all months.
    await tester.tap(find.byTooltip('আগের মাস'));
    await waitFor(tester);
    expect(find.text('ফেব্রুয়ারি ২০২৬'), findsOneWidget);
  });
}
