import 'dart:convert';
import 'dart:io';

import 'package:gedcom/gedcom.dart';

const _usage = '''
Usage: gedcom_to_mermaid [options] [input.ged]

Reads a GEDCOM file (or stdin when no path is given) and writes a
Mermaid flowchart to stdout.

Options:
  -o, --output <path>     Write output to <path> instead of stdout.
  -d, --direction <dir>   Flowchart direction: TD (default), LR, BT, RL.
  -s, --shape <shape>     Family node shape: hexagon (default), circle,
                          rectangle.
      --no-dates          Omit birth/death years from individual labels.
  -h, --help              Show this message.
''';

Future<int> run(List<String> arguments) async {
  var direction = MermaidDirection.topDown;
  var shape = MermaidFamilyShape.hexagon;
  var includeDates = true;
  String? inputPath;
  String? outputPath;

  for (var i = 0; i < arguments.length; i++) {
    final arg = arguments[i];
    switch (arg) {
      case '-h':
      case '--help':
        stdout.write(_usage);
        return 0;
      case '--no-dates':
        includeDates = false;
      case '-o':
      case '--output':
        if (++i >= arguments.length) {
          return _fail('Missing value for $arg');
        }
        outputPath = arguments[i];
      case '-d':
      case '--direction':
        if (++i >= arguments.length) {
          return _fail('Missing value for $arg');
        }
        final parsed = _parseDirection(arguments[i]);
        if (parsed == null) {
          return _fail('Unknown direction: ${arguments[i]}');
        }
        direction = parsed;
      case '-s':
      case '--shape':
        if (++i >= arguments.length) {
          return _fail('Missing value for $arg');
        }
        final parsed = _parseShape(arguments[i]);
        if (parsed == null) {
          return _fail('Unknown shape: ${arguments[i]}');
        }
        shape = parsed;
      default:
        if (arg.startsWith('-')) {
          return _fail('Unknown option: $arg');
        }
        if (inputPath != null) {
          return _fail('Only one input file is supported');
        }
        inputPath = arg;
    }
  }

  final String data;
  if (inputPath == null) {
    if (stdin.hasTerminal) {
      stderr.writeln('Reading from stdin. Pipe a GEDCOM file or pass a path.');
    }
    data = await stdin.transform(systemEncoding.decoder).join();
  } else {
    final file = File(inputPath);
    if (!file.existsSync()) {
      return _fail('File not found: $inputPath');
    }
    data = _decodeBytes(await file.readAsBytes());
  }

  final root = GedcomParser().parse(data, strict: false);
  final output = GedcomMermaidRenderer(
    direction: direction,
    familyShape: shape,
    includeDates: includeDates,
  ).render(root);

  if (outputPath == null) {
    stdout.writeln(output);
  } else {
    await File(outputPath).writeAsString('$output\n');
  }
  return 0;
}

Future<void> main(List<String> arguments) async {
  exitCode = await run(arguments);
}

MermaidDirection? _parseDirection(String value) {
  switch (value.toUpperCase()) {
    case 'TD':
    case 'TB':
      return MermaidDirection.topDown;
    case 'LR':
      return MermaidDirection.leftRight;
    case 'BT':
      return MermaidDirection.bottomUp;
    case 'RL':
      return MermaidDirection.rightLeft;
  }
  return null;
}

MermaidFamilyShape? _parseShape(String value) {
  switch (value.toLowerCase()) {
    case 'hexagon':
      return MermaidFamilyShape.hexagon;
    case 'circle':
      return MermaidFamilyShape.circle;
    case 'rectangle':
    case 'rect':
      return MermaidFamilyShape.rectangle;
  }
  return null;
}

String _decodeBytes(List<int> bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF) {
    return utf8.decode(bytes.sublist(3));
  }
  if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
    return _decodeUtf16(bytes.sublist(2), bigEndian: true);
  }
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
    return _decodeUtf16(bytes.sublist(2), bigEndian: false);
  }
  // No BOM: sniff for UTF-16 by checking zero bytes in even/odd positions
  // (ASCII content encoded as UTF-16 leaves one byte of every pair as 0x00).
  if (bytes.length >= 4 && bytes.length.isEven) {
    final sampleEnd = bytes.length < 512 ? bytes.length : 512;
    var zerosAtEven = 0;
    var zerosAtOdd = 0;
    for (var i = 0; i < sampleEnd; i++) {
      if (bytes[i] == 0) {
        if (i.isEven) {
          zerosAtEven++;
        } else {
          zerosAtOdd++;
        }
      }
    }
    final half = sampleEnd ~/ 2;
    if (zerosAtEven > half * 0.8) {
      return _decodeUtf16(bytes, bigEndian: true);
    }
    if (zerosAtOdd > half * 0.8) {
      return _decodeUtf16(bytes, bigEndian: false);
    }
  }
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return latin1.decode(bytes);
  }
}

String _decodeUtf16(List<int> bytes, {required bool bigEndian}) {
  final units = <int>[];
  for (var i = 0; i + 1 < bytes.length; i += 2) {
    units.add(
      bigEndian
          ? (bytes[i] << 8) | bytes[i + 1]
          : (bytes[i + 1] << 8) | bytes[i],
    );
  }
  return String.fromCharCodes(units);
}

int _fail(String message) {
  stderr
    ..writeln('gedcom_to_mermaid: $message')
    ..writeln()
    ..writeln(_usage);
  return 64;
}
