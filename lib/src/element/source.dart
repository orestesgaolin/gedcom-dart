part of 'element.dart';

class SourceElement extends GedcomElement {
  SourceElement({
    required super.level,
    super.pointer,
    super.value,
    super.children,
    super.parent,
    super.crlf,
  }) : super(
          tag: GEDCOM_TAG_SOURCE,
        );

  @override
  SourceElement copyWith({
    int? level,
    String? pointer,
    String? tag,
    String? value,
    List<GedcomElement>? children,
    GedcomElement? parent,
    String? crlf,
  }) {
    return SourceElement(
      level: level ?? this.level,
      pointer: pointer ?? this.pointer,
      value: value ?? this.value,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      crlf: crlf ?? this.crlf,
    );
  }
}
