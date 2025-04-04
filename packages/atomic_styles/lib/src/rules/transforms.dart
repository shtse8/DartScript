// packages/atomic_styles/lib/src/rules/transforms.dart
import '../constants.dart'; // Import constants

final Map<RegExp, String? Function(List<String> matches)> transformRules = {
  // --- Transforms ---
  // Note: Simplified - setting transform directly overwrites previous transforms.
  // Proper implementation often uses CSS variables like --tw-translate-x, --tw-rotate, etc.

  // Translate
  RegExp(r'^-?translate-x-(.+)$'): (matches) {
    // This regex captures the value part including potential '-' for negative lookup
    final rawValueKey = matches[0];
    final isNegative = rawValueKey.startsWith('-');
    final valueKey = isNegative ? rawValueKey.substring(1) : rawValueKey;
    final lookupKey = isNegative ? '-$valueKey' : valueKey;
    final spacingValue = spacingScale[lookupKey]; // Use constant
    if (spacingValue == null) return null;
    final finalValue = isNegative ? '-$spacingValue' : spacingValue;
    return 'transform: translateX($finalValue);'; // Simplified
  },
  RegExp(r'^-?translate-y-(.+)$'): (matches) {
    final rawValueKey = matches[0];
    final isNegative = rawValueKey.startsWith('-');
    final valueKey = isNegative ? rawValueKey.substring(1) : rawValueKey;
    final lookupKey = isNegative ? '-$valueKey' : valueKey;
    final spacingValue = spacingScale[lookupKey]; // Use constant
    if (spacingValue == null) return null;
    final finalValue = isNegative ? '-$spacingValue' : spacingValue;
    return 'transform: translateY($finalValue);'; // Simplified
  },

  // Rotate
  RegExp(r'^(-?)rotate-([0-9]+)$'): (matches) {
    final sign = matches[0] == '-' ? '-' : '';
    final value = matches[1];
    // Basic validation for angle value might be needed
    return 'transform: rotate(${sign}${value}deg);'; // Simplified
  },

  // Scale
  RegExp(r'^scale-([0-9]+)$'): (matches) {
    final value = int.tryParse(matches[0]);
    if (value == null || value < 0) return null;
    return 'transform: scale(${value / 100});'; // Simplified
  },
  RegExp(r'^scale-x-([0-9]+)$'): (matches) {
    final value = int.tryParse(matches[0]);
    if (value == null || value < 0) return null;
    return 'transform: scaleX(${value / 100});'; // Simplified
  },
  RegExp(r'^scale-y-([0-9]+)$'): (matches) {
    final value = int.tryParse(matches[0]);
    if (value == null || value < 0) return null;
    return 'transform: scaleY(${value / 100});'; // Simplified
  },

  // Skew
  RegExp(r'^(-?)skew-x-([0-9]+)$'): (matches) {
    final sign = matches[0] == '-' ? '-' : '';
    final value = matches[1];
    // Basic validation for angle value might be needed
    return 'transform: skewX(${sign}${value}deg);'; // Simplified
  },
  RegExp(r'^(-?)skew-y-([0-9]+)$'): (matches) {
    final sign = matches[0] == '-' ? '-' : '';
    final value = matches[1];
    // Basic validation for angle value might be needed
    return 'transform: skewY(${sign}${value}deg);'; // Simplified
  },

  // Transform Origin
  RegExp(r'^origin-(center|top|top-right|right|bottom-right|bottom|bottom-left|left|top-left)$'):
      (matches) => 'transform-origin: ${matches[0].replaceAll('-', ' ')};',
};
