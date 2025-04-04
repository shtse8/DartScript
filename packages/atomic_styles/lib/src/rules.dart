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
const Map<String, String> _colors = {
  'red-500': '#ef4444',
  'green-500': '#22c55e',
  'blue-500': '#3b82f6',
  'gray-500': '#6b7280',
  'gray-800': '#1f2937',
  'white': '#ffffff',
  'black': '#000000',
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

  // Add more rules here (e.g., background color, display, flex, grid, etc.)
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
