import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tution_tracker/core/dates/local_date.dart';
import 'package:tution_tracker/core/platform/share_service.dart';
import 'package:tution_tracker/core/platform/temp_directory.dart';
import 'package:tution_tracker/core/settings/settings_keys.dart';
import 'package:tution_tracker/features/fees/data/payment_repository.dart';

import '../../support/fee_harness.dart';
import '../../support/fee_ui.dart';
import '../../support/test_app.dart';

class FakeShare implements ShareService {
  FakeShare({this.result = true, this.fails = false});

  final bool result;
  final bool fails;
  final files = <({String path, String mime})>[];

  @override
  Future<bool> shareFile(
    String path, {
    required String mimeType,
    String? text,
    String? subject,
  }) async {
    if (fails) throw StateError('no share target');
    files.add((path: path, mime: mimeType));
    return result;
  }

  @override
  Future<bool> shareText(String text, {String? subject}) async => result;
}

late Directory _tmp;

Future<void> _open(
  WidgetTester tester,
  FeeHarness h,
  String route,
  FakeShare share,
) async {
  _tmp = Directory.systemTemp.createTempSync('tk_receipt_');
  addTearDown(() => _tmp.deleteSync(recursive: true));
  await pumpApp(
    tester,
    h.db,
    clock: () => h.now,
    overrides: [
      shareServiceProvider.overrideWithValue(share),
      tempDirectoryProvider.overrideWith((ref) async => _tmp),
    ],
  );
  await pushRoute(tester, route);
}

/// Width in pixels of a PNG, read from its header.
int _pngWidth(Uint8List b) => ByteData.sublistView(b, 16, 20).getUint32(0);

Future<String> _paidReceipt(WidgetTester tester, FeeHarness h) async {
  final s = await seedStudent(tester, h, name: 'রহিম উদ্দিন');
  final p = (await real(tester, () => h.pay(s.id, 3000))).payment;
  return p.id;
}

