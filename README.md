# GEDCOM-Dart

Port of [python-gedcom](https://github.com/nickreynke/python-gedcom) library to Dart.

GEDCOM files contain ancestry data. The parser supports both **GEDCOM 5.5/5.5.1** and **GEDCOM 7.0** formats.

## GEDCOM version support

`GedcomParser` automatically detects the version from the `HEAD.GEDC.VERS` tag and delegates to the appropriate parser (`Gedcom5Parser` or `Gedcom7Parser`). You can also use `Gedcom5Parser` or `Gedcom7Parser` directly if needed.

Key differences between GEDCOM 5.5 and 7.0 handled by this library:

- **Sources**: GEDCOM 7.0 parses `SOUR` records as `SourceElement` (with proper type preservation via `copyWith`)
- **Shared notes**: GEDCOM 7.0 uses `SNOTE` for shared note records (5.5 uses `NOTE`)
- **Relationships**: GEDCOM 7.0 uses `ROLE` with `PHRASE` substructures (5.5 uses `RELA`)
- **Languages**: GEDCOM 7.0 uses BCP 47 language tags like `en`, `ja` (5.5 uses full names like `English`, `Japanese`)
- **Dates**: GEDCOM 7.0 normalizes dual-year dates (e.g. `1701/99` becomes `BET 1701 AND 1799` with a `PHRASE`)
- **Extensions**: GEDCOM 7.0 supports `SCHMA` in the header for defining custom tags
- **Character encoding**: GEDCOM 7.0 defaults to UTF-8; the `CHAR` tag from 5.5 is removed

# Warning

The package is still in development. Only selected features are supported.

# Contributing

Contributions are more than welcome!

# License

    Licensed under the GNU General Public License v2

    GEDCOM Dart Parser
    Copyright (C) 2020 Dominik Roszkowski (dominik at roszkowski.dev)

Ported to Dart from Python GEDCOM Parser

    Copyright (C) 2018 Damon Brodie (damon.brodie at gmail.com)
    Copyright (C) 2018-2019 Nicklas Reincke (contact at reynke.com)
    Copyright (C) 2016 Andreas Oberritter
    Copyright (C) 2012 Madeleine Price Ball
    Copyright (C) 2005 Daniel Zappala (zappala at cs.byu.edu)
    Copyright (C) 2005 Brigham Young University

    This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
