package com.apsarawallet.app

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
    /// Receipts are columns: ML Kit returns "Jasmine Rice 5kg" and "8.50" as
    /// separate lines, and sorting by top alone interleaves them. Group lines
    /// whose vertical centre falls inside an existing row's band, then read
    /// rows top-to-bottom and cells left-to-right so the Dart parser sees one
    /// line per printed row ("Jasmine Rice 5kg  8.50"). Mirrors OcrPlugin.swift.
    private fun rows(lines: List<com.google.mlkit.vision.text.Text.Line>): List<String> {
        data class Row(var top: Int, var bottom: Int, val cells: MutableList<com.google.mlkit.vision.text.Text.Line>)
        val rows = mutableListOf<Row>()
        for (line in lines.sortedBy { it.boundingBox?.centerY() ?: 0 }) {
            val box = line.boundingBox ?: continue
            val cy = box.centerY()
            val row = rows.firstOrNull { cy >= it.top && cy <= it.bottom }
            if (row != null) {
                row.cells.add(line)
                row.top = minOf(row.top, box.top)
                row.bottom = maxOf(row.bottom, box.bottom)
            } else {
                rows.add(Row(box.top, box.bottom, mutableListOf(line)))
            }
        }
        return rows.map { row ->
            row.cells.sortedBy { it.boundingBox?.left ?: 0 }.joinToString("  ") { it.text }
        }
    }

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
                            recognizer.close()
                            result.success(rows(visionText.textBlocks.flatMap { it.lines }))
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
