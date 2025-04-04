// packages/atomic_styles/lib/src/rules.dart

// Basic scale for spacing (can be expanded)
const Map<String, String> _spacingScale = {
  '0': '0',
  '1': '0.25rem', // 4px
  '2': '0.5rem', // 8px
  '3': '0.75rem', // 12px
  '4': '1rem', // 16px
  '5': '1.25rem', // 20px
  '6': '1.5rem', // 24px
  '8': '2rem', // 32px
  '10': '2.5rem', // 40px
  '12': '3rem', // 48px
  'px': '1px',
  // Add more as needed
};

// Basic color palette (Tailwind inspired, can be expanded)
// Expanded color palette (Tailwind inspired)
const Map<String, String> _colors = {
  'transparent': 'transparent',
  'current': 'currentColor',
  'black': '#000000',
  'white': '#ffffff',
  'gray-50': '#f9fafb', // Added lighter gray
  'gray-100': '#f3f4f6',
  'gray-200': '#e5e7eb',
  'gray-300': '#d1d5db',
  'gray-400': '#9ca3af',
  'gray-500': '#6b7280',
  'gray-600': '#4b5563',
  'gray-700': '#374151',
  'gray-800': '#1f2937',
  'gray-900': '#111827',
  'red-100': '#fee2e2', // Added hover/lighter shade
  'red-500': '#ef4444',
  'red-600': '#dc2626',
  'red-700': '#b91c1c', // Added hover/darker shade
  'yellow-500': '#eab308',
  'green-100': '#dcfce7', // Added hover/lighter shade
  'green-500': '#22c55e',
  'green-600': '#16a34a',
  'green-700': '#15803d', // Added hover/darker shade
  'blue-100': '#dbeafe', // Added hover/lighter shade
  'blue-500': '#3b82f6',
  'blue-600': '#2563eb',
  'blue-700': '#1d4ed8', // Added hover/darker shade
  'indigo-100': '#e0e7ff', // Added hover/lighter shade
  'indigo-500': '#6366f1',
  'indigo-600': '#4f46e5', // Added hover/darker shade
  'purple-500': '#a855f7',
  'pink-500': '#ec4899',
  // Add more shades and colors as needed
};

