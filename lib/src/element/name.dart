part of 'element.dart';

/// Represents name of an individual
@immutable
class Name implements Comparable<Name> {
  /// Constructor of the Name class
  Name({
    required this.givenName,
    required this.surname,
  });

  /// Given name (first name) of the individual
  final String? givenName;

  /// Surname (last name) of the individual
  final String? surname;

  // ignore: public_member_api_docs
  Name copyWith({
    String? givenName,
    String? surname,
  }) {
    return Name(
      givenName: givenName ?? this.givenName,
      surname: surname ?? this.surname,
    );
  }

  // ignore: public_member_api_docs
  Map<String, dynamic> toMap() {
    return {
      'givenName': givenName,
      'surname': surname,
    };
  }

  static final empty = Name(givenName: '', surname: '');

  // ignore: public_member_api_docs
  factory Name.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Name.empty;

    return Name(
      givenName: map['givenName'],
      surname: map['surname'],
    );
  }

  // ignore: public_member_api_docs
  String toJson() => json.encode(toMap());

  // ignore: public_member_api_docs
  factory Name.fromJson(String source) => Name.fromMap(json.decode(source));

  @override
  String toString() => '$surname $givenName';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Name && o.givenName == givenName && o.surname == surname;
  }

  @override
  int get hashCode => givenName.hashCode ^ surname.hashCode;

  @override
  int compareTo(Name other) {
    return toString().compareTo(other.toString());
  }
}
