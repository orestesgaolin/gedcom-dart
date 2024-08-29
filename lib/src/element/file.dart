part of 'element.dart';

/// GEDCOM element consisting of tag [GEDCOM_TAG_FILE]
class FileElement extends GedcomElement {
  /// Constructor of the FileElement
  FileElement({
    required super.level,
    super.pointer,
    super.value,
    super.children,
    super.parent,
    super.crlf,
  }) : super(
          tag: GEDCOM_TAG_FILE,
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
