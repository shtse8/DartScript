// packages/atomic_styles/lib/src/rules/layout.dart
import '../constants.dart'; // Import constants

final Map<RegExp, String? Function(List<String> matches)> layoutRules = {
  // --- Layout ---

  // Position
  RegExp(r'^(static|fixed|absolute|relative|sticky)$'): (matches) =>
      'position: ${matches[0]};',

  // Top / Right / Bottom / Left
  RegExp(r'^(top|right|bottom|left)-(.+)$'): (matches) {
    final side = matches[0];
    final valueKey = matches[1];
    final spacingValue = spacingScale[valueKey]; // Use constant
    if (spacingValue == null) return null;
    return '$side: $spacingValue;';
  },
  // Negative Top / Right / Bottom / Left
  RegExp(r'^-(top|right|bottom|left)-(.+)$'): (matches) {
    final side = matches[0];
    final valueKey = matches[1];
    final spacingValue =
        spacingScale['-$valueKey']; // Use constant with negative key
    if (spacingValue == null) return null;
    return '$side: -$spacingValue;';
  },

  // Inset (top, right, bottom, left)
  RegExp(r'^inset-(.+)$'): (matches) {
    final valueKey = matches[0];
    final spacingValue = spacingScale[valueKey]; // Use constant
    if (spacingValue == null) return null;
    return 'top: $spacingValue; right: $spacingValue; bottom: $spacingValue; left: $spacingValue;';
  },
  // Negative Inset
  RegExp(r'^-inset-(.+)$'): (matches) {
    final valueKey = matches[0];
    final spacingValue = spacingScale['-$valueKey']; // Use constant
    if (spacingValue == null) return null;
    return 'top: -$spacingValue; right: -$spacingValue; bottom: -$spacingValue; left: -$spacingValue;';
  },

  // Inset X (left, right)
  RegExp(r'^inset-x-(.+)$'): (matches) {
    final valueKey = matches[0];
    final spacingValue = spacingScale[valueKey]; // Use constant
    if (spacingValue == null) return null;
    return 'left: $spacingValue; right: $spacingValue;';
  },
  // Negative Inset X
  RegExp(r'^-inset-x-(.+)$'): (matches) {
    final valueKey = matches[0];
    final spacingValue = spacingScale['-$valueKey']; // Use constant
    if (spacingValue == null) return null;
    return 'left: -$spacingValue; right: -$spacingValue;';
  },

  // Inset Y (top, bottom)
  RegExp(r'^inset-y-(.+)$'): (matches) {
    final valueKey = matches[0];
    final spacingValue = spacingScale[valueKey]; // Use constant
    if (spacingValue == null) return null;
    return 'top: $spacingValue; bottom: $spacingValue;';
  },
  // Negative Inset Y
  RegExp(r'^-inset-y-(.+)$'): (matches) {
    final valueKey = matches[0];
    final spacingValue = spacingScale['-$valueKey']; // Use constant
    if (spacingValue == null) return null;
    return 'top: -$spacingValue; bottom: -$spacingValue;';
  },

  // Z-Index
  RegExp(r'^z-(auto|[0-9]+)$'): (matches) {
    final value = matches[0];
    // Basic validation, can expand allowed values
    if (value != 'auto' && int.tryParse(value) == null) return null;
    if (value != 'auto' && int.parse(value) < 0)
      return null; // Example: only allow 0+
    return 'z-index: $value;';
  },

  // Overflow
  RegExp(r'^overflow-(auto|hidden|visible|scroll)$'): (matches) =>
      'overflow: ${matches[0]};',
  RegExp(r'^overflow-x-(auto|hidden|visible|scroll)$'): (matches) =>
      'overflow-x: ${matches[0]};',
  RegExp(r'^overflow-y-(auto|hidden|visible|scroll)$'): (matches) =>
      'overflow-y: ${matches[0]};',

  // Display (Often considered layout)
  RegExp(r'^(block|inline-block|inline|flex|grid|hidden)$'): (matches) {
    final displayValue = matches[0];
    if (displayValue == 'hidden') return 'display: none;';
    return 'display: $displayValue;';
  },
};
