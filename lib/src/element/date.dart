part of 'element.dart';

/// GEDCOM element consisting of tag [GEDCOM_TAG_DATE]
class DateElement extends GedcomElement {
  /// Constructor of the FileElement
  DateElement({
    @required int level,
    String pointer,
    String value,
    List<GedcomElement> children,
    GedcomElement parent,
    String crlf = '\n',
  })  : assert(level != null, 'Level is required'),
        super(
          level: level,
          tag: GEDCOM_TAG_BIRTH,
          pointer: pointer,
          value: value,
          children: children,
          parent: parent,
          crlf: crlf,
        );

  @override
  String get tag => GEDCOM_TAG_BIRTH;

  DateTime get date => _parseDate();

  DateTime _parseDate() {
    if (value == null || value.isEmpty) {
      return null;
    }
    final values = value.split(' ').toList();
    if (values.isNotEmpty) {
      if (values.length == 1) {
        if (values.first.length == 4) {
          final year = int.tryParse(values.first);
          if (year != null) {
            return DateTime(year);
          }
        }
      } else if (values.length == 2) {
        final month = months[values[0]];
        final year = int.tryParse(values[1]);
        return DateTime(year, month);
      } else if (values.length == 3) {
        final day = int.tryParse(values[0]);
        final month = months[values[1]];
        final year = int.tryParse(values[2]);
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  /// Returns copy of the element
  @override
  DateElement copyWith({
    int level,
    String pointer,
    String tag,
    String value,
    List<GedcomElement> children,
    GedcomElement parent,
    String crlf,
  }) {
    return DateElement(
      level: level ?? this.level,
      pointer: pointer ?? this.pointer,
      value: value ?? this.value,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      crlf: crlf ?? this.crlf,
    );
  }
}

const months = <String, int>{
  'JAN': 1,
  'FEB': 2,
  'MAR': 3,
  'APR': 4,
  'MAY': 5,
  'JUN': 6,
  'JUL': 7,
  'AUG': 8,
  'SEP': 9,
  'OCT': 10,
  'NOV': 11,
  'DEC': 12,
};
