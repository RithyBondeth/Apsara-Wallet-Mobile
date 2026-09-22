import Flutter
import UIKit
import Vision

/// OCR over the `apsara/ocr` method channel, backed by Apple's Vision
/// framework. Vision runs on both physical devices and the iOS Simulator, so
/// the receipt scanner works everywhere the app builds.
///
/// `scanImage({ path }) -> [String]` returns the recognised text lines ordered
/// top-to-bottom, which `ReceiptParser` (Dart) turns into a structured receipt.
class OcrPlugin: NSObject {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "apsara/ocr",
      binaryMessenger: registrar.messenger()
    )
    let instance = OcrPlugin()
    channel.setMethodCallHandler(instance.handle)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "scanImage" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard
      let args = call.arguments as? [String: Any],
      let path = args["path"] as? String,
      let image = UIImage(contentsOfFile: path),
      let cgImage = image.cgImage
    else {
      result(FlutterError(
        code: "bad_image",
        message: "Could not load the image for OCR.",
        details: nil
      ))
      return
    }

    let orientation = Self.cgOrientation(from: image.imageOrientation)

    let request = VNRecognizeTextRequest { request, error in
      if let error = error {
        DispatchQueue.main.async {
          result(FlutterError(
            code: "ocr_failed",
            message: error.localizedDescription,
            details: nil
          ))
        }
        return
      }
      let observations =
        (request.results as? [VNRecognizedTextObservation]) ?? []
      DispatchQueue.main.async { result(Self.rows(from: observations)) }
    }
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(
      cgImage: cgImage,
      orientation: orientation,
      options: [:]
    )
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try handler.perform([request])
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(
            code: "ocr_failed",
            message: error.localizedDescription,
            details: nil
          ))
        }
      }
    }
  }

  /// Receipts are columns: Vision returns "Jasmine Rice 5kg" and "8.50" as
  /// two observations, and sorting by y alone interleaves them in an
  /// unstable order. Group observations whose vertical centre falls inside
  /// an existing row's band, read rows top-to-bottom and cells left-to-right,
  /// so the parser sees one line per printed row ("Jasmine Rice 5kg  8.50",
  /// "TOTAL  USD 35.04"). Vision's origin is bottom-left: larger y is higher.
  static func rows(from observations: [VNRecognizedTextObservation]) -> [String] {
    struct Row {
      var minY: CGFloat
      var maxY: CGFloat
      var cells: [VNRecognizedTextObservation]
    }
    var rows: [Row] = []
    for o in observations.sorted(by: { $0.boundingBox.midY > $1.boundingBox.midY }) {
      let b = o.boundingBox
      if let i = rows.indices.first(where: { b.midY >= rows[$0].minY && b.midY <= rows[$0].maxY }) {
        rows[i].cells.append(o)
        rows[i].minY = min(rows[i].minY, b.minY)
        rows[i].maxY = max(rows[i].maxY, b.maxY)
      } else {
        rows.append(Row(minY: b.minY, maxY: b.maxY, cells: [o]))
      }
    }
    return rows.map { row in
      row.cells
        .sorted { $0.boundingBox.minX < $1.boundingBox.minX }
        .compactMap { $0.topCandidates(1).first?.string }
        .joined(separator: "  ")
    }
  }

  private static func cgOrientation(
    from orientation: UIImage.Orientation
  ) -> CGImagePropertyOrientation {
    switch orientation {
    case .up: return .up
    case .upMirrored: return .upMirrored
    case .down: return .down
    case .downMirrored: return .downMirrored
    case .left: return .left
    case .leftMirrored: return .leftMirrored
    case .right: return .right
    case .rightMirrored: return .rightMirrored
    @unknown default: return .up
    }
  }
}
