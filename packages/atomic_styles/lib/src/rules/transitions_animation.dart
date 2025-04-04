// packages/atomic_styles/lib/src/rules/transitions_animation.dart

final Map<RegExp, String? Function(List<String> matches)>
    transitionsAnimationRules = {
  // --- Transitions ---

  // Transition Property (includes 'all' from original rules)
  RegExp(r'^transition(?:-(all|colors|opacity|shadow|transform|none))?$'):
      (matches) {
    final property = matches[0]; // Can be null for default 'transition'
    // Default timing and function, can be customized later
    // Ensure property is 'all' if null or empty after match
    final validProperty = (property == null ||
            property.isEmpty ||
            property == 'all')
        ? 'color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter' // Tailwind's default 'all'
        : property == 'none'
            ? 'none'
            : property; // colors, opacity, shadow, transform

    // Apply default timing and duration if a property is specified
    if (validProperty != 'none') {
      return 'transition-property: $validProperty; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); transition-duration: 150ms;';
    } else {
      return 'transition-property: none;'; // Handle transition-none
    }
  },

  // Transition Duration
  RegExp(r'^duration-([0-9]+)$'): (matches) =>
      'transition-duration: ${matches[0]}ms;',

  // Transition Delay
  RegExp(r'^delay-([0-9]+)$'): (matches) =>
      'transition-delay: ${matches[0]}ms;',

  // Transition Timing Function
  RegExp(r'^ease-(linear|in|out|in-out)$'): (matches) {
    const timingMap = {
      'linear': 'linear',
      'in': 'cubic-bezier(0.4, 0, 1, 1)',
      'out': 'cubic-bezier(0, 0, 0.2, 1)',
      'in-out': 'cubic-bezier(0.4, 0, 0.2, 1)', // Default Tailwind ease
    };
    final timingValue = timingMap[matches[0]];
    if (timingValue == null) return null;
    return 'transition-timing-function: $timingValue;';
  },

  // --- Animations ---
  // Note: Requires corresponding @keyframes definitions in your CSS.

  RegExp(r'^animate-(spin|ping|pulse|bounce|none)$'): (matches) {
    final animation = matches[0];
    if (animation == 'none') return 'animation: none;';
    // Keyframes need to be defined elsewhere (e.g., in the main CSS file)
    const animationMap = {
      'spin': 'spin 1s linear infinite',
      'ping': 'ping 1s cubic-bezier(0, 0, 0.2, 1) infinite',
      'pulse': 'pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      'bounce': 'bounce 1s infinite',
    };
    final animationValue = animationMap[animation];
    if (animationValue == null) return null;
    return 'animation: $animationValue;';
  },
};
