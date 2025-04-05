// packages/atomic_styles/lib/src/rules/borders.dart
import '../constants.dart'; // Import constants

final Map<RegExp, String? Function(List<String> matches)> borderRules = {
  // --- Borders ---

  // Border Radius: rounded, rounded-{sm|md|lg|xl|2xl|3xl|full}
  RegExp(r'^rounded(?:-(sm|md|lg|xl|2xl|3xl|full))?$'): (matches) {
    final size = matches[0]; // sm, md, lg, xl, 2xl, 3xl, full, or null
    const radiusMap = {
      null: '0.25rem', // default rounded
      'sm': '0.125rem',
      'md': '0.375rem',
      'lg': '0.5rem',
      'xl': '0.75rem',
      '2xl': '1rem',
      '3xl': '1.5rem',
      'full': '9999px',
    };
    if (!radiusMap.containsKey(size)) return null; // Check if size is valid key
    return 'border-radius: ${radiusMap[size]};';
  },

  // Border Width: border, border-{value}
  // Sets width, default style (solid), and default color (currentColor)
  RegExp(r'^border(?:-([0-9]+))?$'): (matches) {
    final valueKey = matches[0]; // Can be null for just 'border'
    final width = valueKey.isEmpty
        ? '1px'
        : '${valueKey}px'; // Default to 1px if valueKey is empty
    // Apply default border style and color. Color can be overridden by border-{color}.
    return 'border-width: $width; border-style: solid; border-color: currentColor;';
  },

  // Border Color: border-{color}-{shade} or border-{color}
  RegExp(r'^border-(.+)$'): (matches) {
    final key = matches[0];
    // Check if it's not a border width (e.g., border-2) or style (e.g., border-solid)
    if (RegExp(r'^[0-9]+$').hasMatch(key) ||
        RegExp(r'^(solid|dashed|dotted|double|hidden|none|collapse|separate)$')
            .hasMatch(key)) {
      return null;
    }

    final colorValue = colors[key]; // Use constant
    if (colorValue == null) return null;
    // Set border-color, assumes border-width and style are set elsewhere (e.g., by 'border')
    return 'border-color: $colorValue;';
  },

  // Border Style (overrides style set by border-width rule)
  RegExp(r'^border-(solid|dashed|dotted|double|hidden|none)$'): (matches) =>
      'border-style: ${matches[0]};',

  // Border Collapse
  RegExp(r'^border-(collapse|separate)$'): (matches) =>
      'border-collapse: ${matches[0]};',
};
