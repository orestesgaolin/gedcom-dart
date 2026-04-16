import 'dart:io';

import 'package:test/test.dart';

import '../bin/gedcom_to_mermaid.dart' as cli;

void main() {
  group('gedcom_to_mermaid CLI', () {
    final outputRoot = Directory('test/samples/mermaid_output');

    setUpAll(() {
      if (outputRoot.existsSync()) {
        outputRoot.deleteSync(recursive: true);
      }
      outputRoot.createSync(recursive: true);
    });

    final sources = <_Source>[
      const _Source(
        label: 'v5 test-files',
        inputDir: 'test/samples/test-files/5',
        outputSubdir: 'test-files/5',
      ),
      const _Source(
        label: 'v7 test-files',
        inputDir: 'test/samples/test-files/7',
        outputSubdir: 'test-files/7',
      ),
      const _Source(
        label: 'v7 samples',
        inputDir: 'test/samples/v7',
        outputSubdir: 'v7',
      ),
    ];

    for (final source in sources) {
      final inputDir = Directory(source.inputDir);
      if (!inputDir.existsSync()) continue;

      final gedFiles = inputDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.ged'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      group(source.label, () {
        for (final gedFile in gedFiles) {
          final name = gedFile.uri.pathSegments.last;
          final baseName = name.substring(0, name.length - 4);
          final outputPath =
              '${outputRoot.path}/${source.outputSubdir}/$baseName.mmd';

          test('converts $name', () async {
            Directory(File(outputPath).parent.path).createSync(recursive: true);

            final exitCode = await cli.run([gedFile.path, '-o', outputPath]);

            expect(exitCode, 0, reason: 'CLI failed for $name');
            final outFile = File(outputPath);
            expect(
              outFile.existsSync(),
              isTrue,
              reason: 'No output written for $name',
            );
            final content = outFile.readAsStringSync();
            expect(
              content,
              startsWith('flowchart TD'),
              reason: 'Output for $name is not a Mermaid flowchart',
            );
          });
        }
      });
    }

    group('family edges via CLI', () {
      test('v5 pedi-1.ged wires the CHIL edge', () async {
        const out = 'test/samples/mermaid_output/cli-v5-pedi-1.mmd';
        final exitCode = await cli.run(
          ['test/samples/test-files/5/pedi-1.ged', '-o', out],
        );
        expect(exitCode, 0);
        final content = File(out).readAsStringSync();
        expect(content, contains('1["@1@"]'));
        expect(content, contains('2{{"@2@"}}'));
        expect(content, contains('2 --> 1'));
      });

      test('v7 pedi-1.ged wires the CHIL edge', () async {
        const out = 'test/samples/mermaid_output/cli-v7-pedi-1.mmd';
        final exitCode = await cli.run(
          ['test/samples/test-files/7/pedi-1.ged', '-o', out],
        );
        expect(exitCode, 0);
        final content = File(out).readAsStringSync();
        expect(content, contains('1["@1@"]'));
        expect(content, contains('2{{"@2@"}}'));
        expect(content, contains('2 --> 1'));
      });

      test('v7 maximal70-tree1.ged emits spouse and child edges', () async {
        const out = 'test/samples/mermaid_output/cli-v7-maximal-tree1.mmd';
        final exitCode = await cli.run(
          ['test/samples/v7/maximal70-tree1.ged', '-o', out],
        );
        expect(exitCode, 0);
        final content = File(out).readAsStringSync();
        expect(content, contains('F1{{"@F1@"}}'));
        expect(content, contains('I1 --- F1'));
        expect(content, contains('I2 --- F1'));
        expect(content, contains('F1 --> I4'));
        expect(content, contains('F2 --> I1'));
        expect(content, isNot(contains('VOID')));
      });

      test('v7 maximal70-tree2.ged produces at least two families', () async {
        const out = 'test/samples/mermaid_output/cli-v7-maximal-tree2.mmd';
        final exitCode = await cli.run(
          ['test/samples/v7/maximal70-tree2.ged', '-o', out],
        );
        expect(exitCode, 0);
        final content = File(out).readAsStringSync();
        expect(content, startsWith('flowchart TD'));
        final familyCount =
            RegExp(r'^\s*F\d+\{\{', multiLine: true).allMatches(content).length;
        expect(familyCount, greaterThanOrEqualTo(2));
        expect(content, matches(RegExp(r'I\w+ --- F\d+', multiLine: true)));
        expect(content, matches(RegExp(r'F\d+ --> I\w+', multiLine: true)));
      });

      test('Harry Potter sample renders full family tree', () async {
        const input = 'test/samples/gedcom-samples/Harry Potter.ged';
        if (!File(input).existsSync()) {
          markTestSkipped('gedcom-samples submodule not checked out');
          return;
        }

        const out = 'test/samples/mermaid_output/cli-harry-potter.mmd';
        final exitCode = await cli.run([input, '-o', out]);
        expect(exitCode, 0);

        final content = File(out).readAsStringSync();
        expect(content, startsWith('flowchart TD'));

        expect(content, contains('I00001["Harry Potter"]'));

        expect(content, contains('F00001{{"@F00001@"}}'));
        expect(content, contains('I00002 --- F00001'));
        expect(content, contains('I00003 --- F00001'));
        expect(content, contains('F00001 --> I00001'));

        final individualCount =
            RegExp(r'^\s*I\d+\[', multiLine: true).allMatches(content).length;
        expect(individualCount, greaterThan(100));

        final familyCount =
            RegExp(r'^\s*F\d+\{\{', multiLine: true).allMatches(content).length;
        expect(familyCount, greaterThanOrEqualTo(40));
      });

      test('--no-dates flag omits birth/death years end-to-end', () async {
        const out = 'test/samples/mermaid_output/cli-v7-maximal-tree1-nd.mmd';
        final exitCode = await cli.run(
          [
            'test/samples/v7/maximal70-tree1.ged',
            '--no-dates',
            '-o',
            out,
          ],
        );
        expect(exitCode, 0);
        final content = File(out).readAsStringSync();
        expect(content, contains('I1['));
        expect(content, isNot(contains('<br/>')));
      });
    });

    test('--help writes usage and exits 0', () async {
      final exitCode = await cli.run(['--help']);
      expect(exitCode, 0);
    });

    test('unknown option exits with code 64', () async {
      final exitCode = await cli.run(['--not-a-flag']);
      expect(exitCode, 64);
    });
  });
}

class _Source {
  const _Source({
    required this.label,
    required this.inputDir,
    required this.outputSubdir,
  });

  final String label;
  final String inputDir;
  final String outputSubdir;
}
