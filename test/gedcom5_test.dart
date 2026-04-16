import 'dart:io';

import 'package:gedcom/gedcom.dart';
import 'package:test/test.dart';

import 'samples/v5/torture.dart';

void main() {
  test('parses input data', () {
    final parser = Gedcom5Parser();
    final root = parser.parse(testData);
    expect(root, isA<RootElement>());
    expect(root.children.first, isA<IndividualElement>());
    final ind = root.children.first as IndividualElement;
    expect(ind.name.givenName, equals('Thomas Trask'));
  });

  test('parses torture input data', () {
    final parser = Gedcom5Parser();
    final root = parser.parse(v5tortureTest1);
    // ignore: avoid_print
    print(root.toGedcomString());
    expect(root, isA<RootElement>());
    expect(root.children[63], isA<ObjectElement>());
    expect(root.children[63].children[0].tag, equals('TITL'));
  });

  test('returns list of elements', () {
    final parser = Gedcom5Parser();
    final root = parser.parse(v5tortureTest1);
    final list = parser.getElementsList(root);
    expect(list.length, equals(2161));
  });

  test('returns map of elements by pointer', () {
    final parser = Gedcom5Parser();
    final root = parser.parse(v5tortureTest1);
    final map = parser.getElementsMap(root);
    expect(map.entries.length, equals(63));
    expect(map['@PERSON6@'], isA<IndividualElement>());
  });

  test('returns families of individual', () {
    final parser = Gedcom5Parser();
    final root = parser.parse(v5tortureTest1);
    final map = parser.getElementsMap(root);
    final families1 =
        parser.getFamilies(map['@PERSON4@'] as IndividualElement?, map);
    final families2 =
        parser.getFamilies(map['@PERSON5@'] as IndividualElement?, map);
    final families3 =
        parser.getFamilies(map['@PERSON6@'] as IndividualElement?, map);
    expect(families1, isEmpty);
    expect(families2.length, equals(1));
    expect(families3.length, equals(1));
  });

  test('returns families of individual as child', () {
    final parser = Gedcom5Parser();
    final root = parser.parse(v5tortureTest1);
    final map = parser.getElementsMap(root);
    final families1 = parser.getFamilies(
      map['@PERSON4@'] as IndividualElement?,
      map,
      relation: FamilyRelation.child,
    );
    expect(families1, isNotEmpty);
    expect(families1.first!.children.length, equals(24));
  });

  group('Gedcom 5.5.1 test-files', () {
    RootElement parseFile(String filename) {
      final file = File('test/samples/test-files/5/$filename');
      final content = file.readAsStringSync();
      return GedcomParser().parse(content);
    }

    test('parses age-invalid.ged', () {
      final root = parseFile('age-invalid.ged');
      expect(root.children.length, 4);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final gedc = head.children.firstWhere((e) => e.tag == 'GEDC');
      final vers = gedc.children.firstWhere((e) => e.tag == 'VERS');
      expect(vers.value, '5.5.1');
      final charTag = head.children.firstWhere((e) => e.tag == 'CHAR');
      expect(charTag.value, 'UTF-8');

      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@SIMPLE@');

      final events = indi.children.where((e) => e.tag == 'EVEN').toList();
      expect(events.length, greaterThan(50));

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

      // In v5, AGE values are kept as-is (not normalized like v7)
      final firstEvent = events.first;
      expect(firstEvent.value, 'when 0');
      final firstAge = firstEvent.children.firstWhere((e) => e.tag == 'AGE');
      expect(firstAge.value, '0');
    });

    test('parses age-valid.ged', () {
      final root = parseFile('age-valid.ged');
      expect(root.children.length, 4);

      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@SIMPLE@');

      final events = indi.children.where((e) => e.tag == 'EVEN').toList();
      expect(events.length, greaterThan(30));

      // In v5, AGE uses keyword values directly (child, infant, stillborn)
      final childEvent = events.firstWhere((e) => e.value == 'when child');
      final childAge = childEvent.children.firstWhere((e) => e.tag == 'AGE');
      expect(childAge.value, 'child');

      final stillbornEvent =
          events.firstWhere((e) => e.value == 'when stillborn');
      final stillbornAge =
          stillbornEvent.children.firstWhere((e) => e.tag == 'AGE');
      expect(stillbornAge.value, 'stillborn');
    });

    test('parses atsign.ged', () {
      final root = parseFile('atsign.ged');
      expect(root.children.length, 22);

      final notes = root.children.where((e) => e.tag == 'NOTE').toList();
      expect(notes.length, 19);

      // Verify specific NOTE pointers and values
      expect(notes[0].pointer, '@N01@');
      expect(notes[0].value, contains('leading'));

      expect(notes[4].pointer, '@N05@');
      expect(notes[4].value, contains('internal'));

      // Last NOTE has CONC and CONT
      final lastNote = notes.last;
      expect(lastNote.pointer, '@N19@');
      final conc = lastNote.children.firstWhere((e) => e.tag == 'CONC');
      expect(conc, isNotNull);
      final cont = lastNote.children.firstWhere((e) => e.tag == 'CONT');
      expect(cont, isNotNull);
      expect(cont.value, contains('CONT'));
    });

    test('parses char_ascii_1.ged', () {
      final root = parseFile('char_ascii_1.ged');
      expect(root.children.length, 3);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final sour = head.children.firstWhere((e) => e.tag == 'SOUR');
      expect(sour.value, 'conversion test');
      final charTag = head.children.firstWhere((e) => e.tag == 'CHAR');
      expect(charTag.value, 'ASCII');

      final subm = root.children.firstWhere((e) => e.tag == 'SUBM');
      final name = subm.children.firstWhere((e) => e.tag == 'NAME');
      expect(name.value, 'Luther Tychonievich');
    });

    test('parses char_ascii_2.ged', () {
      final root = parseFile('char_ascii_2.ged');
      expect(root.children.length, 3);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final charTag = head.children.firstWhere((e) => e.tag == 'CHAR');
      expect(charTag.value, 'LATIN1');

      final subm = root.children.firstWhere((e) => e.tag == 'SUBM');
      final name = subm.children.firstWhere((e) => e.tag == 'NAME');
      expect(name.value, 'Luther Tychonievich');
    });

    test('parses char_utf8-1.ged', () {
      final root = parseFile('char_utf8-1.ged');
      expect(root.children.length, 3);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final charTag = head.children.firstWhere((e) => e.tag == 'CHAR');
      expect(charTag.value, 'UTF-8');
      final note = head.children.firstWhere((e) => e.tag == 'NOTE');
      expect(note.value, contains('UTF-8 without BOM'));
      expect(note.value, contains('¶'));
      expect(note.value, contains('☺'));
    });

    test('parses char_utf8-2.ged', () {
      final root = parseFile('char_utf8-2.ged');
      expect(root.children.length, 3);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final charTag = head.children.firstWhere((e) => e.tag == 'CHAR');
      expect(charTag.value, 'UNICODE');
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

      final pointers = individuals.map((e) => e.pointer).toList();
      expect(pointers, contains('@SIMPLE@'));
      expect(pointers, contains('@CALENDAR@'));
      expect(pointers, contains('@PERIOD@'));
      expect(pointers, contains('@APPROXIMATE@'));
      expect(pointers, contains('@RANGE@'));
      expect(pointers, contains('@CLOSED_RANGE@'));
      expect(pointers, contains('@CLOSED_PERIOD@'));

      // SIMPLE individual should have BIRT with DATE
      final simple = individuals.firstWhere((e) => e.pointer == '@SIMPLE@');
      final births = simple.children.whereType<BirthElement>().toList();
      expect(births, isNotEmpty);

      // Year-only date: "1401" -> DateTime(1401)
      final date1401 = births[0].children.whereType<DateElement>().first;
      expect(date1401.value, '1401');
      expect(date1401.date, DateTime(1401));

      // Dual year: "1401/8" is kept as-is in v5 -> not parseable
      final dateDual = births[1].children.whereType<DateElement>().first;
      expect(dateDual.value, '1401/8');
      expect(dateDual.date, isNull);

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

      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@1@');

      final births = indi.children.whereType<BirthElement>().toList();
      expect(births.length, 84);

      // Each BIRT should have NOTE and DATE
      for (final birth in births) {
        final dateElements = birth.children.whereType<DateElement>().toList();
        expect(
          dateElements.length,
          1,
          reason: 'Each BIRT should have one DATE',
        );
        final noteElements =
            birth.children.where((e) => e.tag == 'NOTE').toList();
        expect(
          noteElements.length,
          1,
          reason: 'Each BIRT should have one NOTE',
        );
      }

      // v5 keeps dual dates as-is: "1701/99" -> not parseable
      final firstDate = births.first.children.whereType<DateElement>().first;
      expect(firstDate.value, '1701/99');
      expect(firstDate.date, isNull);

      // "JAN 1701/99" has extra tokens -> not parseable
      final secondDate = births[1].children.whereType<DateElement>().first;
      expect(secondDate.value, 'JAN 1701/99');
      expect(secondDate.date, isNull);
    });

    test('parses date-dual-valid.ged', () {
      final root = parseFile('date-dual-valid.ged');
      expect(root.children.length, 4);

      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@1@');

      final births = indi.children.whereType<BirthElement>().toList();
      expect(births.length, 11);

      // Dual year dates in v5 are not parseable
      final firstDate = births.first.children.whereType<DateElement>().first;
      expect(firstDate.value, '1699/00');
      expect(firstDate.date, isNull);

      // "JAN 1699/00" -> not parseable due to extra /00
      final secondDate = births[1].children.whereType<DateElement>().first;
      expect(secondDate.value, 'JAN 1699/00');
      expect(secondDate.date, isNull);
    });

    test('parses enum-ext.ged', () {
      final root = parseFile('enum-ext.ged');
      expect(root.children.length, 7);

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
      // In v5, TYPE is directly under NAME (no PHRASE sublevel)
      final nameType1 = names[1].children.firstWhere((e) => e.tag == 'TYPE');
      expect(nameType1.value, 'Screen');

      // Custom _LOC record is parsed
      final loc = root.children.firstWhere((e) => e.tag == '_LOC');
      expect(loc.pointer, '@3@');
      final locType = loc.children.firstWhere((e) => e.tag == 'TYPE');
      expect(locType.value, 'Example');
      final locName = loc.children.firstWhere((e) => e.tag == 'NAME');
      expect(locName.value, 'New York');
    });

    test('parses filename-1.ged', () {
      final root = parseFile('filename-1.ged');
      expect(root.children.length, 4);

      // HEAD has FILE tag with the filename
      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final headFile = head.children.whereType<FileElement>().first;
      expect(headFile.value, 'somename.ged');

      final obje = root.children.whereType<ObjectElement>().first;
      expect(obje.pointer, '@1@');

      final files = obje.children.whereType<FileElement>().toList();
      expect(files.length, 9);

      // v5 uses OS-native paths rather than URIs
      expect(files[0].value, '/unix/absolute');
      expect(files[1].value, r'c:\windows\absolute');
      expect(files[2].value, r'\\windows\server');
      expect(files[3].value, 'a/relative/path');
      expect(files[4].value, r'a\relative\path');
      expect(files[7].value, 'https://leave.alone?with=args#and-frags');

      // Each FILE should have a FORM child with v5 format values
      for (final file in files) {
        final form = file.children.firstWhere((e) => e.tag == 'FORM');
        expect(form.value, 'bmp');
      }
    });

    test('parses lang-all.ged', () {
      final root = parseFile('lang-all.ged');
      expect(root.children.length, 7);

      // HEAD LANG uses full language name in v5
      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final lang = head.children.firstWhere((e) => e.tag == 'LANG');
      expect(lang.value, 'Afrikaans');

      // SUBM has multiple LANG entries with full names
      final subm = root.children.firstWhere((e) => e.tag == 'SUBM');
      final submLangs = subm.children.where((e) => e.tag == 'LANG').toList();
      expect(submLangs.length, 3);
      expect(submLangs[0].value, 'English');
      expect(submLangs[1].value, 'Japanese');
      expect(submLangs[2].value, 'Spanish');

      // _ALL_LANGUAGES has many LANG entries
      final allLangs = root.children.firstWhere((e) => e.pointer == '@2@');
      final langEntries =
          allLangs.children.where((e) => e.tag == 'LANG').toList();
      expect(langEntries.length, greaterThan(70));

      // _WRONG_CASE tests case sensitivity
      final wrongCase = root.children.firstWhere((e) => e.pointer == '@3@');
      final wrongCaseLangs =
          wrongCase.children.where((e) => e.tag == 'LANG').toList();
      expect(wrongCaseLangs.length, 2);
      expect(wrongCaseLangs[0].value, 'serbo_croa');
      expect(wrongCaseLangs[1].value, 'ENGlish');

      // _LANGUAGE_NOT_IN_551 tests non-standard language
      final nonStd = root.children.firstWhere((e) => e.pointer == '@5@');
      final hmong = nonStd.children.firstWhere((e) => e.tag == 'LANG');
      expect(hmong.value, 'Hmong');
    });

    test('parses notes-1.ged', () {
      final root = parseFile('notes-1.ged');
      expect(root.children.length, 7);

      // Header has inline NOTE
      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final headerNote = head.children.firstWhere((e) => e.tag == 'NOTE');
      expect(headerNote.value, 'The header note');

      // SUBM has inline NOTE and NOTE reference (v5 uses NOTE @ptr@)
      final subm = root.children.firstWhere((e) => e.tag == 'SUBM');
      final submNotes = subm.children.where((e) => e.tag == 'NOTE').toList();
      expect(submNotes.length, 2);
      expect(submNotes[0].value, 'An inline submission note');
      expect(submNotes[1].value, '@4@');

      // SOUR has three NOTE references
      final sour = root.children.where((e) => e.tag == 'SOUR').first;
      final sourNotes = sour.children.where((e) => e.tag == 'NOTE').toList();
      expect(sourNotes.length, 3);
      expect(sourNotes[0].value, '@3@');
      expect(sourNotes[1].value, '@4@');
      expect(sourNotes[2].value, '@5@');

      // Shared NOTE records (v5 uses NOTE instead of SNOTE)
      final noteRecords =
          root.children.where((e) => e.tag == 'NOTE' && e.level == 0).toList();
      expect(noteRecords.length, 3);
      expect(noteRecords[0].pointer, '@3@');
      expect(noteRecords[0].value, 'A single-use note record');
      expect(noteRecords[1].pointer, '@4@');
      expect(noteRecords[1].value, 'A dual-use note record');
      expect(noteRecords[2].pointer, '@5@');
      expect(noteRecords[2].value, 'A cyclic note record');

      // NOTE @3@ has CHAN with DATE
      final chan3 = noteRecords[0].children.firstWhere((e) => e.tag == 'CHAN');
      final date3 = chan3.children.whereType<DateElement>().first;
      expect(date3.value, '25 MAY 2021');
      expect(date3.date, DateTime(2021, 5, 25));

      // Cyclic NOTE @5@ references SOUR @2@
      final cyclicSour =
          noteRecords[2].children.firstWhere((e) => e.tag == 'SOUR');
      expect(cyclicSour.value, '@2@');
    });

    test('parses obje-1.ged', () {
      final root = parseFile('obje-1.ged');
      expect(root.children.length, 4);

      // First OBJE has media files
      final obje = root.children.whereType<ObjectElement>().first;
      expect(obje.pointer, '@1@');
      final files = obje.children.whereType<FileElement>().toList();
      expect(files.length, 2);
      expect(files[0].value, 'example.jpg');
      final form0 = files[0].children.firstWhere((e) => e.tag == 'FORM');
      expect(form0.value, 'jpg');
      // In v5, TYPE is under FORM (not MEDI)
      final type0 = form0.children.firstWhere((e) => e.tag == 'TYPE');
      expect(type0.value, 'photo');
      expect(files[1].value, 'example.wav');
      final form1 = files[1].children.firstWhere((e) => e.tag == 'FORM');
      expect(form1.value, 'wav');

      // NOTE in OBJE record
      final objeNote = obje.children.firstWhere((e) => e.tag == 'NOTE');
      expect(objeNote.value, 'note in OBJE record');

      // INDI references OBJE by pointer and inline
      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@2@');
      final objeRefs = indi.children.where((e) => e.tag == 'OBJE').toList();
      expect(objeRefs.length, 2);
      expect(objeRefs[0].value, '@1@');
      // Second OBJE is inline with FILE children
      final inlineFiles =
          objeRefs[1].children.whereType<FileElement>().toList();
      expect(inlineFiles.length, 2);
      expect(inlineFiles[0].value, 'gifts.webm');
      expect(inlineFiles[1].value, 'cake.webm');
      final titl = objeRefs[1].children.firstWhere((e) => e.tag == 'TITL');
      expect(titl.value, 'fifth birthday party');
    });

    test('parses obsolete-1.ged', () {
      final root = parseFile('obsolete-1.ged');
      expect(root.children.length, 4);

      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final gedc = head.children.firstWhere((e) => e.tag == 'GEDC');
      final vers = gedc.children.firstWhere((e) => e.tag == 'VERS');
      expect(vers.value, '5.5.1');

      // HEAD has SUBN reference
      final subnRef = head.children.firstWhere((e) => e.tag == 'SUBN');
      expect(subnRef.value, '@submission@');

      // SUBN record with obsolete fields
      final subn = root.children.firstWhere((e) => e.tag == 'SUBN');
      expect(subn.pointer, '@submission@');
      final famf = subn.children.firstWhere((e) => e.tag == 'FAMF');
      expect(famf.value, 'Example file');
      final ance = subn.children.firstWhere((e) => e.tag == 'ANCE');
      expect(ance.value, '0');
      final desc = subn.children.firstWhere((e) => e.tag == 'DESC');
      expect(desc.value, '0');
      final ordi = subn.children.firstWhere((e) => e.tag == 'ORDI');
      expect(ordi.value, 'no');
      final rin = subn.children.firstWhere((e) => e.tag == 'RIN');
      expect(rin.value, '12345');
    });

    test('parses pedi-1.ged', () {
      final root = parseFile('pedi-1.ged');
      expect(root.children.length, 5);

      // HEAD has NOTE about the test
      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final note = head.children.firstWhere((e) => e.tag == 'NOTE');
      expect(note.value, 'Test for bug identified by Diedrich');

      // INDI @1@ with FAMC @2@ and PEDI birth (lowercase in v5)
      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@1@');
      final famc = indi.children.firstWhere((e) => e.tag == 'FAMC');
      expect(famc.value, '@2@');
      final pedi = famc.children.firstWhere((e) => e.tag == 'PEDI');
      expect(pedi.value, 'birth');

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

      // @I1@ has one ASSO to @I2@ with RELA neighbor (v5 uses RELA not ROLE)
      final indi1 = individuals.firstWhere((e) => e.pointer == '@I1@');
      final asso1 = indi1.children.where((e) => e.tag == 'ASSO').toList();
      expect(asso1.length, 1);
      expect(asso1[0].value, '@I2@');
      final rela1 = asso1[0].children.firstWhere((e) => e.tag == 'RELA');
      expect(rela1.value, 'neighbor');

      // @I2@ has two ASSO entries
      final indi2 = individuals.firstWhere((e) => e.pointer == '@I2@');
      final asso2 = indi2.children.where((e) => e.tag == 'ASSO').toList();
      expect(asso2.length, 2);

      expect(asso2[0].value, '@I1@');
      final rela2a = asso2[0].children.firstWhere((e) => e.tag == 'RELA');
      expect(rela2a.value, 'land-lord');

      expect(asso2[1].value, '@I2@');
      final rela2b = asso2[1].children.firstWhere((e) => e.tag == 'RELA');
      expect(rela2b.value, 'friend');
      final assoNote = asso2[1].children.firstWhere((e) => e.tag == 'NOTE');
      expect(assoNote.value, contains('own friend'));
    });

    test('parses sour-1.ged', () {
      final root = parseFile('sour-1.ged');
      expect(root.children.length, 5);

      // INDI @1@ has inline and linked SOUR references
      final indi = root.children.whereType<IndividualElement>().first;
      expect(indi.pointer, '@1@');
      final indiSources = indi.children.where((e) => e.tag == 'SOUR').toList();
      expect(indiSources.length, 3);

      // In v5, inline SOUR has text value directly
      expect(indiSources[0].value, 'A source described inline');
      expect(indiSources[1].value, 'Another source described inline');

      // Linked SOUR uses pointer reference
      expect(indiSources[2].value, '@2@');
      final page = indiSources[2].children.firstWhere((e) => e.tag == 'PAGE');
      expect(page.value, '23');
      final quay = indiSources[2].children.firstWhere((e) => e.tag == 'QUAY');
      expect(quay.value, '2');

      // First inline SOUR has TEXT and QUAY children
      final texts0 =
          indiSources[0].children.where((e) => e.tag == 'TEXT').toList();
      expect(texts0.length, greaterThanOrEqualTo(1));
      final quay0 = indiSources[0].children.firstWhere((e) => e.tag == 'QUAY');
      expect(quay0.value, '1');

      // Shared SOUR @2@ has AUTH, TITL, TEXT, CHAN
      final sour2 = root.children
          .where((e) => e.tag == 'SOUR' && e.pointer == '@2@')
          .first;
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

      // Only HEAD and TRLR - minimal valid GEDCOM 5
      expect(root.children[0].tag, 'HEAD');
      expect(root.children[1].tag, 'TRLR');
    });

    test('parses xref-case.ged', () {
      final root = parseFile('xref-case.ged');
      expect(root.children.length, 5);

      // HEAD references @test@ (lowercase) SUBM
      final head = root.children.firstWhere((e) => e.tag == 'HEAD');
      final submRef = head.children.firstWhere((e) => e.tag == 'SUBM');
      expect(submRef.value, '@test@');

      // SUBM @TEST@ (uppercase pointer) has NOTE references
      final subm = root.children.firstWhere((e) => e.tag == 'SUBM');
      expect(subm.pointer, '@TEST@');
      final noteRefs = subm.children.where((e) => e.tag == 'NOTE').toList();
      expect(noteRefs.length, 2);
      expect(noteRefs[0].value, '@NoTe@');
      expect(noteRefs[1].value, '@NoTe ref@');

      // NOTE records with mixed-case pointers
      final noteRecords =
          root.children.where((e) => e.tag == 'NOTE' && e.level == 0).toList();
      expect(noteRecords.length, 2);
      expect(noteRecords[0].pointer, '@NoTe@');
      expect(noteRecords[0].value, 'mixed case');
      expect(noteRecords[1].pointer, '@NoTe ref@');
      expect(noteRecords[1].value, 'mixed case and space');
    });
  });
}

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