void main() {
  group('preview', () {
    feeUiTest('shows the receipt: number, date, student, months and total', (
      tester,
      h,
    ) async {
      final id = await _paidReceipt(tester, h);
      await _open(tester, h, '/fees/receipt/$id', FakeShare());
      await tester.pumpAndSettle();

      expect(find.text('রসিদ'), findsWidgets);
      expect(find.text('রসিদ নং ১'), findsOneWidget);
      expect(find.text('১৫ মার্চ ২০২৬'), findsOneWidget);
      expect(find.text('রহিম উদ্দিন'), findsOneWidget);
      expect(find.text('জানুয়ারি ২০২৬'), findsOneWidget);
      expect(find.text('ফেব্রুয়ারি ২০২৬'), findsOneWidget);
      expect(find.text('৳ ১,৫০০'), findsNWidgets(2));
      expect(find.text('মোট জমা'), findsOneWidget);
      expect(find.text('৳ ৩,০০০'), findsOneWidget);
      expect(find.text('ক্যাশ'), findsOneWidget);
      expect(find.text('ধন্যবাদ'), findsOneWidget);
    });

    feeUiTest('uses the tutor and institution names when they are set', (
      tester,
      h,
    ) async {
      final id = await _paidReceipt(tester, h);
      await real(
        tester,
        () => h.settings.set(SettingKeys.institutionName, 'Sunrise Coaching'),
      );
      await real(
        tester,
        () => h.settings.set(SettingKeys.tutorName, 'Karim Sir'),
      );
      await real(
        tester,
        () => h.settings.set(SettingKeys.tutorPhone, '01712345678'),
      );
      await _open(tester, h, '/fees/receipt/$id', FakeShare());
      await waitFor(tester);

      expect(find.text('Sunrise Coaching'), findsOneWidget);
      expect(find.text('Karim Sir'), findsOneWidget);
      expect(find.text('০১৭১২৩৪৫৬৭৮'), findsOneWidget);
    });

    feeUiTest('falls back to the app name without a profile', (
      tester,
      h,
    ) async {
      final id = await _paidReceipt(tester, h);
      await _open(tester, h, '/fees/receipt/$id', FakeShare());
      await tester.pumpAndSettle();
      expect(find.text('টিউশন খাতা'), findsOneWidget);
    });

    feeUiTest('shows advance credit, a one-time fee and the reference', (
      tester,
      h,
    ) async {
      final s = await seedStudent(
        tester,
        h,
        joinedOn: const LocalDate(2026, 3, 1),
      );
      await real(
        tester,
        () => h.fees.addOneTimeFee(s.id, label: 'Admission', amount: 500),
      );
      final p = (await real(
        tester,
        () => h.payments.record(
          PaymentInput(
            studentId: s.id,
            amount: 2300,
            receivedOn: h.today,
            reference: 'TX42',
          ),
        ),
      )).payment;
      await _open(tester, h, '/fees/receipt/${p.id}', FakeShare());
      await tester.pumpAndSettle();
      expect(find.text('Admission (মার্চ ২০২৬)'), findsOneWidget);
      expect(find.text('অগ্রিম জমা'), findsOneWidget);
      expect(find.text('৳ ৩০০'), findsOneWidget);
      expect(find.text('TX42'), findsOneWidget);
    });

    feeUiTest('a very long Bangla name wraps without overflowing', (
      tester,
      h,
    ) async {
      const long =
          'মোহাম্মদ আব্দুল্লাহ আল মামুন চৌধুরী সিদ্দিকী ইসলাম উদ্দিন আহমেদ খান বাহাদুর শ্রীমান দীপঙ্কর';
      final s = await seedStudent(tester, h, name: long);
      final p = (await real(tester, () => h.pay(s.id, 1500))).payment;
      await _open(tester, h, '/fees/receipt/${p.id}', FakeShare());
      await tester.pumpAndSettle();
      expect(find.text(long), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
      ); // a RenderFlex overflow would be thrown here
    });

    feeUiTest('an unknown payment shows a not-found message', (
      tester,
      h,
    ) async {
      await _open(tester, h, '/fees/receipt/nope', FakeShare());
      await tester.pumpAndSettle();
      expect(find.text('কোনো শিক্ষার্থী মেলেনি'), findsOneWidget);
    });
  });

  group('sharing', () {
    feeUiTest(
      'as an image: a PNG file is written and shared, and the payment is marked',
      (tester, h) async {
        final id = await _paidReceipt(tester, h);
        final share = FakeShare();
        await _open(tester, h, '/fees/receipt/$id', share);
        await tester.pumpAndSettle();

        await tester.tap(find.text('ছবি হিসেবে শেয়ার করুন'));
        await waitFor(tester, 8);

        final shared = share.files.single;
        expect(shared.mime, 'image/png');
        expect(shared.path, endsWith('receipt_1.png'));
        final bytes = File(shared.path).readAsBytesSync();
        expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]); // PNG signature
        expect(_pngWidth(bytes), 1080); // 360 logical px at 3x

        final p = await real(tester, () => h.payments.getById(id));
        expect(p!.receiptSharedAt, isNotNull);
      },
    );

    feeUiTest('as a PDF: a one-page PDF is written and shared', (
      tester,
      h,
    ) async {
      final id = await _paidReceipt(tester, h);
      final share = FakeShare();
      await _open(tester, h, '/fees/receipt/$id', share);
      await tester.pumpAndSettle();

      await tester.tap(find.text('PDF হিসেবে শেয়ার করুন'));
      await waitFor(tester, 8);

      final shared = share.files.single;
      expect(shared.mime, 'application/pdf');
      expect(shared.path, endsWith('receipt_1.pdf'));
      final bytes = File(shared.path).readAsBytesSync();
      expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
      expect(String.fromCharCodes(bytes), contains('/Count 1')); // one page
      expect(
        (await real(tester, () => h.payments.getById(id)))!.receiptSharedAt,
        isNotNull,
      );
    });

    feeUiTest(
      'dismissing the share sheet does not mark the receipt as shared',
      (tester, h) async {
        final id = await _paidReceipt(tester, h);
        await _open(tester, h, '/fees/receipt/$id', FakeShare(result: false));
        await tester.pumpAndSettle();
        await tester.tap(find.text('ছবি হিসেবে শেয়ার করুন'));
        await waitFor(tester, 8);
        expect(
          (await real(tester, () => h.payments.getById(id)))!.receiptSharedAt,
          isNull,
        );
      },
    );

    feeUiTest('a share failure is reported and nothing is marked', (
      tester,
      h,
    ) async {
      final id = await _paidReceipt(tester, h);
      await _open(tester, h, '/fees/receipt/$id', FakeShare(fails: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ছবি হিসেবে শেয়ার করুন'));
      await waitFor(tester, 8);
      expect(find.text('শেয়ার করা যায়নি'), findsOneWidget);
      expect(
        (await real(tester, () => h.payments.getById(id)))!.receiptSharedAt,
        isNull,
      );
    });

    feeUiTest('once shared, editing the payment warns about it', (
      tester,
      h,
    ) async {
      final id = await _paidReceipt(tester, h);
      await _open(tester, h, '/fees/receipt/$id', FakeShare());
      await tester.pumpAndSettle();
      await tester.tap(find.text('ছবি হিসেবে শেয়ার করুন'));
      await waitFor(tester, 8);

      await pushRoute(tester, '/fees/payments/$id/edit');
      expect(find.textContaining('রসিদ আগে শেয়ার করা হয়েছে'), findsOneWidget);
    });
  });

  group('reaching the receipt', () {
    feeUiTest('the payment-saved dialog offers it', (tester, h) async {
      final s = await seedStudent(tester, h);
      await _open(tester, h, '/fees/pay/${s.id}', FakeShare());
      await tester.tap(find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'));
      await waitFor(tester);
      expect(find.text('রসিদ শেয়ার করুন'), findsOneWidget);

      await tester.tap(find.text('রসিদ শেয়ার করুন'));
      await waitFor(tester);
      expect(
        find.text('ছবি হিসেবে শেয়ার করুন'),
        findsOneWidget,
      ); // on the receipt screen
      expect(find.text('রসিদ নং ১'), findsOneWidget);
    });

    feeUiTest('Done skips the receipt', (tester, h) async {
      final s = await seedStudent(tester, h);
      await _open(tester, h, '/fees/pay/${s.id}', FakeShare());
      await tester.tap(find.widgetWithText(FilledButton, 'সংরক্ষণ করুন'));
      await waitFor(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'ঠিক আছে'));
      await tester.pumpAndSettle();
      expect(find.text('ছবি হিসেবে শেয়ার করুন'), findsNothing);
    });

    feeUiTest('a payment in the history opens its receipt', (tester, h) async {
      final s = await seedStudent(tester, h);
      await real(tester, () => h.pay(s.id, 1500));
      await _open(tester, h, '/students/${s.id}', FakeShare());
      await tester.tap(find.widgetWithText(Tab, 'ফি'));
      await tester.pumpAndSettle();

      await tapCentered(tester, find.textContaining('রসিদ নং ১'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('রসিদ').last);
      await waitFor(tester);
      expect(find.text('ছবি হিসেবে শেয়ার করুন'), findsOneWidget);
    });
  });
}
