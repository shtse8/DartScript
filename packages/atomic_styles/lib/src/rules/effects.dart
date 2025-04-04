// packages/atomic_styles/lib/src/rules/effects.dart

final Map<RegExp, String? Function(List<String> matches)> effectRules = {
  // --- Effects ---

  // Box Shadow
  RegExp(r'^shadow(?:-(sm|md|lg|xl|2xl|inner|none))?$'): (matches) {
    final size =
        matches[0]; // null for default 'shadow', md is handled here too
    const shadowMap = {
      null:
          '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)', // shadow
      'sm': '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
      'md':
          '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)', // Added md explicitly
      'lg':
          '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
      'xl':
          '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
      '2xl': '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
      'inner': 'inset 0 2px 4px 0 rgba(0, 0, 0, 0.06)',
      'none': 'none',
    };
    if (!shadowMap.containsKey(size)) return null;
    final value = shadowMap[size];
    // Handle none separately for box-shadow property
    if (size == 'none') return 'box-shadow: none;';
    return 'box-shadow: $value;';
  },

  // Opacity
  RegExp(r'^opacity-([0-9]+)$'): (matches) {
    final value = int.tryParse(matches[0]);
    if (value == null || value < 0 || value > 100) return null;
    return 'opacity: ${value / 100};';
  },
};
