import 'package:gedcom/gedcom.dart';

const testData = '''
  0 @I25@ INDI
  1 NAME Thomas Trask /Wetmore/ Sr
  1 SEX M
  1 BIRT
    2 DATE 13 March 1866
    2 PLAC St. Mary's Bay, Digby, Nova Scotia
    2 SOUR Social Security application
  1 NATU
    2 NAME Thomas T. Wetmore
    2 DATE 26 October 1888
    2 PLAC Norwich, New London, Connecticut
    2 AGE 22 years
    2 COUR New London County Court of Common Pleas
    2 SOUR court record from National Archives
  1 OCCU Antiques Dealer
  1 DEAT
    2 NAME Thomas Trask Wetmore
    2 DATE 17 February 1947
    2 PLAC New London, New London, Connecticut
    2 AGE 80 years, 11 months, 4 days
    2 CAUS Heart Attack
    2 SOUR New London Death Records
  1 FAMC @F11@
  1 FAMS @F6@
  1 FAMS @F12@
''';

void main() {
  final parser = GedcomParser();
  final root = parser.parse(testData);
  // ignore: avoid_print
  print(root.toGedcomString(recursive: true));
  //Output:

  // 0 @I25@ INDI
  // 1 NAME Thomas Trask /Wetmore/ Sr
  // 1 SEX M
  // 1 BIRT
  // 2 DATE 13 March 1866
  // 2 PLAC St. Mary's Bay, Digby, Nova Scotia
  // 2 SOUR Social Security application
  // 1 NATU
  // 2 NAME Thomas T. Wetmore
  // 2 DATE 26 October 1888
  // 2 PLAC Norwich, New London, Connecticut
  // 2 AGE 22 years
  // 2 COUR New London County Court of Common Pleas
  // 2 SOUR court record from National Archives
  // 1 OCCU Antiques Dealer
  // 1 DEAT
  // 2 NAME Thomas Trask Wetmore
  // 2 DATE 17 February 1947
  // 2 PLAC New London, New London, Connecticut
  // 2 AGE 80 years, 11 months, 4 days
  // 2 CAUS Heart Attack
  // 2 SOUR New London Death Records
  // 1 FAMC @F11@
  // 1 FAMS @F6@
  // 1 FAMS @F12@
}
