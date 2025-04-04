// packages/atomic_styles/lib/src/rules.dart
import 'constants.dart';
// Import rule files
import 'rules/spacing.dart';
import 'rules/layout.dart';
import 'rules/flex_grid.dart';
import 'rules/sizing.dart';
import 'rules/typography.dart';
import 'rules/backgrounds.dart';
import 'rules/borders.dart';
import 'rules/effects.dart';
import 'rules/filters.dart';
import 'rules/interactivity.dart';
import 'rules/transforms.dart';
import 'rules/transitions_animation.dart';
import 'rules/svg.dart';
import 'rules/accessibility.dart';

// Map of atomic class prefixes/patterns to CSS generation functions
// Each function takes the matched parts of the class name and returns a CSS rule string (or null if invalid)
// This map is populated by spreading maps from individual rule files.
final Map<RegExp, String? Function(List<String> matches)> atomicRules = {
  // Spread rules from individual files
  ...spacingRules,
  ...layoutRules,
  ...flexGridRules,
  ...sizingRules,
  ...typographyRules,
  ...backgroundRules,
  ...borderRules,
  ...effectRules,
  ...filterRules,
  ...interactivityRules,
  ...transformRules,
  ...transitionsAnimationRules,
  ...svgRules,
  ...accessibilityRules,

  // NOTE: Hover, focus, active etc. require modifying the CssWriterBuilder
  // to generate selectors like `.hover\:text-blue-700:hover`.
  // This is a placeholder for future implementation.
  // RegExp(r'^hover:(.+)$'): (matches) => null, // Mark as handled but generate nothing yet
};

/// Generates CSS rules for a given set of atomic class names.
/// Returns a map where keys are class names and values are CSS rule strings.
Map<String, String> generateAtomicCss(Set<String> classNames) {
  final generatedCss = <String, String>{};

  for (final className in classNames) {
    if (generatedCss.containsKey(className)) {
      continue; // Skip if already generated
    }

    for (final entry in atomicRules.entries) {
      final regex = entry.key;
      final generator = entry.value;
      final match = regex.firstMatch(className);

      if (match != null) {
        // Extract matched groups (group 0 is the full match, group 1+ are capture groups)
        // Ensure matches passed to generator are List<String>
        final matches = List<String>.generate(
            match.groupCount, (i) => match.group(i + 1) ?? '');

        // Individual rule functions should import constants.dart if they need spacingScale or colors
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
