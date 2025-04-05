// packages/atomic_styles/lib/src/rules/backgrounds.dart
import '../constants.dart'; // Import constants

final Map<RegExp, String? Function(List<String> matches)> backgroundRules = {
  // --- Backgrounds ---

  // Background Color: bg-{color}-{shade} or bg-{color}
  RegExp(r'^bg-(.+)$'): (matches) {
    final colorKey = matches[0];
    // Check if it's not another bg-* utility like bg-fixed, bg-cover etc.
    // This check might need refinement depending on other rules added.
    if (RegExp(
            r'^(fixed|local|scroll|clip-.+|origin-.+|bottom|center|left|right|top|repeat.*|no-repeat|auto|cover|contain)$')
        .hasMatch(colorKey)) {
      return null;
    }
    final colorValue = colors[colorKey]; // Use constant
    if (colorValue == null) return null;
    return 'background-color: $colorValue;';
  },

  // Background Attachment
  RegExp(r'^bg-(fixed|local|scroll)$'): (matches) =>
      'background-attachment: ${matches[0]};',

  // Background Clip
  RegExp(r'^bg-clip-(border|padding|content|text)$'): (matches) {
    final clipValue = matches[0];
    // Special handling for text clipping often requires vendor prefix
    if (clipValue == 'text') {
      return '-webkit-background-clip: text; background-clip: text; color: transparent;'; // Basic text clip effect
    }
    return 'background-clip: ${clipValue}-box;';
  },

  // Background Origin
  RegExp(r'^bg-origin-(border|padding|content)$'): (matches) =>
      'background-origin: ${matches[0]}-box;',

  // Background Position
  RegExp(r'^bg-(bottom|center|left|left-bottom|left-top|right|right-bottom|right-top|top)$'):
      (matches) => 'background-position: ${matches[0].replaceAll('-', ' ')};',

  // Background Repeat
  RegExp(r'^bg-repeat(-x|-y|-round|-space)?$'): (matches) {
    final suffix = matches[0]; // -x, -y, -round, -space, or empty string ''
    // If suffix is empty (matched 'bg-repeat'), return 'repeat'. Otherwise, append suffix.
    return 'background-repeat: repeat${suffix.isEmpty ? '' : suffix};';
  },
  RegExp(r'^bg-no-repeat$'): (matches) => 'background-repeat: no-repeat;',

  // Background Size
  RegExp(r'^bg-(auto|cover|contain)$'): (matches) =>
      'background-size: ${matches[0]};',
};
