part of 'element.dart';

/// Represents name of an individual
@immutable
class Name implements Comparable<Name> {
  /// Constructor of the Name class
  const Name({
    required this.givenName,
    required this.surname,
  });

  // ignore: public_member_api_docs
  factory Name.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Name.empty;

    return Name(
      givenName: map['givenName'] as String?,
      surname: map['surname'] as String?,
    );
  }

  // ignore: public_member_api_docs
  factory Name.fromJson(String source) =>
      Name.fromMap(json.decode(source) as Map<String, dynamic>);

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

  static const empty = Name(givenName: '', surname: '');

  // ignore: public_member_api_docs
  String toJson() => json.encode(toMap());

  @override
  String toString() => '$surname $givenName';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Name &&
        other.givenName == givenName &&
        other.surname == surname;
  }

  @override
  int get hashCode => givenName.hashCode ^ surname.hashCode;

  @override
  int compareTo(Name other) {
    return toString().compareTo(other.toString());
  }
}
