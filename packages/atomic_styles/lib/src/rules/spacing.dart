// packages/atomic_styles/lib/src/rules/spacing.dart
import '../constants.dart'; // Import constants

final Map<RegExp, String? Function(List<String> matches)> spacingRules = {
  // Margin: m-{value}, mx-{value}, my-{value}, mt-{value}, mr-{value}, mb-{value}, ml-{value}
  // Handles positive, negative, and auto values from spacingScale
  RegExp(r'^-?(m|mx|my|mt|mr|mb|ml)-(.+)$'): (matches) {
    // Extract parts carefully, considering the optional '-'
    // The first group captures the optional '-', the second the type (m, mx, etc.), the third the value key.
    final match =
        RegExp(r'^(-)?(m|mx|my|mt|mr|mb|ml)-(.+)$').firstMatch(matches[0]);
    if (match == null) return null; // Should not happen if outer regex matched

    final isNegative = match.group(1) == '-';
    final type = match.group(2)!; // m, mx, my, etc.
    final valueKey = match.group(3)!; // '4', 'px', 'auto'

    final lookupKey = isNegative ? '-$valueKey' : valueKey;
    // Use spacingScale from constants.dart
    final spacingValue = spacingScale[lookupKey];

    if (spacingValue == null) return null; // Invalid value

    final finalValue = isNegative ? '-$spacingValue' : spacingValue;

    // Handle 'auto' specifically for margin
    if (valueKey == 'auto' && !isNegative) {
      switch (type) {
        case 'm':
          return 'margin: auto;';
        case 'mx':
          return 'margin-left: auto; margin-right: auto;';
        case 'my':
          return 'margin-top: auto; margin-bottom: auto;';
        case 'mt':
          return 'margin-top: auto;';
        case 'mr':
          return 'margin-right: auto;';
        case 'mb':
          return 'margin-bottom: auto;';
        case 'ml':
          return 'margin-left: auto;';
        default:
          return null;
      }
    } else if (valueKey == 'auto' && isNegative) {
      return null; // Negative auto margin is invalid
    }

    // Handle numeric/rem/px values
    switch (type) {
      case 'm':
        return 'margin: $finalValue;';
      case 'mx':
        return 'margin-left: $finalValue; margin-right: $finalValue;';
      case 'my':
        return 'margin-top: $finalValue; margin-bottom: $finalValue;';
      case 'mt':
        return 'margin-top: $finalValue;';
      case 'mr':
        return 'margin-right: $finalValue;';
      case 'mb':
        return 'margin-bottom: $finalValue;';
      case 'ml':
        return 'margin-left: $finalValue;';
      default:
        return null;
    }
  },

  // Padding: p-{value}, px-{value}, py-{value}, pt-{value}, pr-{value}, pb-{value}, pl-{value}
  RegExp(r'^(p|px|py|pt|pr|pb|pl)-(.+)$'): (matches) {
    final type = matches[0]; // p, px, py, pt, pr, pb, pl
    final valueKey = matches[1]; // e.g., '4', 'px'
    // Use spacingScale from constants.dart
    final spacingValue = spacingScale[valueKey];
    if (spacingValue == null) return null; // Invalid value

    switch (type) {
      case 'p':
        return 'padding: $spacingValue;';
      case 'px':
        return 'padding-left: $spacingValue; padding-right: $spacingValue;';
      case 'py':
        return 'padding-top: $spacingValue; padding-bottom: $spacingValue;';
      case 'pt':
        return 'padding-top: $spacingValue;';
      case 'pr':
        return 'padding-right: $spacingValue;';
      case 'pb':
        return 'padding-bottom: $spacingValue;';
      case 'pl':
        return 'padding-left: $spacingValue;';
      default:
        return null;
    }
  },

  // Space Between (for flex/grid children)
  RegExp(r'^space-x-(.+)$'): (matches) {
    final valueKey = matches[0];
    // Use spacingScale from constants.dart
    final spacingValue = spacingScale[valueKey];
    if (spacingValue == null) return null;
    // Uses the lobotomized owl selector, works for direct children
    return '> * + * { margin-left: $spacingValue; }';
  },
  RegExp(r'^space-y-(.+)$'): (matches) {
    final valueKey = matches[0];
    // Use spacingScale from constants.dart
    final spacingValue = spacingScale[valueKey];
    if (spacingValue == null) return null;
    return '> * + * { margin-top: $spacingValue; }';
  },
};
