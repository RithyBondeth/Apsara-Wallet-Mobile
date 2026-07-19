import 'package:flutter/services.dart';

import 'package:apsara_wallet_mobile/features/scan/data/receipt_parser.dart';
import 'package:apsara_wallet_mobile/features/scan/data/scanned_receipt.dart';

/// Runs on-device OCR over a captured/selected receipt image and hands the
/// recognised text to [ReceiptParser].
///
/// OCR is provided by the host platform through the `apsara/ocr` method
/// channel — Apple Vision on iOS (works on the Simulator too) and Google
/// ML Kit on Android. Keeping the OCR engine native means the parsing
/// heuristics stay pure Dart and unit-testable, and the app links cleanly on
/// the iOS Simulator (the ML Kit Flutter plugin ships no simulator slice).
class ReceiptScannerService {
  ReceiptScannerService();

  static const MethodChannel _channel = MethodChannel('apsara/ocr');

  /// Recognises text in the image at [imagePath] and parses it into a receipt.
  Future<ScannedReceipt> scanImage(String imagePath) async {
    final lines = await _channel.invokeListMethod<String>(
      'scanImage',
      {'path': imagePath},
    );
    return ReceiptParser.parse(lines ?? const []);
  }

  Future<void> dispose() async {}
}