// Map of atomic class prefixes/patterns to CSS generation functions
// Each function takes the matched parts of the class name and returns a CSS rule string (or null if invalid)
final Map<RegExp, String? Function(List<String> matches)> atomicRules = {
  // Margin: m-{value}, mx-{value}, my-{value}, mt-{value}, mr-{value}, mb-{value}, ml-{value}
  RegExp(r'^(m|mx|my|mt|mr|mb|ml)-(.+)$'): (matches) {
    final type = matches[0]; // m, mx, my, mt, mr, mb, ml
    final valueKey = matches[
        1]; // e.g., '4', 'px', 'auto' (auto needs special handling if added)
    final spacingValue = _spacingScale[valueKey];
    if (spacingValue == null) return null; // Invalid value

    switch (type) {
      case 'm':
        return 'margin: $spacingValue;';
      case 'mx':
        return 'margin-left: $spacingValue; margin-right: $spacingValue;';
      case 'my':
        return 'margin-top: $spacingValue; margin-bottom: $spacingValue;';
      case 'mt':
        return 'margin-top: $spacingValue;';
      case 'mr':
        return 'margin-right: $spacingValue;';
      case 'mb':
        return 'margin-bottom: $spacingValue;';
      case 'ml':
        return 'margin-left: $spacingValue;';
      default:
        return null;
    }
  },

  // Padding: p-{value}, px-{value}, py-{value}, pt-{value}, pr-{value}, pb-{value}, pl-{value}
  RegExp(r'^(p|px|py|pt|pr|pb|pl)-(.+)$'): (matches) {
    final type = matches[0]; // p, px, py, pt, pr, pb, pl
    final valueKey = matches[1]; // e.g., '4', 'px'
    final spacingValue = _spacingScale[valueKey];
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

  // Text Color: text-{color}-{shade} or text-{color}
  RegExp(r'^text-(.+)$'): (matches) {
    final colorKey = matches[0]; // e.g., 'red-500', 'white'
    final colorValue = _colors[colorKey];
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

  // Background Color: bg-{color}-{shade} or bg-{color}
  RegExp(r'^bg-(.+)$'): (matches) {
    final colorKey = matches[0];
    final colorValue = _colors[colorKey];
    if (colorValue == null) return null;
    return 'background-color: $colorValue;';
  },

  // Border Radius: rounded, rounded-{sm|md|lg|full}
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
  RegExp(r'^border(?:-([0-9]+))?$'): (matches) {
    final valueKey = matches[0]; // Can be null for just 'border'
    final width = (valueKey == null || valueKey.isEmpty)
        ? '1px'
        : '${valueKey}px'; // Default to 1px explicitly
    // Basic border style, can be expanded
    return 'border-width: $width; border-style: solid; border-color: currentColor;'; // Default color
  },

  // Border Color: border-{color}-{shade} or border-{color}
  RegExp(r'^border-(.+)$'): (matches) {
    // Check if it's not a border width first (e.g., border-2)
    if (RegExp(r'^[0-9]+$').hasMatch(matches[0])) return null;

    final colorKey = matches[0];
    final colorValue = _colors[colorKey];
    if (colorValue == null) return null;
    // Set border-color, assumes border-width and style are set elsewhere (e.g., by 'border')
    return 'border-color: $colorValue;';
  },

  // Display: block, inline-block, inline, flex, grid, hidden
  RegExp(r'^(block|inline-block|inline|flex|grid|hidden)$'): (matches) {
    final displayValue = matches[0];
    if (displayValue == 'hidden') return 'display: none;';
    return 'display: $displayValue;';
  },

  // Flexbox: items-start, items-end, items-center, items-baseline, items-stretch
  RegExp(r'^items-(start|end|center|baseline|stretch)$'): (matches) {
    final alignValue = matches[0] == 'start'
        ? 'flex-start'
        : (matches[0] == 'end' ? 'flex-end' : matches[0]);
    return 'align-items: $alignValue;';
  },

  // Flexbox: justify-start, justify-end, justify-center, justify-between, justify-around, justify-evenly
  RegExp(r'^justify-(start|end|center|between|around|evenly)$'): (matches) {
    final keyword = matches[0];
    final justifyValue = keyword == 'start'
        ? 'flex-start'
        : keyword == 'end'
            ? 'flex-end'
            : keyword == 'between'
                ? 'space-between' // Correct value
                : keyword == 'around'
                    ? 'space-around' // Correct value
                    : keyword; // center, evenly remain the same
    return 'justify-content: $justifyValue;';
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

  // Basic Opacity
  RegExp(r'^opacity-([0-9]+)$'): (matches) {
    final value = int.tryParse(matches[0]);
    if (value == null || value < 0 || value > 100) return null;
    return 'opacity: ${value / 100};';
  },

  // Basic Transitions (can be expanded)
  RegExp(r'^transition(?:-(all|colors|opacity|shadow|transform))?$'):
      (matches) {
    final property = matches[0]; // Can be null
    // Default timing and function, can be customized later
    // Ensure property is 'all' if null or empty after match
    final validProperty =
        (property == null || property.isEmpty) ? 'all' : property;
    return 'transition-property: $validProperty; transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1); transition-duration: 150ms;';
  },

  // Cursor pointer
  RegExp(r'^cursor-pointer$'): (matches) => 'cursor: pointer;',

  // List style none
  RegExp(r'^list-none$'): (matches) => 'list-style-type: none;',

  // Max Width (example, needs more sizes)
  RegExp(r'^max-w-md$'): (matches) => 'max-width: 28rem;', // 448px

  // Margin Auto (for centering)
  RegExp(r'^mx-auto$'): (matches) => 'margin-left: auto; margin-right: auto;',

  // Space Between (for flex children, basic x-axis)
  RegExp(r'^space-x-([0-9]+)$'): (matches) {
    final valueKey = matches[0];
    final spacingValue = _spacingScale[valueKey];
    if (spacingValue == null) return null;
    // Uses the lobotomized owl selector, works for direct children
    return '> * + * { margin-left: $spacingValue; }';
  },
  RegExp(r'^space-y-([0-9]+)$'): (matches) {
    final valueKey = matches[0];
    final spacingValue = _spacingScale[valueKey];
    if (spacingValue == null) return null;
    return '> * + * { margin-top: $spacingValue; }';
  },

  // Basic Shadow (example)
  RegExp(r'^shadow-md$'): (matches) =>
      'box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);',

  // Line Through
  RegExp(r'^line-through$'): (matches) => 'text-decoration-line: line-through;',

  // NOTE: Hover, focus, active etc. require modifying the CssWriterBuilder
  // to generate selectors like `.hover\:text-blue-700:hover`.
  // This is a placeholder for future implementation.
  // RegExp(r'^hover:(.+)$'): (matches) => null, // Mark as handled but generate nothing yet

  // Add more rules here
  // RegExp(r'^hover:(.+)$'): (matches) => handleHover(matches[0]),

  // Add more rules here
};

/// Generates CSS rules for a given set of atomic class names.
/// Returns a map where keys are class names and values are CSS rule strings.
Map<String, String> generateAtomicCss(Set<String> classNames) {
  final generatedCss = <String, String>{};

  for (final className in classNames) {
    if (generatedCss.containsKey(className))
      continue; // Skip if already generated

    for (final entry in atomicRules.entries) {
      final regex = entry.key;
      final generator = entry.value;
      final match = regex.firstMatch(className);

      if (match != null) {
        // Extract matched groups (group 0 is the full match, group 1+ are capture groups)
        final matches =
            List.generate(match.groupCount, (i) => match.group(i + 1) ?? '');
        final cssRule = generator(matches);
        if (cssRule != null) {
          generatedCss[className] = cssRule;
          break; // Found a matching rule, move to the next class name
        }
      }
    }
  }
  return generatedCss;
}
