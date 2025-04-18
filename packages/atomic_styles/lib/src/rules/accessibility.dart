// packages/atomic_styles/lib/src/rules/accessibility.dart

final Map<RegExp, String? Function(List<String> matches)> accessibilityRules = {
  // --- Accessibility ---

  // Screen Reader Only
  RegExp(r'^sr-only$'): (matches) =>
      'position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0, 0, 0, 0); white-space: nowrap; border-width: 0;',
  RegExp(r'^not-sr-only$'): (matches) =>
      'position: static; width: auto; height: auto; padding: 0; margin: 0; overflow: visible; clip: auto; white-space: normal;',
};
