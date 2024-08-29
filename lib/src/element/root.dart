part of 'element.dart';

/// Virtual GEDCOM root element containing all logical records as children
class RootElement extends GedcomElement {
  /// Constructor of the FamilyElement
  RootElement({
    super.children,
    super.crlf,
  }) : super(
          level: -1,
          tag: 'ROOT',
          pointer: '',
          value: '',
          parent: null,
        );

  @override
  String get tag => 'ROOT';

  /// Returns copy of the element
  @override
  RootElement copyWith({
    int? level,
    String? pointer,
    String? tag,
    String? value,
    List<GedcomElement>? children,
    GedcomElement? parent,
    String? crlf,
  }) {
    assert(level == null, 'Cannot set level on RootElement');
    assert(pointer == null, 'Cannot set pointer on RootElement');
    assert(value == null, 'Cannot set value on RootElement');
    assert(parent == null, 'Cannot set parent on RootElement');
    return RootElement(
      children: children ?? this.children,
      crlf: crlf ?? this.crlf,
    );
  }
}
