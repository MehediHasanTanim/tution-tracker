import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Captures the widget under [key] (which must be a [RepaintBoundary]) as a
/// PNG. [pixelRatio] 3 gives a sharp image on a phone screen.
Future<Uint8List> capturePng(GlobalKey key, {double pixelRatio = 3}) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

/// A one-page PDF holding the receipt image.
///
/// The receipt is an image on purpose: the `pdf` package cannot shape Bangla
/// conjuncts, but Flutter's text engine can, so the receipt is drawn by
/// Flutter and only wrapped here. The page is sized to the receipt
/// ([width] by [height] logical pixels, plus a margin) rather than A4.
Future<Uint8List> receiptPdf(
  Uint8List png, {
  required double width,
  required double height,
  String? title,
}) async {
  const margin = 24.0;
  final doc = pw.Document(title: title);
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(width + 2 * margin, height + 2 * margin),
      margin: const pw.EdgeInsets.all(margin),
      build: (_) => pw.Image(pw.MemoryImage(png), width: width, height: height),
    ),
  );
  return doc.save();
}
