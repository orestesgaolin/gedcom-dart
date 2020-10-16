part of 'element.dart';

/// GEDCOM element consisting of tag `GEDCOM_TAG_OBJECT`
class ObjectElement extends GedcomElement {
  /// Constructor of the FileElement
  ObjectElement({
    @required int level,
    String pointer,
    String value,
    List<GedcomElement> children,
    GedcomElement parent,
    String crlf = '\n',
  })  : assert(level != null, 'Level is required'),
        super(
          level: level,
          tag: GEDCOM_TAG_OBJECT,
          pointer: pointer,
          value: value,
          children: children,
          parent: parent,
          crlf: crlf,
        );

  @override
  String get tag => GEDCOM_TAG_OBJECT;

  /// Returns copy of the element
  @override
  ObjectElement copyWith({
    int level,
    String pointer,
    String tag,
    String value,
    List<GedcomElement> children,
    GedcomElement parent,
    String crlf,
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
