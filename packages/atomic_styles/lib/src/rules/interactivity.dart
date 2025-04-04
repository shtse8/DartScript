// packages/atomic_styles/lib/src/rules/interactivity.dart

final Map<RegExp, String? Function(List<String> matches)> interactivityRules = {
  // --- Interactivity ---

  // Appearance
  RegExp(r'^appearance-none$'): (matches) => 'appearance: none;',

  // Cursor (includes pointer from original rules)
  RegExp(r'^cursor-(pointer|default|wait|text|move|not-allowed|auto)$'):
      (matches) => 'cursor: ${matches[0]};',

  // User Select
  RegExp(r'^select-(none|text|all|auto)$'): (matches) =>
      'user-select: ${matches[0]};',
};
