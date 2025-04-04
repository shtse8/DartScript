// packages/atomic_styles/lib/builder.dart
import 'package:build/build.dart';
import 'src/builder.dart'; // Import the actual builder implementation

/// Builder factory function required by build.yaml.
Builder atomicStyleBuilder(BuilderOptions options) => AtomicStyleBuilder();
