part of 'element.dart';

/// GEDCOM element consisting of tag [GEDCOM_TAG_DEATH]
class DeathElement extends GedcomElement {
  /// Constructor of the FileElement
  DeathElement({
    required super.level,
    super.pointer,
    super.value,
    super.children,
    super.parent,
    super.crlf,
  }) : super(
          tag: GEDCOM_TAG_DEATH,
        );

  @override
  String get tag => GEDCOM_TAG_DEATH;

  DateTime? get date => children.any((e) => e is DateElement)
      ? (children.firstWhere((e) => e is DateElement) as DateElement).date
      : null;

  /// Returns copy of the element
  @override
  DeathElement copyWith({
    int? level,
    String? pointer,
    String? tag,
    String? value,
    List<GedcomElement>? children,
    GedcomElement? parent,
    String? crlf,
  }) {
    return DeathElement(
      level: level ?? this.level,
      pointer: pointer ?? this.pointer,
      value: value ?? this.value,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      crlf: crlf ?? this.crlf,
    );
  }
}
