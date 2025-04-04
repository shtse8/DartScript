// packages/atomic_styles/lib/builder.dart
import 'package:build/build.dart';
import 'src/builder.dart'; // Import the AtomicStyleBuilder implementation
import 'src/aggregator.dart'; // Import the AtomicCssAggregator implementation

/// Builder factory function for AtomicStyleBuilder (scans .dart, outputs .atomic_scan_complete).
Builder atomicStyleBuilder(BuilderOptions options) => AtomicStyleBuilder();

/// Builder factory function for AtomicCssAggregator (reads .classes files, generates final CSS).
Builder cssAggregatorBuilder(BuilderOptions options) => AtomicCssAggregator();
