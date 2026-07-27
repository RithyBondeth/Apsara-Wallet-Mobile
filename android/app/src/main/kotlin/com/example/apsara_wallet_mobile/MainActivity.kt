package com.example.apsara_wallet_mobile

import android.net.Uri
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/// Hosts the `apsara/ocr` method channel, backed by Google ML Kit's on-device
/// Latin text recogniser. Mirrors the iOS (Apple Vision) implementation:
/// `scanImage({ path }) -> [String]` returns recognised lines top-to-bottom,
/// which the Dart [ReceiptParser] turns into a structured receipt.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "apsara/ocr")
            .setMethodCallHandler { call, result ->
                if (call.method != "scanImage") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val path = call.argument<String>("path")
                if (path == null) {
                    result.error("bad_args", "Missing image path", null)
                    return@setMethodCallHandler
                }
                try {
                    val image = InputImage.fromFilePath(this, Uri.fromFile(File(path)))
                    val recognizer =
                        TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
                    recognizer.process(image)
                        .addOnSuccessListener { visionText ->
                            val lines = visionText.textBlocks
                                .flatMap { it.lines }
                                .sortedBy { it.boundingBox?.top ?: 0 }
                                .map { it.text }
                            recognizer.close()
                            result.success(lines)
                        }
                        .addOnFailureListener { e ->
                            recognizer.close()
                            result.error("ocr_failed", e.message, null)
                        }
                } catch (e: Exception) {
                    result.error("ocr_failed", e.message, null)
                }
            }
    }
}
