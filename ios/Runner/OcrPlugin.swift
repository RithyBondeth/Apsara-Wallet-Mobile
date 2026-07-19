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
      // Vision's coordinate origin is bottom-left, so a larger y is higher up
      // the page — sort descending to read top-to-bottom.
      let lines = observations
        .sorted { $0.boundingBox.origin.y > $1.boundingBox.origin.y }
        .compactMap { $0.topCandidates(1).first?.string }
      DispatchQueue.main.async { result(lines) }
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
