part of 'element.dart';

/// GEDCOM element consisting of tag [GEDCOM_TAG_FILE]
class FileElement extends GedcomElement {
  /// Constructor of the FileElement
  FileElement({
    required int level,
    String? pointer,
    String? value,
    List<GedcomElement>? children,
    GedcomElement? parent,
    String? crlf = '\n',
  }) : super(
          level: level,
          tag: GEDCOM_TAG_FILE,
          pointer: pointer,
          value: value,
          children: children,
          parent: parent,
          crlf: crlf,
        );

  @override
  String get tag => GEDCOM_TAG_FILE;

  /// Returns copy of the element
  @override
  FileElement copyWith({
    int? level,
    String? pointer,
    String? tag,
    String? value,
    List<GedcomElement>? children,
    GedcomElement? parent,
    String? crlf,
  }) {
    return FileElement(
      level: level ?? this.level,
      pointer: pointer ?? this.pointer,
      value: value ?? this.value,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      crlf: crlf ?? this.crlf,
    );
  }
}
