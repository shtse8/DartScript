// packages/atomic_styles/lib/src/rules/svg.dart
import '../constants.dart'; // Import constants

final Map<RegExp, String? Function(List<String> matches)> svgRules = {
  // --- SVG ---

  // Fill Color
  RegExp(r'^fill-(.+)$'): (matches) {
    final colorKey = matches[0];
    if (colorKey == 'current') return 'fill: currentColor;';
    final colorValue = colors[colorKey]; // Use constant
    if (colorValue == null) return null;
    return 'fill: $colorValue;';
  },

  // Stroke Color
  RegExp(r'^stroke-(.+)$'): (matches) {
    final colorKey = matches[0];
    // Check if it's not stroke width
    if (RegExp(r'^[0-9]+$').hasMatch(colorKey)) return null;

    if (colorKey == 'current') return 'stroke: currentColor;';
    final colorValue = colors[colorKey]; // Use constant
    if (colorValue == null) return null;
    return 'stroke: $colorValue;';
  },

  // Stroke Width
  RegExp(r'^stroke-([0-9]+)$'): (matches) => 'stroke-width: ${matches[0]};',
};
