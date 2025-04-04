// packages/atomic_styles/lib/src/rules/sizing.dart
import '../constants.dart'; // Import constants

final Map<RegExp, String? Function(List<String> matches)> sizingRules = {
  // --- Sizing ---

  // Width & Height (using spacing scale + screen/full/min/max/fit)
  RegExp(r'^w-(.+)$'): (matches) {
    final valueKey = matches[0];
    final sizeValue = spacingScale[valueKey] ??
        const {
          // Use const map for keywords
          'screen': '100vw',
          'min': 'min-content',
          'max': 'max-content',
          'fit': 'fit-content',
        }[valueKey];
    if (sizeValue == null) return null;
    return 'width: $sizeValue;';
  },
  RegExp(r'^h-(.+)$'): (matches) {
    final valueKey = matches[0];
    final sizeValue = spacingScale[valueKey] ??
        const {
          // Use const map for keywords
          'screen': '100vh',
          'min': 'min-content',
          'max': 'max-content',
          'fit': 'fit-content',
        }[valueKey];
    if (sizeValue == null) return null;
    return 'height: $sizeValue;';
  },

  // Max Width (using spacing scale + specific keywords/sizes)
  RegExp(r'^max-w-(.+)$'): (matches) {
    final valueKey = matches[0];
    final sizeValue = spacingScale[valueKey] ??
        const {
          '0': '0rem',
          'none': 'none',
          'xs': '20rem',
          'sm': '24rem',
          'md': '28rem',
          'lg': '32rem',
          'xl': '36rem',
          '2xl': '42rem',
          '3xl': '48rem',
          '4xl': '56rem',
          '5xl': '64rem',
          '6xl': '72rem',
          '7xl': '80rem',
          'full':
              '100%', // Already in spacingScale, but good to have here for clarity
          'min': 'min-content',
          'max': 'max-content',
          'fit': 'fit-content',
          'prose': '65ch',
          'screen-sm': '640px',
          'screen-md': '768px',
          'screen-lg': '1024px',
          'screen-xl': '1280px',
          'screen-2xl': '1536px',
        }[valueKey];
    if (sizeValue == null) return null;
    return 'max-width: $sizeValue;';
  },

  // Min Width (using spacing scale + specific keywords)
  RegExp(r'^min-w-(.+)$'): (matches) {
    final valueKey = matches[0];
    final sizeValue = spacingScale[valueKey] ??
        const {
          '0': '0px', // Use px for zero
          'full': '100%', // Already in spacingScale
          'min': 'min-content',
          'max': 'max-content',
          'fit': 'fit-content',
        }[valueKey];
    if (sizeValue == null) return null;
    return 'min-width: $sizeValue;';
  },

  // Max Height (using spacing scale + specific keywords)
  RegExp(r'^max-h-(.+)$'): (matches) {
    final valueKey = matches[0];
    final sizeValue = spacingScale[valueKey] ??
        const {
          '0': '0px',
          'full': '100%', // Already in spacingScale
          'screen': '100vh',
          'min': 'min-content',
          'max': 'max-content',
          'fit': 'fit-content',
        }[valueKey];
    if (sizeValue == null) return null;
    return 'max-height: $sizeValue;';
  },

  // Min Height (using spacing scale + specific keywords)
  RegExp(r'^min-h-(.+)$'): (matches) {
    final valueKey = matches[0];
    final sizeValue = spacingScale[valueKey] ??
        const {
          '0': '0px',
          'full': '100%', // Already in spacingScale
          'screen': '100vh',
          'min': 'min-content',
          'max': 'max-content',
          'fit': 'fit-content',
        }[valueKey];
    if (sizeValue == null) return null;
    return 'min-height: $sizeValue;';
  },
};
