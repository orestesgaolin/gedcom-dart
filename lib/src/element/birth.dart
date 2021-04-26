part of 'element.dart';

/// GEDCOM element consisting of tag [GEDCOM_TAG_BIRTH]
class BirthElement extends GedcomElement {
  /// Constructor of the FileElement
  BirthElement({
    required int level,
    String? pointer,
    String? value,
    List<GedcomElement>? children,
    GedcomElement? parent,
    String? crlf = '\n',
  }) : super(
          level: level,
          tag: GEDCOM_TAG_BIRTH,
          pointer: pointer,
          value: value,
          children: children,
          parent: parent,
          crlf: crlf,
        );

  @override
  String get tag => GEDCOM_TAG_BIRTH;

  DateTime? get date => children.any((e) => e is DateElement)
      ? (children.firstWhere((e) => e is DateElement) as DateElement).date
      : null;

  /// Returns copy of the element
  @override
  BirthElement copyWith({
    int? level,
    String? pointer,
    String? tag,
    String? value,
    List<GedcomElement>? children,
    GedcomElement? parent,
    String? crlf,
  }) {
    return BirthElement(
      level: level ?? this.level,
      pointer: pointer ?? this.pointer,
      value: value ?? this.value,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      crlf: crlf ?? this.crlf,
    );
  }
}
