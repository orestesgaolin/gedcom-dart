part of 'element.dart';

/// GEDCOM element consisting of tag `GEDCOM_TAG_FAMILY`
class FamilyElement extends GedcomElement {
  /// Constructor of the FamilyElement
  FamilyElement({
    @required int level,
    String pointer,
    String value,
    List<GedcomElement> children,
    GedcomElement parent,
    String crlf = '\n',
  })  : assert(level != null, 'Level is required'),
        super(
          level: level,
          tag: GEDCOM_TAG_FAMILY,
          pointer: pointer,
          value: value,
          children: children,
          parent: parent,
          crlf: crlf,
        );

  @override
  String get tag => GEDCOM_TAG_FAMILY;

  /// Returns copy of the element
  @override
  FamilyElement copyWith({
    int level,
    String pointer,
    String tag,
    String value,
    List<GedcomElement> children,
    GedcomElement parent,
    String crlf,
  }) {
    return FamilyElement(
      level: level ?? this.level,
      pointer: pointer ?? this.pointer,
      value: value ?? this.value,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      crlf: crlf ?? this.crlf,
    );
  }
}
