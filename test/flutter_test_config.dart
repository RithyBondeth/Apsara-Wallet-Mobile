import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden comparison with a small tolerance.
///
/// The PNGs in test/goldens are rendered on a developer Mac. Any other
/// machine — CI's macOS image, a newer Flutter engine, a different OS
/// font build — rasterises text a hair differently, which the exact
/// comparator rejects at 0.1–0.3% pixel diff. Real layout regressions are
/// an order of magnitude larger (the ones caught during the audit were
/// 7–28%), so a 1% ceiling keeps the signal and drops the noise.
class _TolerantGoldenComparator extends LocalFileComparator {
  _TolerantGoldenComparator(super.testFile);

  static const double _maxDiffRatio = 0.01;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed) return true;
    if (result.diffPercent <= _maxDiffRatio) return true;
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final previous = goldenFileComparator;
  if (previous is LocalFileComparator) {
    goldenFileComparator = _TolerantGoldenComparator(
      Uri.parse('${previous.basedir}/placeholder_test.dart'),
    );
  }
  await testMain();
}
