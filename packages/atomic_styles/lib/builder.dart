// packages/atomic_styles/lib/builder.dart
import 'package:build/build.dart';
import 'src/builder.dart'; // Import the AtomicStyleBuilder implementation
import 'src/css_writer.dart'; // Import the CssWriterBuilder implementation

/// Builder factory function for AtomicStyleBuilder (scans .dart, outputs .atomic_scan_complete).
Builder atomicStyleBuilder(BuilderOptions options) => AtomicStyleBuilder();

/// Builder factory function for CssWriterBuilder (reads collected classes, generates final CSS).
Builder cssWriterBuilder(BuilderOptions options) => CssWriterBuilder(options);
