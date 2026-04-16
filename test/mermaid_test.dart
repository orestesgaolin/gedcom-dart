import 'package:gedcom/gedcom.dart';
import 'package:test/test.dart';

const _sample = '''
0 @I1@ INDI
1 NAME John /Doe/
1 SEX M
1 BIRT
2 DATE 1 JAN 1900
1 DEAT
2 DATE 5 MAY 1970
1 FAMS @F1@
0 @I2@ INDI
1 NAME Jane /Smith/
1 SEX F
1 BIRT
2 DATE 3 FEB 1905
1 FAMS @F1@
0 @I3@ INDI
1 NAME Alice /Doe/
1 SEX F
1 BIRT
2 DATE 10 MAR 1930
1 FAMC @F1@
0 @F1@ FAM
1 HUSB @I1@
1 WIFE @I2@
1 CHIL @I3@
''';

void main() {
  group('GedcomMermaidRenderer', () {
    test('emits flowchart header with configured direction', () {
      final root = GedcomParser().parse(_sample);
      final output = const GedcomMermaidRenderer(
        direction: MermaidDirection.leftRight,
      ).render(root);
      expect(output, startsWith('flowchart LR'));
    });

    test('renders individuals, families, and edges', () {
      final root = GedcomParser().parse(_sample);
      final output = const GedcomMermaidRenderer().render(root);

      expect(output, contains('I1["John Doe<br/>1900–1970"]'));
      expect(output, contains('I2["Jane Smith<br/>1905–"]'));
      expect(output, contains('I3["Alice Doe<br/>1930–"]'));
      expect(output, contains('F1{{"@F1@"}}'));

      expect(output, contains('I1 --- F1'));
      expect(output, contains('I2 --- F1'));
      expect(output, contains('F1 --> I3'));
    });

    test('can omit dates and use alternative family shape', () {
      final root = GedcomParser().parse(_sample);
      final output = const GedcomMermaidRenderer(
        includeDates: false,
        familyShape: MermaidFamilyShape.circle,
      ).render(root);

      expect(output, contains('I1["John Doe"]'));
      expect(output, isNot(contains('1900')));
      expect(output, contains('F1(("@F1@"))'));
    });

    test('handles empty root without errors', () {
      final output = const GedcomMermaidRenderer().render(RootElement());
      expect(output, 'flowchart TD');
    });
  });
}
