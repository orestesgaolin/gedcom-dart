part of 'element.dart';

/// GEDCOM element consisting of tag [GEDCOM_TAG_INDIVIDUAL]
class IndividualElement extends GedcomElement
    implements Comparable<IndividualElement> {
  /// Constructor of the FileElement
  IndividualElement({
    required super.level,
    super.pointer,
    super.value,
    super.children,
    super.parent,
    super.crlf,
  }) : super(
          tag: GEDCOM_TAG_INDIVIDUAL,
        );

  /// Checks if this individual is deceased
  bool get isDeceased =>
      children.any((element) => element.tag == GEDCOM_TAG_DEATH);

  /// Checks if this individual is child of a family
  bool get isChild =>
      children.any((element) => element.tag == GEDCOM_TAG_FAMILY_CHILD);

  /// Checks if this individual is a spouse/has a family
  bool get isSpouse =>
      children.any((element) => element.tag == GEDCOM_TAG_FAMILY_SPOUSE);

  /// Returns pointer value of the family where individual
  /// is wife or husband. Returns null if not available.
  String? get spouseFamily => isSpouse
      ? children
          .firstWhere((element) => element.tag == GEDCOM_TAG_FAMILY_SPOUSE)
          .value
      : null;

  /// Checks if this individual is marked private
  bool get isPrivate => children.any(
        (element) => element.tag == GEDCOM_TAG_PRIVATE && element.value == 'Y',
      );

  /// Returns individual's birth date. Returns null if not available.
  DateTime? get birthDate => children.any((e) => e is BirthElement)
      ? (children.firstWhere((e) => e is BirthElement) as BirthElement).date
      : null;

  /// Returns individual's death date if deceased. Returns null if not available.
  DateTime? get deathDate => isDeceased
      ? (children.firstWhere((e) => e is DeathElement) as DeathElement).date
      : null;

  /// Returns an individual's name as [Name]
  Name get name {
    String? givenName;
    String? surname;

    var foundGivenName = false;
    var foundSurname = false;

    for (final child in children) {
      if (child.tag == GEDCOM_TAG_NAME) {
        // Some GEDCOM files don't use child tags but instead
        // place the name in the value of the NAME tag.
        if (child.value != '') {
          final name = child.value!.split('/');
          if (name.isNotEmpty) {
            givenName = name[0].trim();
            if (name.length > 1) {
              surname = name[1].trim();
            }
          }
          return Name(givenName: givenName, surname: surname);
        }

        for (final childOfChild in child.children) {
          if (childOfChild.tag == GEDCOM_TAG_GIVEN_NAME) {
            givenName = childOfChild.value;
            foundGivenName = true;
          }
          if (childOfChild.tag == GEDCOM_TAG_SURNAME) {
            surname = childOfChild.value;
            foundSurname = true;
          }
        }
      }
      if (foundSurname && foundGivenName) {
        return Name(givenName: givenName, surname: surname);
      }
    }
    // If we reach here we are probably returning empty strings
    return Name.empty;
  }

  /// Returns copy of the element
  @override
  IndividualElement copyWith({
    int? level,
    String? pointer,
    String? tag,
    String? value,
    List<GedcomElement>? children,
    GedcomElement? parent,
    String? crlf,
  }) {
    return IndividualElement(
      level: level ?? this.level,
      pointer: pointer ?? this.pointer,
      value: value ?? this.value,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      crlf: crlf ?? this.crlf,
    );
  }

  @override
  int compareTo(IndividualElement other) {
    if (birthDate == null) {
      return -1;
    }
    if (other.birthDate == null) {
      return 1;
    }

    final value = birthDate!.compareTo(other.birthDate!);
    if (value == 0) {
      return other.name.compareTo(other.name);
    }
    return value;
  }
}
