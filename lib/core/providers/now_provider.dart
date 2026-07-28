import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current wall-clock time, as a provider so screens can group/relativize
/// dates against "now" while tests override it with a fixed instant (keeping
/// day-grouping and goldens deterministic).
final nowProvider = Provider<DateTime>((ref) => DateTime.now());
