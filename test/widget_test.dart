import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/app.dart';

void main() {
  testWidgets('app boots and shows the title', (tester) async {
    await tester.pumpWidget(const TuitionTrackerApp(flavor: AppFlavor.dev));
    expect(find.text('Tuition Khata'), findsOneWidget);
  });
}
