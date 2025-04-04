// packages/atomic_styles/lib/src/rules/flex_grid.dart
import '../constants.dart'; // Import constants

final Map<RegExp, String? Function(List<String> matches)> flexGridRules = {
  // --- Flexbox ---

  // Flex Direction
  RegExp(r'^flex-(row|col|row-reverse|col-reverse)$'): (matches) =>
      'flex-direction: ${matches[0]};',

  // Flex Wrap
  RegExp(r'^flex-(wrap|nowrap|wrap-reverse)$'): (matches) =>
      'flex-wrap: ${matches[0]};',

  // Flex Grow / Shrink
  RegExp(r'^grow(?:-(0))?$'): (matches) => 'flex-grow: ${matches[0] ?? '1'};',
  RegExp(r'^shrink(?:-(0))?$'): (matches) =>
      'flex-shrink: ${matches[0] ?? '1'};',

  // Flex Basis (Simplified - using spacing scale)
  RegExp(r'^basis-(.+)$'): (matches) {
    final valueKey = matches[0];
    final basisValue = spacingScale[valueKey]; // Use constant
    if (basisValue == null) return null;
    return 'flex-basis: $basisValue;';
  },

  // Flex (Combined property)
  RegExp(r'^flex-1$'): (matches) => 'flex: 1 1 0%;',
  RegExp(r'^flex-auto$'): (matches) => 'flex: 1 1 auto;',
  RegExp(r'^flex-initial$'): (matches) => 'flex: 0 1 auto;',
  RegExp(r'^flex-none$'): (matches) => 'flex: none;',

  // Align Items
  RegExp(r'^items-(start|end|center|baseline|stretch)$'): (matches) {
    final alignValue = matches[0] == 'start'
        ? 'flex-start'
        : (matches[0] == 'end' ? 'flex-end' : matches[0]);
    return 'align-items: $alignValue;';
  },

  // Justify Content
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

  // --- Grid ---

  // Grid Template Columns
  RegExp(r'^grid-cols-([0-9]+)$'): (matches) =>
      'grid-template-columns: repeat(${matches[0]}, minmax(0, 1fr));',
  RegExp(r'^grid-cols-none$'): (matches) => 'grid-template-columns: none;',

  // Grid Column Start / End
  RegExp(r'^col-start-([0-9]+|auto)$'): (matches) =>
      'grid-column-start: ${matches[0]};',
  RegExp(r'^col-end-([0-9]+|auto)$'): (matches) =>
      'grid-column-end: ${matches[0]};',

  // Grid Column Span
  RegExp(r'^col-span-([0-9]+)$'): (matches) =>
      'grid-column: span ${matches[0]} / span ${matches[0]};',
  RegExp(r'^col-span-full$'): (matches) => 'grid-column: 1 / -1;',

  // Grid Template Rows
  RegExp(r'^grid-rows-([0-9]+)$'): (matches) =>
      'grid-template-rows: repeat(${matches[0]}, minmax(0, 1fr));',
  RegExp(r'^grid-rows-none$'): (matches) => 'grid-template-rows: none;',

  // Grid Row Start / End
  RegExp(r'^row-start-([0-9]+|auto)$'): (matches) =>
      'grid-row-start: ${matches[0]};',
  RegExp(r'^row-end-([0-9]+|auto)$'): (matches) =>
      'grid-row-end: ${matches[0]};',

  // Grid Row Span
  RegExp(r'^row-span-([0-9]+)$'): (matches) =>
      'grid-row: span ${matches[0]} / span ${matches[0]};',
  RegExp(r'^row-span-full$'): (matches) => 'grid-row: 1 / -1;',

  // Grid Auto Flow
  RegExp(r'^grid-flow-(row|col|row-dense|col-dense)$'): (matches) =>
      'grid-auto-flow: ${matches[0].replaceFirst('-', ' ')};', // col-dense -> col dense
};
