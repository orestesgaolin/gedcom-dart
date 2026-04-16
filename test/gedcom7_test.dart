// Licensed under the GNU General Public License v2

// GEDCOM Dart Parser
// Copyright (C) 2020 Dominik Roszkowski (dominik at roszkowski.dev)

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.

import 'dart:io';

import 'package:gedcom/gedcom.dart';
import 'package:test/test.dart';

void main() {
  group('Gedcom 7.0 Parser', () {
    test('parses minimal70.ged', () {
      final file = File('test/samples/v7/minimal70.ged');
      final content = file.readAsStringSync();
      final parser = GedcomParser();
      final root = parser.parse(content);

      expect(root.children, isNotEmpty);
      final gedc = root.children
          .firstWhere((element) => element.tag == 'HEAD')
          .children
          .firstWhere((element) => element.tag == 'GEDC');
      final vers = gedc.children.firstWhere((element) => element.tag == 'VERS');
      expect(vers.value, '7.0');
    });

    test('parses maximal70-tree1.ged', () {
      final file = File('test/samples/v7/maximal70-tree1.ged');
      final content = file.readAsStringSync();
      final parser = GedcomParser();
      final root = parser.parse(content);

      expect(root.children.length, 10);
    });

    test('parses maximal70-tree2.ged', () {
      final file = File('test/samples/v7/maximal70-tree2.ged');
      final content = file.readAsStringSync();
      final parser = GedcomParser();
      final root = parser.parse(content);

      expect(root.children.length, 10);
    });

    test('parses age.ged', () {
      final file = File('test/samples/v7/age.ged');
      final content = file.readAsStringSync();
      final parser = GedcomParser();
      final root = parser.parse(content);

      expect(root.children.length, 3);
    });

    test('parses SOUR tags', () {
      final file = File('test/samples/v7/maximal70-tree1.ged');
      final content = file.readAsStringSync();
      final parser = GedcomParser();
      final root = parser.parse(content);

      final sources = root.children.whereType<SourceElement>().toList();
      expect(sources.length, 2);
      expect(sources[0].tag, 'SOUR');
      expect(sources[0].pointer, '@S1@');
      expect(sources[1].tag, 'SOUR');
      expect(sources[1].pointer, '@S2@');
    });
  });

  group('Gedcom 7.0 test-files', () {
    RootElement parseFile(String filename) {
      final file = File('test/samples/test-files/7/$filename');
      final content = file.readAsStringSync();
      return GedcomParser().parse(content);
    }

    test('parses age-invalid.ged', () {
      final root = parseFile('age-invalid.ged');
      expect(root.children.length, 4);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final gedc = head.children.firstWhere((e) => e.tag == 'GEDC');
      final vers = gedc.children.firstWhere((e) => e.tag == 'VERS');
      expect(vers.value, '7.0');

      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@SIMPLE@');

      final events = indi.children.where((e) => e.tag == 'EVEN').toList();
      expect(events.length, greaterThan(50));

      // Each EVEN should have a TYPE and AGE child
      for (final event in events) {
        expect(
          event.children.where((e) => e.tag == 'TYPE').length,
          1,
          reason: 'EVEN "${event.value}" should have exactly one TYPE',
        );
        expect(
          event.children.where((e) => e.tag == 'AGE').length,
          1,
          reason: 'EVEN "${event.value}" should have exactly one AGE',
        );
      }

      // Verify specific age formats are parsed
      final firstEvent = events.first;
      expect(firstEvent.value, 'when 0');
      final firstAge = firstEvent.children.firstWhere((e) => e.tag == 'AGE');
      expect(firstAge.value, '0y');
    });

    test('parses age-valid.ged', () {
      final root = parseFile('age-valid.ged');
      expect(root.children.length, 4);

      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@SIMPLE@');

      final events = indi.children.where((e) => e.tag == 'EVEN').toList();
      expect(events.length, greaterThan(30));

      // Verify PHRASE subrecords exist on age keyword events
      final childEvent = events.firstWhere((e) => e.value == 'when child');
      final childAge = childEvent.children.firstWhere((e) => e.tag == 'AGE');
      expect(childAge.value, '< 8y');
      final childPhrase =
          childAge.children.firstWhere((e) => e.tag == 'PHRASE');
      expect(childPhrase.value, 'child');

      // Verify DEAT element with AGE and PHRASE
      final deathElements = indi.children.whereType<DeathElement>().toList();
      expect(deathElements.length, 1);
      final deathAge =
          deathElements.first.children.firstWhere((e) => e.tag == 'AGE');
      expect(deathAge.value, '0y');
      final deathPhrase =
          deathAge.children.firstWhere((e) => e.tag == 'PHRASE');
      expect(deathPhrase.value, 'Stillborn');
    });

    test('parses atsign.ged', () {
      final root = parseFile('atsign.ged');
      expect(root.children.length, 22);

      final snotes = root.children.where((e) => e.tag == 'SNOTE').toList();
      expect(snotes.length, 19);

      // Verify specific SNOTE pointers and values
      expect(snotes[0].pointer, '@N01@');
      expect(snotes[0].value, contains('leading'));

      expect(snotes[4].pointer, '@N05@');
      expect(snotes[4].value, contains('internal'));

      // Last SNOTE has CONT continuation
      final lastSnote = snotes.last;
      expect(lastSnote.pointer, '@N19@');
      final cont = lastSnote.children.firstWhere((e) => e.tag == 'CONT');
      expect(cont, isNotNull);
      expect(cont.value, contains('CONT'));
    });

    test('parses char_ascii_1.ged', () {
      final root = parseFile('char_ascii_1.ged');
      expect(root.children.length, 3);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final sour = head.children.firstWhere((e) => e.tag == 'SOUR');
      expect(sour.value, 'conversion test');

      final subm = root.children.firstWhere((e) => e.tag == 'SUBM');
      final name = subm.children.firstWhere((e) => e.tag == 'NAME');
      expect(name.value, 'Luther Tychonievich');
    });

    test('parses char_ascii_2.ged', () {
      final root = parseFile('char_ascii_2.ged');
      expect(root.children.length, 3);

      final subm = root.children.firstWhere((e) => e.tag == 'SUBM');
      final name = subm.children.firstWhere((e) => e.tag == 'NAME');
      expect(name.value, 'Luther Tychonievich');
    });

    test('parses char_utf16be-1.ged', () {
      final root = parseFile('char_utf16be-1.ged');
      expect(root.children.length, 3);
    });

    test('parses char_utf16be-2.ged', () {
      final root = parseFile('char_utf16be-2.ged');
      expect(root.children.length, 3);
    });

    test('parses char_utf16le-1.ged', () {
      final root = parseFile('char_utf16le-1.ged');
      expect(root.children.length, 3);
    });

    test('parses char_utf16le-2.ged', () {
      final root = parseFile('char_utf16le-2.ged');
      expect(root.children.length, 3);
    });

    test('parses char_utf8-1.ged', () {
      final root = parseFile('char_utf8-1.ged');
      expect(root.children.length, 3);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final note = head.children.firstWhere((e) => e.tag == 'NOTE');
      expect(note.value, contains('UTF-8 without BOM'));
      expect(note.value, contains('¶'));
      expect(note.value, contains('☺'));
    });

    test('parses char_utf8-2.ged', () {
      final root = parseFile('char_utf8-2.ged');
      expect(root.children.length, 3);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final note = head.children.firstWhere((e) => e.tag == 'NOTE');
      expect(note.value, contains('mislabeled as UNICODE'));
      expect(note.value, contains('¶'));
    });

    test('parses char_utf8-3.ged', () {
      final root = parseFile('char_utf8-3.ged');
      expect(root.children.length, 3);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final note = head.children.firstWhere((e) => e.tag == 'NOTE');
      expect(note.value, contains('UTF-8 with BOM'));
      expect(note.value, contains('¶'));
      expect(note.value, contains('☺'));
    });

    test('parses date-all.ged', () {
      final root = parseFile('date-all.ged');
      expect(root.children.length, 11);

      final individuals = root.children.whereType<IndividualElement>().toList();
      expect(individuals.length, 9);

      // Verify individual pointers
      final pointers = individuals.map((e) => e.pointer).toList();
      expect(pointers, contains('@SIMPLE@'));
      expect(pointers, contains('@CALENDAR@'));
      expect(pointers, contains('@PERIOD@'));
      expect(pointers, contains('@APPROXIMATE@'));
      expect(pointers, contains('@RANGE@'));
      expect(pointers, contains('@CLOSED_RANGE@'));

      // SIMPLE individual should have BIRT with DATE
      final simple = individuals.firstWhere((e) => e.pointer == '@SIMPLE@');
      final births = simple.children.whereType<BirthElement>().toList();
      expect(births, isNotEmpty);

      // Year-only date: "1401" -> DateTime(1401)
      final date1401 = births[0].children.whereType<DateElement>().first;
      expect(date1401.value, '1401');
      expect(date1401.date, DateTime(1401));

      // In v7, dual year "1401/8" becomes "BET 1401 AND 1408" -> null (not simple)
      final dateBet = births[1].children.whereType<DateElement>().first;
      expect(dateBet.value, 'BET 1401 AND 1408');
      expect(dateBet.date, isNull);

      // Month + year: "OCT 1401" -> DateTime(1401, 10)
      final dateOct = births[2].children.whereType<DateElement>().first;
      expect(dateOct.value, 'OCT 1401');
      expect(dateOct.date, DateTime(1401, 10));

      // Full date: "12 AUG 1401" -> DateTime(1401, 8, 12)
      final dateFull = births[3].children.whereType<DateElement>().first;
      expect(dateFull.value, '12 AUG 1401');
      expect(dateFull.date, DateTime(1401, 8, 12));

      // BirthElement.date should resolve through DateElement child
      expect(births[0].date, DateTime(1401));
      expect(births[2].date, DateTime(1401, 10));
      expect(births[3].date, DateTime(1401, 8, 12));
    });

    test('parses date-dual-invalid.ged', () {
      final root = parseFile('date-dual-invalid.ged');
      expect(root.children.length, 4);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final note = head.children.firstWhere((e) => e.tag == 'NOTE');
      expect(note.value, 'Test for bug identified by Dave Thaler');

      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@1@');

      final births = indi.children.whereType<BirthElement>().toList();
      expect(births.length, greaterThan(5));

      // Each BIRT should have NOTE, DATE, and DATE should have PHRASE
      for (final birth in births) {
        final dateElements = birth.children.whereType<DateElement>().toList();
        expect(
          dateElements.length,
          1,
          reason: 'Each BIRT should have one DATE',
        );
        final phrase =
            dateElements.first.children.where((e) => e.tag == 'PHRASE');
        expect(
          phrase.length,
          1,
          reason: 'Each DATE in dual-invalid should have a PHRASE',
        );
      }

      // v7 dual dates are converted: "1701/99" -> "BET 1701 AND 1799"
      // BET dates should not parse to DateTime
      final firstDate = births.first.children.whereType<DateElement>().first;
      expect(firstDate.value, 'BET 1701 AND 1799');
      expect(firstDate.date, isNull);

      // "JAN 1699" is a simple month+year -> parseable
      final secondDate = births[1].children.whereType<DateElement>().first;
      expect(secondDate.value, 'JAN 1699');
      expect(secondDate.date, DateTime(1699));
    });

    test('parses enum-ext.ged', () {
      final root = parseFile('enum-ext.ged');
      expect(root.children.length, 7);

      // HEAD contains SCHMA with custom TAG definition
      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final schma = head.children.firstWhere((e) => e.tag == 'SCHMA');
      final tag = schma.children.firstWhere((e) => e.tag == 'TAG');
      expect(tag.value, '_LOC http://genealogy.net/GEDCOM#_LOC');

      // INDI @2@ has two NAME entries with TYPE
      final individuals = root.children.whereType<IndividualElement>().toList();
      expect(individuals.length, 2);

      final indi2 = individuals.firstWhere((e) => e.pointer == '@2@');
      final names = indi2.children.where((e) => e.tag == 'NAME').toList();
      expect(names.length, 2);
      expect(names[0].value, '/Family/ Personal');
      final nameType0 = names[0].children.firstWhere((e) => e.tag == 'TYPE');
      expect(nameType0.value, 'PROFESSIONAL');
      expect(names[1].value, 'King /Kong/');
      final nameType1 = names[1].children.firstWhere((e) => e.tag == 'TYPE');
      expect(nameType1.value, 'OTHER');
      final phrase = nameType1.children.firstWhere((e) => e.tag == 'PHRASE');
      expect(phrase.value, 'Screen');

      // Custom _LOC record is parsed
      final loc = root.children.firstWhere((e) => e.tag == '_LOC');
      expect(loc.pointer, '@3@');
    });

    test('parses filename-1.ged', () {
      final root = parseFile('filename-1.ged');
      expect(root.children.length, 4);

      final obje = root.children.whereType<ObjectElement>().first;
      expect(obje.pointer, '@1@');

      final files = obje.children.whereType<FileElement>().toList();
      expect(files.length, 9);

      // Verify specific file paths
      expect(files[0].value, 'file:///unix/absolute');
      expect(files[1].value, 'file:///c:/windows/absolute');
      expect(files[2].value, 'file://windows/server');
      expect(files[3].value, 'a/relative/path');
      expect(files[7].value, 'https://leave.alone?with=args#and-frags');

      // Each FILE should have a FORM child
      for (final file in files) {
        final form = file.children.firstWhere((e) => e.tag == 'FORM');
        expect(form.value, 'image/bmp');
      }
    });

    test('parses lang-all.ged', () {
      final root = parseFile('lang-all.ged');
      expect(root.children.length, 7);

      // HEAD LANG is 'af'
      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final lang = head.children.firstWhere((e) => e.tag == 'LANG');
      expect(lang.value, 'af');

      // SUBM has multiple LANG entries
      final subm = root.children.firstWhere((e) => e.tag == 'SUBM');
      final submLangs = subm.children.where((e) => e.tag == 'LANG').toList();
      expect(submLangs.length, 3);
      expect(submLangs[0].value, 'en');
      expect(submLangs[1].value, 'ja');
      expect(submLangs[2].value, 'es');

      // _ALL_LANGUAGES has many LANG entries
      final allLangs = root.children.firstWhere((e) => e.pointer == '@2@');
      final langEntries =
          allLangs.children.where((e) => e.tag == 'LANG').toList();
      expect(langEntries.length, greaterThan(70));

      // _PHON_ROMN_PAYLOADS has LANG with PHRASE substructures
      final phonRomn = root.children.firstWhere((e) => e.pointer == '@4@');
      final phonLangs =
          phonRomn.children.where((e) => e.tag == 'LANG').toList();
      expect(phonLangs.length, 2);
      expect(phonLangs[0].value, 'und');
      final hangulPhrase =
          phonLangs[0].children.firstWhere((e) => e.tag == '_PHRASE');
      expect(hangulPhrase.value, 'hangul');
    });

    test('parses notes-1.ged', () {
      final root = parseFile('notes-1.ged');
      expect(root.children.length, 7);

      // Header has inline NOTE
      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final headerNote = head.children.firstWhere((e) => e.tag == 'NOTE');
      expect(headerNote.value, 'The header note');

      // SUBM has inline NOTE and SNOTE reference
      final subm = root.children.firstWhere((e) => e.tag == 'SUBM');
      final submNote = subm.children.firstWhere((e) => e.tag == 'NOTE');
      expect(submNote.value, 'An inline submission note');
      final submSnote = subm.children.firstWhere((e) => e.tag == 'SNOTE');
      expect(submSnote.value, '@4@');

      // SOUR has three SNOTE references
      final sour = root.children.where((e) => e.tag == 'SOUR').first;
      final sourSnotes = sour.children.where((e) => e.tag == 'SNOTE').toList();
      expect(sourSnotes.length, 3);
      expect(sourSnotes[0].value, '@3@');
      expect(sourSnotes[1].value, '@4@');
      expect(sourSnotes[2].value, '@5@');

      // Shared SNOTE records
      final snotes = root.children.where((e) => e.tag == 'SNOTE').toList();
      expect(snotes.length, 3);
      expect(snotes[0].pointer, '@3@');
      expect(snotes[0].value, 'A single-use note record');
      expect(snotes[1].pointer, '@4@');
      expect(snotes[1].value, 'A dual-use note record');
      expect(snotes[2].pointer, '@5@');
      expect(snotes[2].value, 'A cyclic note record');

      // SNOTE @3@ and @4@ have CHAN with DATE
      final chan3 = snotes[0].children.firstWhere((e) => e.tag == 'CHAN');
      final date3 = chan3.children.whereType<DateElement>().first;
      expect(date3.value, '25 MAY 2021');
      expect(date3.date, DateTime(2021, 5, 25));

      // Cyclic SNOTE @5@ references SOUR @2@
      final cyclicSour = snotes[2].children.firstWhere((e) => e.tag == 'SOUR');
      expect(cyclicSour.value, '@2@');
    });

    test('parses obje-1.ged', () {
      final root = parseFile('obje-1.ged');
      expect(root.children.length, 5);

      final objects = root.children.whereType<ObjectElement>().toList();
      expect(objects.length, 2);

      // First OBJE has mixed media files
      final obje1 = objects.firstWhere((e) => e.pointer == '@1@');
      final files1 = obje1.children.whereType<FileElement>().toList();
      expect(files1.length, 2);
      expect(files1[0].value, 'example.jpg');
      final form0 = files1[0].children.firstWhere((e) => e.tag == 'FORM');
      expect(form0.value, 'image/jpeg');
      final medi = form0.children.firstWhere((e) => e.tag == 'MEDI');
      expect(medi.value, 'PHOTO');
      expect(files1[1].value, 'example.wav');
      final form1 = files1[1].children.firstWhere((e) => e.tag == 'FORM');
      expect(form1.value, 'audio/wav');

      // Second OBJE has video files
      final objeX1 = objects.firstWhere((e) => e.pointer == '@X1@');
      final filesX1 = objeX1.children.whereType<FileElement>().toList();
      expect(filesX1.length, 2);
      expect(filesX1[0].value, 'gifts.webm');
      expect(filesX1[1].value, 'cake.webm');

      // INDI references both OBJE records
      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@2@');
      final objeRefs = indi.children.where((e) => e.tag == 'OBJE').toList();
      expect(objeRefs.length, 2);
      expect(objeRefs[0].value, '@1@');
      expect(objeRefs[1].value, '@X1@');
      final titl = objeRefs[1].children.firstWhere((e) => e.tag == 'TITL');
      expect(titl.value, 'fifth birthday party');
    });

    test('parses obsolete-1.ged', () {
      final root = parseFile('obsolete-1.ged');
      expect(root.children.length, 3);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final gedc = head.children.firstWhere((e) => e.tag == 'GEDC');
      final vers = gedc.children.firstWhere((e) => e.tag == 'VERS');
      expect(vers.value, '7.0');

      final subm = root.children.firstWhere((e) => e.tag == 'SUBM');
      expect(subm.pointer, '@1@');
      final name = subm.children.firstWhere((e) => e.tag == 'NAME');
      expect(name.value, 'Luther Tychonievich');
    });

    test('parses pedi-1.ged', () {
      final root = parseFile('pedi-1.ged');
      expect(root.children.length, 5);

      // HEAD has NOTE about the test
      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final note = head.children.firstWhere((e) => e.tag == 'NOTE');
      expect(note.value, 'Test for bug identified by Diedrich');

      // INDI @1@ with FAMC @2@ and PEDI BIRTH
      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@1@');
      final famc = indi.children.firstWhere((e) => e.tag == 'FAMC');
      expect(famc.value, '@2@');
      final pedi = famc.children.firstWhere((e) => e.tag == 'PEDI');
      expect(pedi.value, 'BIRTH');

      // FAM @2@ has CHIL @1@ linking back
      final fam = root.children.whereType<FamilyElement>().first;
      expect(fam.pointer, '@2@');
      final chil = fam.children.firstWhere((e) => e.tag == 'CHIL');
      expect(chil.value, '@1@');
    });

    test('parses rela_1.ged', () {
      final root = parseFile('rela_1.ged');
      expect(root.children.length, 5);

      final individuals = root.children.whereType<IndividualElement>().toList();
      expect(individuals.length, 2);

      // First INDI @I1@ has one ASSO to @I2@ as NGHBR
      final indi1 = individuals.firstWhere((e) => e.pointer == '@I1@');
      final asso1 = indi1.children.where((e) => e.tag == 'ASSO').toList();
      expect(asso1.length, 1);
      expect(asso1[0].value, '@I2@');
      final role1 = asso1[0].children.firstWhere((e) => e.tag == 'ROLE');
      expect(role1.value, 'NGHBR');
      final phrase1 = role1.children.firstWhere((e) => e.tag == 'PHRASE');
      expect(phrase1.value, 'neighbor');

      // Second INDI @I2@ has two ASSO entries
      final indi2 = individuals.firstWhere((e) => e.pointer == '@I2@');
      final asso2 = indi2.children.where((e) => e.tag == 'ASSO').toList();
      expect(asso2.length, 2);

      // First ASSO: ROLE OTHER with PHRASE land-lord
      expect(asso2[0].value, '@I1@');
      final role2a = asso2[0].children.firstWhere((e) => e.tag == 'ROLE');
      expect(role2a.value, 'OTHER');
      final phrase2a = role2a.children.firstWhere((e) => e.tag == 'PHRASE');
      expect(phrase2a.value, 'land-lord');

      // Second ASSO: ROLE FRIEND with NOTE
      expect(asso2[1].value, '@I2@');
      final role2b = asso2[1].children.firstWhere((e) => e.tag == 'ROLE');
      expect(role2b.value, 'FRIEND');
      final assoNote = asso2[1].children.firstWhere((e) => e.tag == 'NOTE');
      expect(assoNote.value, contains('own friend'));
    });

    test('parses sour-1.ged', () {
      final root = parseFile('sour-1.ged');
      expect(root.children.length, 7);

      final sources = root.children.where((e) => e.tag == 'SOUR').toList();
      expect(sources.length, 3);

      // Inline source @X1@ has NOTE
      final sourX1 = sources.firstWhere((e) => e.pointer == '@X1@');
      final noteX1 = sourX1.children.firstWhere((e) => e.tag == 'NOTE');
      expect(noteX1.value, 'A source described inline');

      // INDI @1@ references sources
      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@1@');
      final indiSources = indi.children.where((e) => e.tag == 'SOUR').toList();
      expect(indiSources.length, 3);
      expect(indiSources[0].value, '@X1@');
      expect(indiSources[1].value, '@X2@');
      expect(indiSources[2].value, '@2@');

      // First SOUR citation has DATA with TEXT and QUAY
      final data0 = indiSources[0].children.firstWhere((e) => e.tag == 'DATA');
      final texts = data0.children.where((e) => e.tag == 'TEXT').toList();
      expect(texts.length, greaterThanOrEqualTo(1));
      final quay = indiSources[0].children.firstWhere((e) => e.tag == 'QUAY');
      expect(quay.value, '1');

      // Shared SOUR @2@ has AUTH, TITL, TEXT, CHAN
      final sour2 = sources.firstWhere((e) => e.pointer == '@2@');
      final auth = sour2.children.firstWhere((e) => e.tag == 'AUTH');
      expect(auth.value, "Luther's imagination");
      final titl = sour2.children.firstWhere((e) => e.tag == 'TITL');
      expect(titl.value, 'Example birth and christening source');
      final chan = sour2.children.firstWhere((e) => e.tag == 'CHAN');
      final chanDate = chan.children.whereType<DateElement>().first;
      expect(chanDate.value, '18 JUN 2021');
      expect(chanDate.date, DateTime(2021, 6, 18));
    });

    test('parses tiny-1.ged', () {
      final root = parseFile('tiny-1.ged');
      expect(root.children.length, 2);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final gedc = head.children.firstWhere((e) => e.tag == 'GEDC');
      final vers = gedc.children.firstWhere((e) => e.tag == 'VERS');
      expect(vers.value, '7.0');

      // Only HEAD and TRLR
      expect(root.children[0].tag, 'HEAD');
      expect(root.children[1].tag, 'TRLR');
    });

    test('parses xref-case.ged', () {
      final root = parseFile('xref-case.ged');
      expect(root.children.length, 5);

      // HEAD references @VOID@ SUBM (non-existent)
      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final submRef = head.children.firstWhere((e) => e.tag == 'SUBM');
      expect(submRef.value, '@VOID@');

      // SUBM @TEST@ has SNOTE references
      final subm = root.children.firstWhere((e) => e.tag == 'SUBM');
      expect(subm.pointer, '@TEST@');
      final snoteRefs = subm.children.where((e) => e.tag == 'SNOTE').toList();
      expect(snoteRefs.length, 2);
      expect(snoteRefs[0].value, '@X1@');
      expect(snoteRefs[1].value, '@X2@');

      // SNOTE records
      final snotes = root.children.where((e) => e.tag == 'SNOTE').toList();
      expect(snotes.length, 2);
      expect(snotes[0].pointer, '@X1@');
      expect(snotes[0].value, 'mixed case');
      expect(snotes[1].pointer, '@X2@');
      expect(snotes[1].value, 'mixed case and space');
    });
  });
}
