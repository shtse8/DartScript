import 'dart:async';
import 'package:build/build.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class AtomicStyleBuilder implements Builder {
  // No static state needed anymore
  @override
  final buildExtensions = const {
    '.dart': [
      '.classes'
    ] // Output file containing found class names for this input
  };

  // No instance state needed anymore

  @override
  Future<void> build(BuildStep buildStep) async {
    // Only process dart files
    if (!buildStep.inputId.path.endsWith('.dart')) {
      return;
    }
    // Removed static reset logic

    final inputId = buildStep.inputId;
    final content = await buildStep.readAsString(inputId);

    try {
      final parseResult =
          parseString(content: content, throwIfDiagnostics: false);
      if (parseResult.errors.isNotEmpty) {
        log.warning(
            'Skipping ${inputId.path} due to parsing errors: ${parseResult.errors}');
        return;
      }

      final visitor = _ClassNameVisitor();
      parseResult.unit.accept(visitor);
      // Process only the classes found in the current file
      final currentFileClasses = visitor.foundClassNames;
      // No need to add to any global/static set here

      // Generate CSS only for the classes found in this specific file.
      // The PostProcessBuilder will handle aggregation later.

      // Write the found class names (one per line) to the .classes file
      final outputId = inputId.changeExtension('.classes');
      // Sort classes for consistent output in the .classes file
      final sortedClasses = currentFileClasses.toList()..sort();
      final outputContent = sortedClasses.join('\n');
      // Always write the output, build_runner should handle overwrites if content is same.
      await buildStep.writeAsString(outputId, outputContent);
      if (currentFileClasses.isNotEmpty) {
        print(
            "AtomicStyleBuilder: Found ${currentFileClasses.length} classes in ${inputId.path}, wrote to ${outputId.path}");
      } else {
        // If no classes found, still write an empty file
        print(
            "AtomicStyleBuilder: No classes found in ${inputId.path}, wrote empty file to ${outputId.path}");
      }
    } catch (e, s) {
      log.severe('Error processing ${inputId.path}: $e\n$s');
    }
  }
}

// AST Visitor to find 'class' attributes within HTML helper function calls
class _ClassNameVisitor extends RecursiveAstVisitor<void> {
  final Set<String> foundClassNames = {};

  // TODO: Make this list configurable or more robust
  final Set<String> htmlHelperFunctionNames = {
    'div', 'span', 'p', 'h1', 'h2', 'h3', 'ul', 'li', 'button', 'input',
    // Add other helper function names here
  };

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node); // Visit children first

    final functionName = node.methodName.name;

    // Check if it's one of our HTML helper functions
    if (htmlHelperFunctionNames.contains(functionName)) {
      // Find the 'attributes' named argument by iterating
      NamedExpression? attributesArg;
      for (final arg in node.argumentList.arguments) {
        if (arg is NamedExpression && arg.name.label.name == 'attributes') {
          attributesArg = arg;
          break;
        }
      }

      // Check if attributesArg was found and is a map literal
      if (attributesArg != null &&
          attributesArg.expression is SetOrMapLiteral) {
        final mapLiteral = attributesArg.expression as SetOrMapLiteral;
        // Find the 'class' entry within the map literal
        for (final element in mapLiteral.elements) {
          if (element is MapLiteralEntry) {
            final key = element.key;
            final value = element.value;
            // Check if the key is a string literal 'class'
            if (key is SimpleStringLiteral &&
                key.value == 'class' &&
                value is SimpleStringLiteral) {
              // Extract class names from the string value
              final classString = value.value;
              final classes = classString.split(' ').where((c) => c.isNotEmpty);
              foundClassNames.addAll(classes);
              print(
                  "AtomicStyleBuilder Visitor: Found classes: $classes in ${node.methodName}");
            }
          }
        }
      }
    }
  }
}
