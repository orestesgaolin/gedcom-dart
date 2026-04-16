import 'dart:io';

import 'package:gedcom/gedcom.dart';
import 'package:test/test.dart';

import 'samples/v5/torture.dart';

String _renderFile(String path) {
  final data = File(path).readAsStringSync();
  return const GedcomMermaidRenderer()
      .render(GedcomParser().parse(data, strict: false));
}

void main() {
  group('Mermaid rendering — family relationships', () {
    group('v5 test-files', () {
      test('pedi-1.ged wires the single CHIL edge', () {
        final output = _renderFile('test/samples/test-files/5/pedi-1.ged');

        expect(output, contains('1["@1@"]'));
        expect(output, contains('2{{"@2@"}}'));
        expect(output, contains('2 --> 1'));

        expect(output, isNot(contains('1 --- 2')));
        expect(output, isNot(contains('--- 1')));
      });

      test('torture inline data renders multi-spouse and children edges', () {
        final root = Gedcom5Parser().parse(v5tortureTest1);
        final output = const GedcomMermaidRenderer().render(root);

        expect(output, contains('FAMILY1{{"@FAMILY1@"}}'));
        expect(output, contains('PERSON1 --- FAMILY1'));
        expect(output, contains('PERSON2 --- FAMILY1'));
        expect(output, contains('FAMILY1 --> PERSON3'));
        expect(output, contains('FAMILY1 --> PERSON4'));

        expect(output, contains('FAMILY2{{"@FAMILY2@"}}'));
        expect(output, contains('PERSON1 --- FAMILY2'));
        expect(output, contains('PERSON8 --- FAMILY2'));
        expect(output, contains('FAMILY2 --> PERSON7'));

        expect(output, contains('F5{{"@F5@"}}'));
        expect(output, contains('I9 --- F5'));
        expect(output, contains('I15 --- F5'));
        expect(output, contains('F5 --> I10'));
        expect(output, contains('F5 --> I11'));
        expect(output, contains('F5 --> I12'));
      });
    });

    group('v7 test-files', () {
      test('pedi-1.ged wires the single CHIL edge', () {
        final output = _renderFile('test/samples/test-files/7/pedi-1.ged');

        expect(output, contains('1["@1@"]'));
        expect(output, contains('2{{"@2@"}}'));
        expect(output, contains('2 --> 1'));
      });

      test('maximal70-tree1.ged renders husband, wife, and child edges', () {
        final output = _renderFile('test/samples/v7/maximal70-tree1.ged');

        expect(output, contains('F1{{"@F1@"}}'));
        expect(output, contains('I1 --- F1'));
        expect(output, contains('I2 --- F1'));
        expect(output, contains('F1 --> I4'));

        expect(output, contains('F2{{"@F2@"}}'));
        expect(output, contains('F2 --> I1'));

        // @VOID@ is not a real individual so no edge should be emitted for it.
        expect(output, isNot(contains('VOID')));

        // Individual labels fall back to the pointer when no NAME child exists.
        expect(output, contains('I3["@I3@"]'));
        expect(output, contains('I4["@I4@"]'));
      });

      test('maximal70-tree2.ged renders families from the second sample', () {
        final output = _renderFile('test/samples/v7/maximal70-tree2.ged');

        expect(output, startsWith('flowchart TD'));
        final familyCount =
            RegExp(r'^\s*F\d+\{\{', multiLine: true).allMatches(output).length;
        expect(familyCount, greaterThanOrEqualTo(2));

        // At least one spouse edge and one child edge should exist.
        expect(output, matches(RegExp(r'I\w+ --- F\d+', multiLine: true)));
        expect(output, matches(RegExp(r'F\d+ --> I\w+', multiLine: true)));
      });
    });
  });
}
