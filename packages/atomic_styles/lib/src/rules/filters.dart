// packages/atomic_styles/lib/src/rules/filters.dart

final Map<RegExp, String? Function(List<String> matches)> filterRules = {
  // --- Filters ---
  // Note: These often require --tw-filter variables and combining filters,
  // simplified here to set individual filter properties which will overwrite each other.
  // A more robust solution would manage a filter stack.

  // Blur
  RegExp(r'^blur(?:-(sm|md|lg|xl|2xl|3xl))?$'): (matches) {
    final size = matches[0]; // null for default 'blur'
    const blurMap = {
      null: '8px',
      'sm': '4px',
      'md': '12px',
      'lg': '16px',
      'xl': '24px',
      '2xl': '40px',
      '3xl': '64px',
    };
    if (!blurMap.containsKey(size)) return null;
    return 'filter: blur(${blurMap[size]});'; // Simplified
  },
  RegExp(r'^blur-none$'): (matches) => 'filter: blur(0);', // Simplified

  // Brightness
  RegExp(r'^brightness-([0-9]+)$'): (matches) {
    final value = int.tryParse(matches[0]);
    if (value == null || value < 0) return null;
    return 'filter: brightness(${value / 100});'; // Simplified
  },

  // Contrast
  RegExp(r'^contrast-([0-9]+)$'): (matches) {
    final value = int.tryParse(matches[0]);
    if (value == null || value < 0) return null;
    return 'filter: contrast(${value / 100});'; // Simplified
  },

  // Grayscale
  RegExp(r'^grayscale(?:-(0))?$'): (matches) =>
      'filter: grayscale(${matches[0] == '0' ? '0' : '1'});', // Simplified

  // Hue Rotate
  RegExp(r'^(-?)hue-rotate-([0-9]+)$'): (matches) {
    final sign = matches[0] == '-' ? '-' : '';
    final value = int.tryParse(matches[1]);
    if (value == null) return null;
    return 'filter: hue-rotate(${sign}${value}deg);'; // Simplified
  },

  // Invert
  RegExp(r'^invert(?:-(0))?$'): (matches) =>
      'filter: invert(${matches[0] == '0' ? '0' : '1'});', // Simplified

  // Saturate
  RegExp(r'^saturate-([0-9]+)$'): (matches) {
    final value = int.tryParse(matches[0]);
    if (value == null || value < 0) return null;
    return 'filter: saturate(${value / 100});'; // Simplified
  },

  // Sepia
  RegExp(r'^sepia(?:-(0))?$'): (matches) =>
      'filter: sepia(${matches[0] == '0' ? '0' : '1'});', // Simplified
};
