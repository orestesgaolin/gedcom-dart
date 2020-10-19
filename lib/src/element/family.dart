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

  /// Returns the husband/father of the family
  ///
  /// Returns null if not found
  IndividualElement getHusband(Map<String, GedcomElement> elementsMap) {
    final husbandId = children.firstWhere(
        (element) => element.tag == GEDCOM_TAG_HUSBAND,
        orElse: () => null);
    if (husbandId != null) {
      final husband = elementsMap[husbandId.value];
      return husband;
    }
    return null;
  }

  /// Returns the wife/mother of the family
  ///
  /// Returns null if not found
  IndividualElement getWife(Map<String, GedcomElement> elementsMap) {
    final wifeId = children.firstWhere(
        (element) => element.tag == GEDCOM_TAG_WIFE,
        orElse: () => null);
    if (wifeId != null) {
      final wife = elementsMap[wifeId.value];
      return wife;
    }
    return null;
  }

  /// Returns the children sorted by the birth year if available
  ///
  /// Returns empty list if no children found
  List<IndividualElement> getChildren(Map<String, GedcomElement> elementsMap) {
    final childrenElements = <IndividualElement>[];
    final childrenIds =
        children.where((element) => element.tag == GEDCOM_TAG_CHILD).toList();
    for (final child in childrenIds) {
      childrenElements.add(elementsMap[child.value]);
    }
    childrenElements.sort();
    return childrenElements;
  }

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
