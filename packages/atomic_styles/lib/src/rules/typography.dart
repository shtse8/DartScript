// packages/atomic_styles/lib/src/rules/typography.dart
import '../constants.dart'; // Import constants

final Map<RegExp, String? Function(List<String> matches)> typographyRules = {
  // --- Typography ---

  // Text Color: text-{color}-{shade} or text-{color}
  RegExp(r'^text-(.+)$'): (matches) {
    final colorKey = matches[0]; // e.g., 'red-500', 'white'
    final colorValue = colors[colorKey]; // Use constant
    if (colorValue == null) return null; // Invalid color
    return 'color: $colorValue;';
  },

  // Font Weight: font-{weight}
  RegExp(r'^font-(thin|extralight|light|normal|medium|semibold|bold|extrabold|black)$'):
      (matches) {
    final weightName = matches[0];
    const weightMap = {
      'thin': '100',
      'extralight': '200',
      'light': '300',
      'normal': '400',
      'medium': '500',
      'semibold': '600',
      'bold': '700',
      'extrabold': '800',
      'black': '900',
    };
    final weightValue = weightMap[weightName];
    if (weightValue == null) return null;
    return 'font-weight: $weightValue;';
  },

  // Text Size: text-{size}
  RegExp(r'^text-(xs|sm|base|lg|xl|2xl|3xl|4xl|5xl|6xl)$'): (matches) {
    final sizeKey = matches[0];
    // Approximate Tailwind sizes, adjust as needed
    const sizeMap = {
      'xs': '0.75rem',
      'sm': '0.875rem',
      'base': '1rem',
      'lg': '1.125rem',
      'xl': '1.25rem',
      '2xl': '1.5rem',
      '3xl': '1.875rem',
      '4xl': '2.25rem',
      '5xl': '3rem',
      '6xl': '4rem',
    };
    // Line height often paired with font size, simplified here
    const lineHeightMap = {
      'xs': '1rem', 'sm': '1.25rem', 'base': '1.5rem', 'lg': '1.75rem',
      'xl': '1.75rem', '2xl': '2rem', '3xl': '2.25rem', '4xl': '2.5rem',
      '5xl': '1', '6xl': '1', // Usually set explicitly for larger sizes
    };
    final sizeValue = sizeMap[sizeKey];
    final lineHeightValue = lineHeightMap[sizeKey];
    if (sizeValue == null || lineHeightValue == null) return null;
    return 'font-size: $sizeValue; line-height: $lineHeightValue;';
  },

  // Text Alignment
  RegExp(r'^text-(left|center|right|justify)$'): (matches) =>
      'text-align: ${matches[0]};',

  // Text Decoration (including line-through)
  RegExp(r'^(underline|overline|line-through|no-underline)$'): (matches) {
    final decoration = matches[0];
    if (decoration == 'no-underline') return 'text-decoration-line: none;';
    return 'text-decoration-line: $decoration;';
  },

  // Text Transform
  RegExp(r'^(uppercase|lowercase|capitalize|normal-case)$'): (matches) {
    final transform = matches[0];
    if (transform == 'normal-case') return 'text-transform: none;';
    return 'text-transform: $transform;';
  },

  // Font Style
  RegExp(r'^(italic|not-italic)$'): (matches) =>
      'font-style: ${matches[0] == 'italic' ? 'italic' : 'normal'};',

  // Letter Spacing
  RegExp(r'^tracking-(tighter|tight|normal|wide|wider|widest)$'): (matches) {
    const trackingMap = {
      'tighter': '-0.05em',
      'tight': '-0.025em',
      'normal': '0em',
      'wide': '0.025em',
      'wider': '0.05em',
      'widest': '0.1em',
    };
    final value = trackingMap[matches[0]];
    if (value == null) return null;
    return 'letter-spacing: $value;';
  },

  // Line Height
  RegExp(r'^leading-(.+)$'): (matches) {
    final valueKey = matches[0];
    final sizeValue = spacingScale[valueKey] ?? // Use constant
        const {
          'none': '1',
          'tight': '1.25',
          'snug': '1.375',
          'normal': '1.5',
          'relaxed': '1.625',
          'loose': '2',
        }[valueKey];
    if (sizeValue == null) return null;
    return 'line-height: $sizeValue;';
  },

  // Vertical Alignment
  RegExp(r'^align-(baseline|top|middle|bottom|text-top|text-bottom)$'):
      (matches) => 'vertical-align: ${matches[0]};',

  // Whitespace
  RegExp(r'^whitespace-(normal|nowrap|pre|pre-line|pre-wrap)$'): (matches) =>
      'white-space: ${matches[0]};',

  // Word Break
  RegExp(r'^break-normal$'): (matches) =>
      'overflow-wrap: normal; word-break: normal;',
  RegExp(r'^break-words$'): (matches) =>
      'overflow-wrap: break-word;', // word-break: break-word is deprecated
  RegExp(r'^break-all$'): (matches) => 'word-break: break-all;',

  // List style none (often used with typography)
  RegExp(r'^list-none$'): (matches) => 'list-style-type: none;',
};
