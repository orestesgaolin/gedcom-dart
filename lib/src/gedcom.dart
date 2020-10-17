// Licensed under the GNU General Public License v2

// GEDCOM Dart Parser
// Copyright (C) 2020 Dominik Roszkowski (dominik at roszkowski.dev)

// Ported to Dart from Python GEDCOM Parser
// Copyright (C) 2018 Damon Brodie (damon.brodie at gmail.com)
// Copyright (C) 2018-2019 Nicklas Reincke (contact at reynke.com)
// Copyright (C) 2016 Andreas Oberritter
// Copyright (C) 2012 Madeleine Price Ball
// Copyright (C) 2005 Daniel Zappala (zappala at cs.byu.edu)
// Copyright (C) 2005 Brigham Young University

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

import 'package:meta/meta.dart';

import 'element/element.dart';

/// Class responsible for parsing GEDCOM data
class GedcomParser {
  final RootElement _root = RootElement();

  /// Parses the string input consisting of GEDCOM
  /// lines and returns resulting [RootElement]
  /// having parsed data as its children
  RootElement parse(String data, {bool strict = true}) {
    var lineNumber = 1;
    GedcomElement lastElement = _root;

    final lines = data.split('\n')
      ..removeWhere((element) => element.trim().isEmpty);

    for (final line in lines) {
      lastElement = _parseLine(
          lineNumber: lineNumber, line: line, lastElement: lastElement);
      lineNumber++;
    }
    return _root;
  }

  /// Parses single line of GEDCOM input
  ///
  /// Returns resulting [GedcomElement]
  GedcomElement _parseLine({
    @required int lineNumber,
    @required String line,
    @required GedcomElement lastElement,
    bool strict = true,
  }) {
    final match = RegExp(_lineRe).firstMatch(line);

    if (match == null) {
      if (strict == true) {
        throw Exception(
            'Line $lineNumber $line of document violates GEDCOM format 5.5 '
            'See: https://chronoplexsoftware.com/gedcomvalidator/gedcom/gedcom-5.5.pdf');
      } else {
        //TODO: handle non-strict case as https://github.com/nickreynke/python-gedcom/blob/master/gedcom/parser.py
        throw UnimplementedError();
      }
    } else {
      final level = int.parse(match.group(1));
      final pointer = match.group(2).trim();
      final tag = match.group(3).trim().toUpperCase();
      final value = match.group(4).trim();
      final crlf = match.groupCount > 4 ? match.group(5).trim() : '\n';

      if (level > lastElement.level + 1) {
        throw Exception('Line $lineNumber of document violates GEDCOM '
            'format 5.5. Lines must be no more than one level higher than '
            'previous line. See https://chronoplexsoftware.com/gedcomvalidator/gedcom/gedcom-5.5.pdf');
      }
      GedcomElement element;
      if (tag == GEDCOM_TAG_FAMILY) {
        element = FamilyElement(
          level: level,
          pointer: pointer,
          value: value,
          crlf: crlf,
        );
      } else if (tag == GEDCOM_TAG_FILE) {
        element = FileElement(
          level: level,
          pointer: pointer,
          value: value,
          crlf: crlf,
        );
      } else if (tag == GEDCOM_TAG_INDIVIDUAL) {
        element = IndividualElement(
          level: level,
          pointer: pointer,
          value: value,
          crlf: crlf,
        );
      } else if (tag == GEDCOM_TAG_OBJECT) {
        element = ObjectElement(
          level: level,
          pointer: pointer,
          value: value,
          crlf: crlf,
        );
      } else {
        element = GedcomElement(
          level: level,
          pointer: pointer,
          tag: tag,
          value: value,
          crlf: crlf,
        );
      }
      var parentElement = lastElement;
      while (parentElement.level > level - 1) {
        parentElement = parentElement.parent;
      }

      final newElement = parentElement.addChildElement(element);

      return newElement;
    }
  }
}

/// Level must start with non-negative int, no leading zeros.
/// Pointer optional, if it exists it must be flanked by `@`.
/// Tag must be an alphanumeric string.
/// Value optional, consists of anything after a space to end of line.
/// End of line defined by `\n` or `\r`.
const _lineRe = r'\s*(0|[1-9]+[0-9]*) (@[^@]+@ |)([A-Za-z0-9_]+)( [^\n\r]*|)';
