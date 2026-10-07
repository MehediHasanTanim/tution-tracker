import 'package:tution_tracker/features/fees/domain/payment_method.dart';
import 'package:tution_tracker/l10n/generated/app_localizations.dart';

String paymentMethodLabel(AppLocalizations l10n, PaymentMethod m) =>
    switch (m) {
      PaymentMethod.cash => l10n.methodCash,
      PaymentMethod.bkash => l10n.methodBkash,
      PaymentMethod.nagad => l10n.methodNagad,
      PaymentMethod.rocket => l10n.methodRocket,
      PaymentMethod.bank => l10n.methodBank,
      PaymentMethod.other => l10n.methodOther,
    };
