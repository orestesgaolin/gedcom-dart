// Licensed under the GNU General Public License v2

import 'package:gedcom/src/element/element.dart';

/// Flowchart direction of the rendered Mermaid diagram.
enum MermaidDirection {
  /// Top to bottom.
  topDown('TD'),

  /// Left to right.
  leftRight('LR'),

  /// Bottom to top.
  bottomUp('BT'),

  /// Right to left.
  rightLeft('RL');

  const MermaidDirection(this.code);

  /// Mermaid flowchart direction code (`TD`, `LR`, `BT`, `RL`).
  final String code;
}

/// Shape used to render family union nodes.
enum MermaidFamilyShape {
  /// Hexagon rendered as `{{...}}`.
  hexagon,

  /// Circle rendered as `((...))`.
  circle,

  /// Rectangle rendered as `[...]`.
  rectangle,
}

/// Renders a parsed GEDCOM tree as Mermaid `flowchart` source.
///
/// The output is a self-contained Mermaid diagram where each
/// [IndividualElement] is a labeled node, each [FamilyElement] is a
/// small union node, and edges connect spouses to their family and
/// families to their children.
///
/// ```dart
/// final root = GedcomParser().parse(data);
/// final mermaid = const GedcomMermaidRenderer().render(root);
/// ```
class GedcomMermaidRenderer {
  /// Creates a renderer with the given display options.
  const GedcomMermaidRenderer({
    this.direction = MermaidDirection.topDown,
    this.includeDates = true,
    this.familyShape = MermaidFamilyShape.hexagon,
  });

  /// Flowchart direction. Defaults to [MermaidDirection.topDown].
  final MermaidDirection direction;

  /// When true, birth and death years are appended under each individual.
  final bool includeDates;

  /// Shape used for family union nodes.
  final MermaidFamilyShape familyShape;

  /// Renders [root] as Mermaid `flowchart` source.
  String render(RootElement root) {
    final buffer = StringBuffer()..writeln('flowchart ${direction.code}');

    final byPointer = <String, GedcomElement>{};
    for (final child in root.children) {
      final pointer = child.pointer;
      if (pointer != null && pointer.isNotEmpty) {
        byPointer[pointer] = child;
      }
    }

    for (final individual in byPointer.values.whereType<IndividualElement>()) {
      buffer.writeln('  ${_individualNode(individual)}');
    }

    for (final family in byPointer.values.whereType<FamilyElement>()) {
      final familyPointer = family.pointer;
      if (familyPointer == null || familyPointer.isEmpty) continue;
      final familyId = _safeId(familyPointer);
      buffer.writeln('  ${_familyNode(family, familyId)}');

      for (final child in family.children) {
        final value = child.value;
        if (value == null || value.isEmpty) continue;
        final target = byPointer[value];
        if (target is! IndividualElement) continue;

        final targetId = _safeId(value);
        switch (child.tag) {
          case GEDCOM_TAG_HUSBAND:
          case GEDCOM_TAG_WIFE:
            buffer.writeln('  $targetId --- $familyId');
          case GEDCOM_TAG_CHILD:
            buffer.writeln('  $familyId --> $targetId');
        }
      }
    }

    return buffer.toString().trimRight();
  }

  String _individualNode(IndividualElement individual) {
    final pointer = individual.pointer;
    if (pointer == null || pointer.isEmpty) return '';
    final id = _safeId(pointer);
    return '$id["${_individualLabel(individual)}"]';
  }

  String _individualLabel(IndividualElement individual) {
    final name = individual.name;
    final given = (name.givenName ?? '').trim();
    final surname = (name.surname ?? '').trim();
    final fullName = [given, surname].where((s) => s.isNotEmpty).join(' ');
    final displayName =
        fullName.isEmpty ? (individual.pointer ?? '?') : fullName;

    final buffer = StringBuffer(_escape(displayName));
    if (includeDates) {
      final birth = individual.birthDate?.year;
      final death = individual.deathDate?.year;
      if (birth != null || death != null) {
        buffer
          ..write('<br/>')
          ..write(birth?.toString() ?? '?')
          ..write('–')
          ..write(death?.toString() ?? '');
      }
    }
    return buffer.toString();
  }

  String _familyNode(FamilyElement family, String id) {
    final label = _escape(family.pointer ?? id);
    switch (familyShape) {
      case MermaidFamilyShape.hexagon:
        return '$id{{"$label"}}';
      case MermaidFamilyShape.circle:
        return '$id(("$label"))';
      case MermaidFamilyShape.rectangle:
        return '$id["$label"]';
    }
  }

  String _safeId(String pointer) {
    final sanitized =
        pointer.replaceAll('@', '').replaceAll(RegExp('[^A-Za-z0-9_]'), '_');
    return sanitized.isEmpty ? 'N' : sanitized;
  }

  String _escape(String input) =>
      input.replaceAll('"', r'\"').replaceAll('\n', ' ');
}
