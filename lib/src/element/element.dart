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

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

part 'family.dart';
part 'file.dart';
part 'individual.dart';
part 'name.dart';
part 'object.dart';
part 'root.dart';
part 'tags.dart';

/// Base GEDCOM element
/// Each line in a GEDCOM file is an element with the format
/// `level [pointer] tag [value]` where `level` and `tag` are
/// required, and `pointer` and `value` are optional.
///
/// Elements are arranged hierarchically according to their level,
/// and elements with a level of zero are at the top level.
///
/// Elements with a level greater than zero are children of their parent.
/// A pointer has the format `@pname@`, where `pname` is any sequence of
/// characters and numbers. The pointer identifies the object being pointed
/// to, so that any pointer included as the value of any element points
/// back to the original object.
///
/// For example, an element may have a `FAMS` tag whose value is
/// `@F1@`, meaning that this element points to the family record
/// in which the associated person is a spouse.
///
/// Likewise, an element with a tag of `FAMC` has a value that points
/// to a family record in which the associated person is a child.
///
/// See a GEDCOM file for examples of tags and their values.
///
/// Tags available to an element are available in `tags.dart`
@immutable
class GedcomElement {
  /// Constructor of the element
  GedcomElement({
    @required this.level,
    @required this.tag,
    this.pointer,
    this.value,
    List<GedcomElement> children,
    this.parent,
    this.crlf = '\n',
  })  : _children = children ?? [],
        assert(level != null, 'Level is required'),
        assert(tag != null, 'Tag is required');

  /// Level of the element within the GEDCOM file
  final int level;

  /// Pointer of the element withing the GEDCOM file
  final String pointer;

  /// Tag of the element within the GEDCOM file
  final String tag;

  /// Value of the element within the GEDCOM file
  final String value;

  final List<GedcomElement> _children;

  /// Direct child elements of the element
  List<GedcomElement> get children => _children;

  /// Returns new reference to the added element where
  /// this element is its parent
  GedcomElement addChildElement(GedcomElement element) {
    final newElement = element.copyWith(parent: this);
    _children.add(newElement);
    //TODO consider using copyWith instead of modifying the underlying list
    return newElement;
  }

  /// Parent element of the element
  final GedcomElement parent;

  /// Value of the element including concatenations or continuations
  String get multiLineValue {
    var result = value;
    var lastCrlf = crlf;
    for (var element in children) {
      var tag = element.tag;
      if (tag == GEDCOM_TAG_CONCATENATION) {
        result += element.value;
        lastCrlf = element.crlf;
      } else if (tag == GEDCOM_TAG_CONTINUED) {
        result += lastCrlf + element.value;
        lastCrlf = element.crlf;
      }
    }
    return result;
  }

  /// Character used to delimit new lines
  final String crlf;

  /// Indicates whether element consist of multiple lines
  bool get isMultiline => multiLineValue != null;

  /// Creates and returns a new child element of this element
  GedcomElement newChildElement({
    String tag,
    String pointer = '',
    String value = '',
  }) {
    GedcomElement childElement;
    if (tag == GEDCOM_TAG_FAMILY) {
      childElement = FamilyElement(
        level: level + 1,
        pointer: pointer,
        value: value,
        crlf: crlf,
        parent: this,
      );
    } else if (tag == GEDCOM_TAG_FILE) {
      childElement = FileElement(
        level: level + 1,
        pointer: pointer,
        value: value,
        crlf: crlf,
        parent: this,
      );
    } else if (tag == GEDCOM_TAG_INDIVIDUAL) {
      childElement = IndividualElement(
        level: level + 1,
        pointer: pointer,
        value: value,
        crlf: crlf,
        parent: this,
      );
    } else if (tag == GEDCOM_TAG_OBJECT) {
      childElement = ObjectElement(
        level: level + 1,
        pointer: pointer,
        value: value,
        crlf: crlf,
        parent: this,
      );
    } else {
      childElement = GedcomElement(
        level: level + 1,
        pointer: pointer,
        tag: tag,
        value: value,
        crlf: crlf,
        parent: this,
      );
    }
    children.add(childElement);
    return childElement;
  }

  /// Formats this element and optionally all of its subelements
  /// to GEDCOM string
  String toGedcomString({bool recursive = false}) {
    var result = '$level';

    if (pointer != null && pointer.isNotEmpty) {
      result += ' $pointer';
    }

    result += ' $tag';

    if (value != null && value.isNotEmpty) {
      result += ' $value';
    }

    result += crlf;

    if (level < 0) {
      result = '';
    }

    if (recursive == true) {
      for (final element in children) {
        result += element.toGedcomString(recursive: true);
      }
    }

    return result;
  }

  /// Returns copy of the element
  GedcomElement copyWith({
    int level,
    String pointer,
    String tag,
    String value,
    List<GedcomElement> children,
    GedcomElement parent,
    String crlf,
  }) {
    return GedcomElement(
      level: level ?? this.level,
      pointer: pointer ?? this.pointer,
      tag: tag ?? this.tag,
      value: value ?? this.value,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      crlf: crlf ?? this.crlf,
    );
  }

  /// Returns map of the element
  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'pointer': pointer,
      'tag': tag,
      'value': value,
      'children': children?.map((x) => x?.toMap())?.toList(),
      'parent': parent?.toMap(),
      'crlf': crlf,
    };
  }

  /// Creates element from map
  factory GedcomElement.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return GedcomElement(
      level: map['level'],
      pointer: map['pointer'],
      tag: map['tag'],
      value: map['value'],
      children: List<GedcomElement>.from(
          map['children']?.map((x) => GedcomElement.fromMap(x))),
      parent: GedcomElement.fromMap(map['parent']),
      crlf: map['crlf'],
    );
  }

  /// Returns JSON representation of the elmenet
  String toJson() => json.encode(toMap());

  /// Creates element from JSON
  factory GedcomElement.fromJson(String source) =>
      GedcomElement.fromMap(json.decode(source));

  @override
  String toString() => toGedcomString();

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return o is GedcomElement &&
        o.level == level &&
        o.pointer == pointer &&
        o.tag == tag &&
        o.value == value &&
        listEquals(o.children, children) &&
        o.parent == parent &&
        o.crlf == crlf;
  }

  @override
  int get hashCode {
    return level.hashCode ^
        pointer.hashCode ^
        tag.hashCode ^
        value.hashCode ^
        children.hashCode ^
        parent.hashCode ^
        crlf.hashCode;
  }
}
