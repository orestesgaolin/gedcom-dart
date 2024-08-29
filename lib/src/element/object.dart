part of 'element.dart';

/// GEDCOM element consisting of tag `GEDCOM_TAG_OBJECT`
class ObjectElement extends GedcomElement {
  /// Constructor of the FileElement
  ObjectElement({
    required super.level,
    super.pointer,
    super.value,
    super.children,
    super.parent,
    super.crlf,
  }) : super(
          tag: GEDCOM_TAG_OBJECT,
        );

  @override
  String get tag => GEDCOM_TAG_OBJECT;

  /// Returns copy of the element
  @override
  ObjectElement copyWith({
    int? level,
    String? pointer,
    String? tag,
    String? value,
    List<GedcomElement>? children,
    GedcomElement? parent,
    String? crlf,
  }) {
    return ObjectElement(
      level: level ?? this.level,
      pointer: pointer ?? this.pointer,
      value: value ?? this.value,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      crlf: crlf ?? this.crlf,
    );
  }
}
