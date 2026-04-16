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

import 'package:gedcom/src/element/element.dart';
import 'package:gedcom/src/gedcom.dart';
import 'package:gedcom/src/gedcom7.dart';

export 'src/element/element.dart';
export 'src/gedcom.dart' show Gedcom5Parser;
export 'src/gedcom7.dart' show Gedcom7Parser;
export 'src/mermaid.dart'
    show GedcomMermaidRenderer, MermaidDirection, MermaidFamilyShape;

class GedcomParser {
  RootElement parse(String data, {bool strict = true}) {
    final version = _detectVersion(data);
    if (version.startsWith('7.')) {
      return Gedcom7Parser().parse(data, strict: strict);
    } else {
      return Gedcom5Parser().parse(data, strict: strict);
    }
  }

  String _detectVersion(String data) {
    final lines = data.split('\n');
    for (final line in lines) {
      if (line.startsWith('1 GEDC')) {
        final nextLineIndex = lines.indexOf(line) + 1;
        if (nextLineIndex < lines.length) {
          final nextLine = lines[nextLineIndex];
          if (nextLine.trim().startsWith('2 VERS')) {
            return nextLine.trim().substring(7);
          }
        }
      }
    }
    // Default to 5.5.1 if no version is found
    return '5.5.1';
  }
}

