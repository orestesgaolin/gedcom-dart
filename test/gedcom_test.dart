import 'package:gedcom/gedcom.dart';
import 'package:test/test.dart';

void main() {
  test('parses input data', () {
    final parser = GedcomParser();
    final root = parser.parse(testData);
    expect(root, isA<RootElement>());
    expect(root.children.first, isA<IndividualElement>());
    final ind = root.children.first as IndividualElement;
    expect(ind.name.givenName, equals('Thomas Trask'));
  });

  test('parses torture input data', () {
    final parser = GedcomParser();
    final root = parser.parse(tortureTest1);
    // ignore: avoid_print
    print(root.toGedcomString());
    expect(root, isA<RootElement>());
    expect(root.children[63], isA<ObjectElement>());
    expect(root.children[63].children[0].tag, equals('TITL'));
  });

  test('returns list of elements', () {
    final parser = GedcomParser();
    final root = parser.parse(tortureTest1);
    final list = parser.getElementsList(root);
    expect(list.length, equals(2161));
  });

  test('returns map of elements by pointer', () {
    final parser = GedcomParser();
    final root = parser.parse(tortureTest1);
    final map = parser.getElementsMap(root);
    expect(map.entries.length, equals(63));
    expect(map['@PERSON6@'], isA<IndividualElement>());
  });

  test('returns families of individual', () {
    final parser = GedcomParser();
    final root = parser.parse(tortureTest1);
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
    final parser = GedcomParser();
    final root = parser.parse(tortureTest1);
    final map = parser.getElementsMap(root);
    final families1 = parser.getFamilies(
      map['@PERSON4@'] as IndividualElement?,
      map,
      relation: FamilyRelation.child,
    );
    expect(families1, isNotEmpty);
    expect(families1.first!.children.length, equals(24));
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

const tortureTest1 = '''
0 HEAD
1 SOUR GEDitCOM
2 NAME GEDitCOM
2 VERS 2.9.4
2 CORP RSAC Software
3 ADDR 7108 South Pine Cone Street
4 CONT Salt Lake City, UT 84121
4 CONT USA
4 ADR1 RSAC Software
4 ADR2 7108 South Pine Cone Street
4 CITY Salt Lake City
4 STAE UT
4 POST 84121
4 CTRY USA
3 PHON +1-801-942-7768
3 PHON +1-801-555-1212
3 PHON +1-801-942-1148 (FAX) (last one!)
2 DATA Name of source data
3 DATE 1 JAN 1998
3 COPR Copyright of source data
1 SUBM @SUBMITTER@
1 SUBN @SUBMISSION@
1 _HME @PERSON1@
1 DEST ANSTFILE
1 DATE 1 JAN 1998
2 TIME 13:57:24.80
1 FILE TGC55C.ged
1 COPR � 1997 by H. Eichmann, parts � 1999-2000 by J. A. Nairn.
1 GEDC
2 VERS 5.5
2 FORM LINEAGE-LINKED
1 LANG English
1 CHAR ANSEL
2 VERS ANSI Z39.47-1985
1 PLAC
2 FORM City, County, State, Country
1 NOTE This file demonstrates all tags that are allowed in GEDCOM 5.5. Here are some comments about the HEADER record
2 CONC and comments about where to look for information on the other 9 types of GEDCOM records. Most other records will
2 CONC have their own notes that describe what to look for in that record and what to hope the importing software will find.
2 CONT
2 CONT Many applications will fail to import these notes. The notes are therefore also provided with the files as a plain-text
2 CONC "Read-Me" file.
2 CONT
2 CONT --------------------------
2 CONT The HEADER Record:
2 CONT      This record has all possible tags for a HEADER record. In uses one custom tag ("_HME") to see what the software
2 CONC will say about custom tags.
2 CONT
2 CONT --------------------------
2 CONT INDIVIDUAL Records:
2 CONT      This file has a small number of INDIVIDUAL records. The record named "Joseph Tag Torture" has all possible
2 CONC tags for an INDIVIDUAL record. All remaining  individuals have less tags. Some test specific features; for example:
2 CONT
2 CONT      Name: Standard GEDCOM Filelinks
2 CONT      Name: Nonstandard Multimedia Filelinks
2 CONT      Name: General Custom Filelinks
2 CONT      Name: Extra URL Filelinks
2 CONT           These records link to multimedia files mentioned by the GEDCOM standard and to a variety of other types of
2 CONC multimedia files, general files, or URL names.
2 CONT
2 CONT      Name: Chris Locked Torture
2 CONT           Has a "locked" restriction (RESN) tag - should not be able to edit this record it. This record has one set of notes
2 CONC that is used to test line breaking in notes and a few other text-parsing features of the GEDCOM software. Read those
2 CONC notes to see what they are testing.
2 CONT
2 CONT      Name: Sandy Privacy Torture
2 CONT           Has a "privacy" restriction (RESN) tag. Is the tag recognized and how is the record displayed and/or printed?
2 CONT
2 CONT      Name: Chris Locked Torture
2 CONT      Name: Sandy Privacy Torture
2 CONT      Name: Pat Smith Torture
2 CONT           The three children in this file have unknown sex (no SEX tag). An ancestor tree from each should give five
2 CONC generations of ancestors.
2 CONT
2 CONT      Name: Charlie Accented ANSEL
2 CONT      Name: Lucy Special ANSEL
2 CONT           The notes in these records use all possible special characters in the ANSEL character set. The header of this file
2 CONC denotes this file as using the ANSEL character set. The importing software should handle these special characters in a
2 CONC reasonable way.
2 CONT
2 CONT      Name: Torture GEDCOM Matriarch
2 CONT            All individuals in this file are related and all are descendants (or spouses of descendants) of Torture GEDCOM
2 CONC Matriarch. A descendant tree or report from this individual should show five generations of descendants.
2 CONT
2 CONT --------------------------
2 CONT FAMILY Records:
2 CONT      The FAMILY record for "Joseph Tag Torture" (husband) and "Mary First Jones" (wife) has all tags allowed in
2 CONC family records. All other family records use only a few tags and are used to provide records for extra family links in
2 CONC other records.
2 CONT
2 CONT --------------------------
2 CONT SOURCE Records:
2 CONT      There are two SOURCE records in this file. The "Everything You Every Wanted to Know about GEDCOM Tags"
2 CONC source has all possible GEDCOM tags for a SOURCE record. The other source only has only a few tags.
2 CONT
2 CONT --------------------------
2 CONT REPOSITORY Record:
2 CONT      There is just one REPOSITORY record and it uses all possible tags for such a record.
2 CONT
2 CONT --------------------------
2 CONT SUBMITTER Records:
2 CONT      This file has three SUBMITTER records. The "John A. Nairn" record has all tags allowed in such records. The
2 CONC second and third submitter are to test how programs input files with multiple submitters. The GEDCOM standard does
2 CONC not allow for notes in SUBMITTER records. Look in the "Main Submitter" to verify all address data comes through,
2 CONC that all three phone numbers appear, and that the multimedia file link is preserved.
2 CONT
2 CONT --------------------------
2 CONT MULTIMEDIA OBJECT Record:
2 CONT      The one MULTIMEDIA record has all possible tags and even has encoded data for a small image of a flower. There
2 CONC are no known GEDCOM programs that can read or write such records. The record is included here to test how
2 CONC programs might respond to finding multimedia records present. There are possible plans to eliminate encoded
2 CONC multimedia objects in the next version of GEDCOM. In the future all multimedia will be included by links to other files.
2 CONC To test current file links and extended file links, see the "Filelinks" family records described above.
2 CONT
2 CONT --------------------------
2 CONT SUBMISSION Record:
2 CONT      The one (maximum allowed) SUBMISSION record in this file has all possible tags for such a record.
2 CONT
2 CONT --------------------------
2 CONT NOTE Records:
2 CONT      This file has many NOTE records. These are all linked to other records.
2 CONT
2 CONT --------------------------
2 CONT TRLR Records:
2 CONT      This file ends in the standard TRLR record.
2 CONT
2 CONT --------------------------
2 CONT ADDITIONAL NOTES
2 CONT      This file was originally created by H. Eichmann at <h.eichmann@@mbox.iqo.uni-hannover.de> and posted on the
2 CONC Internet.
2 CONT
2 CONT (NOTE: email addresses are listed here with double "at" signs. A rule of GEDCOM parsing is that these should be
2 CONC converted to single "at" at signs, but not many programs follow that rule. In addition, that rule is not needed and may be
2 CONC abandoned in a future version of GEDCOM).
2 CONT
2 CONT This original file was extensively modified by J. A. Nairn using GEDitCOM 2.9.4 (1999-2001) at
2 CONC <support@@geditcom.com> and posted on the Internet at <http://www.geditcom.com>. Some changes included many
2 CONC more notes, the use or more tags, extensive testing of multimedia file links, and some notes to test all special ANSEL
2 CONC characters.
2 CONT
2 CONT Feel free to copy and use this GEDCOM file for any  non-commercial purpose.
2 CONT
2 CONT For selecting the allowed tags, the GEDCOM standard Release 5.5 (2 JAN 1996) was used. Copyright: The Church of
2 CONC Jesus Christ of Latter-Day Saints, <gedcom@@gedcom.org>.
2 CONT
2 CONT You can download the GEDCOM 5.5 specs from: <ftp.gedcom.com/pub/genealogy/gedcom>. You can read the
2 CONC GEDCOM 5.5 specs on the Internet at <http://homepages.rootsweb.com/~pmcbride/gedcom/55gctoc.htm>.
0 @SUBMISSION@ SUBN
1 SUBM @SUBMITTER@
1 FAMF NameOfFamilyFile
1 TEMP Abbreviated Temple Code
1 ANCE 1
1 DESC 1
1 ORDI yes
1 RIN 1
0 @SUBMITTER@ SUBM
1 NAME John A. Nairn
1 ADDR Submitter address line 1
2 CONT Submitter address line 2
2 CONT Submitter address line 3
2 CONT Submitter address line 4
2 ADR1 Submitter address line 1
2 ADR2 Submitter address line 2
2 CITY Submitter address city
2 STAE Submitter address state
2 POST Submitter address ZIP code
2 CTRY Submitter address country
1 PHON Submitter phone number 1
1 PHON Submitter phone number 2
1 PHON Submitter phone number 3 (last one!)
1 LANG English
1 OBJE
2 FORM jpeg
2 TITL Submitter Multimedia File
2 FILE ImgFile.JPG
2 NOTE @N1@
1 RFN Submitter Registered RFN
1 RIN 1
1 CHAN
2 DATE 7 Sep 2000
3 TIME 8:35:36
0 @SM2@ SUBM
1 NAME Secondary Submitter
1 ADDR Secondary Submitter Address 1
2 CONT Secondary Submitter Address 2
1 LANG English
1 CHAN
2 DATE 12 Mar 2000
3 TIME 10:38:33
1 RIN 2
0 @SM3@ SUBM
1 NAME H. Eichmann
1 ADDR email: h.eichmann@@mbox.iqo.uni-hannover.de
2 CONT or: heiner_eichmann@@h.maus.de (no more than 16k!!!!)
1 CHAN
2 DATE 13 Jun 2000
3 TIME 17:07:32
1 RIN 3
0 @I14@ INDI
1 NAME Charlie Accented /ANSEL/
1 SEX M
1 BIRT
2 DATE 15 JUN 1900
1 DEAT
2 DATE 5 JUL 1974
1 FAMS @F6@
1 FAMC @F7@
1 NOTE @N24@
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:00:06
1 RIN 1
0 @I13@ INDI
1 NAME Lucy Special /ANSEL/
1 SEX F
1 BIRT
2 DATE 12 AUG 1905
1 DEAT
2 DATE 31 DEC 1990
1 FAMS @F6@
1 NOTE @N25@
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:00:23
1 RIN 2
0 @PERSON6@ INDI
1 NAME Teresa Mary /Caregiver/
1 SEX F
1 BIRT
2 DATE 6 JUN 1944
1 FAMS @ADOPTIVE_PARENTS@
1 NOTE @N27@
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:03:05
1 RIN 3
0 @I12@ INDI
1 NAME Extra URL /Filelinks/
1 SEX F
1 BIRT
2 DATE 1875
1 FAMC @F5@
1 NOTE @N23@
1 OBJE
2 FORM URL
2 TITL GEDCOM 5.5 documentation web site
2 FILE http://homepages.rootsweb.com/~pmcbride/gedcom/55gctoc.htm
1 OBJE
2 FORM URL
2 TITL FTP site with many GEDCOM files
2 FILE ftp://ftp.genealogy.org/genealogy/GEDCOM/
1 OBJE
2 FORM URL
2 TITL GEDitCOM Macintosh genealogy software home page
2 FILE http://www.geditcom.com
1 OBJE
2 FORM URL
2 TITL Email comments on this GEDCOM file to here
2 FILE mailto:support@geditcom.com
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:01:19
1 RIN 4
0 @I11@ INDI
1 NAME General Custom /Filelinks/
1 SEX M
1 BIRT
2 DATE 1872
1 DEAT
2 DATE 7 DEC 1941
1 FAMC @F5@
1 NOTE @N22@
1 OBJE
2 FORM TEXT
2 TITL Plain TEXT document
2 FILE Document.tex
1 OBJE
2 FORM W8BN
2 TITL Microsoft Word document
2 FILE Document.DOC
1 OBJE
2 FORM RTF
2 TITL Rich text format document
2 FILE Document.RTF
1 OBJE
2 FORM PDF
2 TITL Portable document format file
2 FILE Document.pdf
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:01:03
1 RIN 5
0 @I10@ INDI
1 NAME Nonstandard Multimedia /Filelinks/
1 SEX F
1 BIRT
2 DATE 1870
1 DEAT Y
1 FAMS @F7@
1 FAMC @F5@
1 NOTE @N21@
1 OBJE
2 FORM PICT
2 TITL Macintosh PICT file
2 FILE ImgFile.PIC
1 OBJE
2 FORM PNTG
2 TITL Macintosh MacPaint file
2 FILE ImgFile.MAC
1 OBJE
2 FORM TPIC
2 TITL TGA image file
2 FILE ImgFile.TGA
1 OBJE
2 FORM aiff
2 TITL Macintosh sound file
2 FILE enthist.aif
1 OBJE
2 FORM mov
2 TITL QuickTime movie file
2 FILE suntun.mov
1 OBJE
2 TITL Adobe Photoshop file
2 FORM 8BPS
2 FILE ImgFile.PSD
1 OBJE
2 FORM mpeg
2 TITL Mpeg Movie File
2 FILE top.mpg
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:00:39
1 RIN 6
0 @I9@ INDI
1 NAME Standard GEDCOM /Filelinks/
1 SEX M
1 BIRT
2 DATE 1835
1 FAMS @F5@
1 NOTE @N18@
1 OBJE
2 TITL Windows bit mapped image file
2 FORM bmp
2 FILE ImgFile.BMP
1 OBJE
2 TITL GIF image file
2 FORM gif
2 FILE ImgFile.GIF
1 OBJE
2 TITL JPEG image file
2 FORM jpeg
2 FILE ImgFile.JPG
1 OBJE
2 TITL Tagged image format file
2 FORM tiff
2 FILE ImgFile.TIF
1 OBJE
2 FORM pcx
2 TITL Windows paint brush file
2 FILE ImgFile.PCX
1 OBJE
2 TITL Windows sound File
2 FORM wav
2 FILE force.wav
1 OBJE @M1@
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:02:06
1 RIN 7
0 @PERSON2@ INDI
1 NAME Mary First /Jones/
1 SEX F
1 BIRT
2 DATE BEF 1970
1 DEAT
2 DATE AFT 2000
1 FAMS @FAMILY1@
1 NOTE @N31@
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:58:16
1 RIN 8
0 @I15@ INDI
1 NAME Torture GEDCOM /Matriarch/
1 SEX F
1 BIRT
2 DATE 12 FEB 1840
1 DEAT
2 DATE 15 JUN 1915
1 FAMS @F5@
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:01:59
1 RIN 9
0 @PERSON8@ INDI
1 NAME Elizabeth Second /Smith/
1 SEX F
1 BIRT
2 DATE BET MAY 1979 AND AUG 1979
1 DEAT
2 DATE FROM APR 2000 TO 5 MAR 2001
1 FAMS @FAMILY2@
1 NOTE @N32@
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:58:58
1 RIN 10
0 @PERSON3@ INDI
1 NAME Chris Locked /Torture/
1 BIRT
2 DATE MAR 1999
2 PLAC Las Vegas, Nevada USA
1 FAMC @FAMILY1@
1 NOTE @N20@
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:55:43
2 NOTE This date is the last time this record was changed
1 RESN locked
1 RIN 11
0 @PERSON1@ INDI
1 NAME Joseph Tag /Torture/
2 NPFX Prof.
2 GIVN Joseph
2 NICK Joe
2 SPFX Le
2 SURN Torture
2 NSFX Jr.
2 SOUR @SOURCE1@
3 PAGE 42
2 NOTE These are notes about the first NAME structure in this record. These notes are
3 CONC embedded in the INDIVIDUAL record itself.
3 CONT
3 CONT The second name structure in this record uses all possible tags for a personal name
3 CONC structure.
3 CONT
3 CONT NOTE: many applications are confused by two NAME structures.
1 SEX M
1 BIRT
2 DATE 31 DEC 1965
2 PLAC Salt Lake City, UT, USA
2 TYPE Normal
2 ADDR St. Marks Hospital
3 CONT Salt Lake City, UT
3 CONT USA
2 AGNC none
2 OBJE
3 TITL Link to multimedia file
3 FORM tiff
3 FILE ImgFile.TIF
2 SOUR @SOURCE1@
3 PAGE 42
3 QUAY 2
3 NOTE Some notes about this birth source citation which are embedded in the citation
4 CONC structure itself.
2 NOTE @N8@
2 FAMC @PARENTS@
1 DEAT
2 DATE ABT 15 JAN 2001
2 PLAC New York, New York, USA
3 FORM city, state, country
3 NOTE The place structure has more detail than usually used for places
3 SOUR @SOURCE1@
2 AGE 76
2 TYPE slow
2 ADDR at Home
2 CAUS Cancer
2 AGNC none
2 OBJE
3 FORM jpeg
3 TITL Multimedia link about the death event
3 FILE ImgFile.JPG
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some death source text.
3 QUAY 3
3 NOTE A death source note.
2 NOTE A death event note.
1 FAMS @FAMILY1@
2 NOTE Note about the link to the family record with his first spouse.
2 NOTE Another note about the link to the family record with his first spouse.
1 FAMS @FAMILY2@
1 FAMC @PARENTS@
2 NOTE Note about this link to his parents family record.
2 NOTE Another note about this link to his parents family record
1 FAMC @ADOPTIVE_PARENTS@
2 PEDI adopted
2 NOTE Note about the link to his adoptive parents family record.
1 BAPM Y
2 DATE ABT 31 DEC 1997
2 PLAC The place
2 AGE 3 months
2 TYPE BAPM
2 ADDR Church Name
3 CONT Street Address
3 CONT City Name, zip
3 CONT Country
2 CAUS Birth
2 AGNC The Church
2 OBJE
3 FORM jpeg
3 TITL JPEG File Link
3 FILE ImgFile.JPG
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Sample baptism Source text.
3 QUAY 3
3 NOTE A baptism source note.
2 NOTE A baptism event note (the event of baptism (not LDS), performed in infancy or later. See also BAPL and CHR).
1 CHR
2 DATE CAL 31 DEC 1997
2 PLAC The place
2 TYPE CHR
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Sample CHR Source text.
3 QUAY 3
3 NOTE A christening Source note.
2 NOTE Christening event note (the religious event (not LDS) of baptizing and/or naming a
3 CONC child).
2 FAMC @ADOPTIVE_PARENTS@
1 CHR
2 DATE EST 30 DEC 1997
2 PLAC The place
2 TYPE CHR
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some christening source text.
5 CONT This is the second christening structure.
3 QUAY 3
3 NOTE A christening Source note.
2 NOTE Alternative christening event note. GEDOM allows more than one of the same type
3 CONC of event.
1 BLES
2 DATE BEF 31 DEC 1997
2 PLAC The place
2 TYPE BLES
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some blessing source text.
3 QUAY 3
3 NOTE A blessing source note.
2 NOTE Blessing event note (a religious event of bestowing divine care or intercession.
3 CONC Sometimes given in connection with a naming ceremony)
1 BARM
2 DATE AFT 31 DEC 1997
2 PLAC The place
2 TYPE BARM
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some Bar Mitzvah source text.
3 QUAY 3
3 NOTE A Bar Mitzvah source note.
2 NOTE Bar Mitzvah event note (the ceremonial event held when a Jewish boy reaches age
3 CONC 13).
1 BASM
2 DATE FROM 31 DEC 1997
2 PLAC The place
2 TYPE BASM
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some Bas Mitzvah source text.
3 QUAY 3
3 NOTE A Bas Mitzvah source note.
2 NOTE Bas Mitzvah event note (the ceremonial event held when a Jewish girl reaches age 13,
3 CONC also known as "Bat Mitzvah").
1 ADOP Y
2 DATE TO 31 DEC 1997
2 PLAC The place
2 TYPE ADOP
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some adoption source text.
3 QUAY 3
3 NOTE An adoption source note.
2 NOTE Adoption event note (pertaining to creation of a child-parent relationship that does
3 CONC not exist biologically).
2 FAMC @ADOPTIVE_PARENTS@
3 ADOP BOTH
1 CHRA
2 DATE BET 31 DEC 1997 AND 1 FEB 1998
2 PLAC The place
2 TYPE CHRA
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some christening source text.
3 QUAY 3
3 NOTE A christening source note.
2 NOTE Adult christening event note (the religious event (not LDS) of baptizing and/or
3 CONC naming an adult person).
1 CONF
2 DATE FROM 31 DEC 1997 TO 2 JAN 1998
2 PLAC The place
2 TYPE CONF
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some CONF Source text.
3 QUAY 3
3 NOTE A CONF Source note.
2 NOTE CONFIRMATION event note (the religious event (not LDS) of conferring the gift of the Holy Ghost and, among protestants, full church membership).
1 FCOM
2 DATE INT 31 DEC 1997 (a test)
2 PLAC The place
2 TYPE FCOM
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some first communion source text.
3 QUAY 3
3 NOTE An first communion source note.
2 NOTE First communion event note (a religious rite, the first act of sharing in the Lord's
3 CONC supper as part of church worship).
1 ORDN
2 DATE (No idea of the date)
2 PLAC The place
2 TYPE ORDN
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some ordination source text.
3 QUAY 3
3 NOTE An ordination source note.
2 NOTE Ordination event note (a religious event of receiving authority to act in religious
3 CONC matters).
1 GRAD
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE GRAD
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some graduation source text.
3 QUAY 3
3 NOTE A graduation source note.
2 NOTE Graduation event note (an event of awarding educational diplomas or degrees to
3 CONC individuals).
1 EMIG
2 DATE 1997
2 PLAC The place
2 TYPE EMIG
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some emigration source text.
3 QUAY 3
3 NOTE An emigration source note.
2 NOTE Emigration event note (an event of leaving one's homeland with the intent of residing
3 CONC elsewhere).
1 IMMI
2 DATE DEC 1997
2 PLAC The place
2 TYPE IMMI
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some immigration source text.
3 QUAY 3
3 NOTE An immigration source note.
2 NOTE Immigration event note (an event of entering into a new locality with the intent of
3 CONC residing there).
1 NATU
2 DATE 5 AUG 1100 B.C.
2 PLAC The place
2 TYPE NATU
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some naturalization source text.
3 QUAY 3
3 NOTE A naturalization source note.
2 NOTE Naturalization event note (the event of obtaining citizenship).
1 CENS
2 DATE 2 TVT 5758
2 PLAC The place
2 TYPE CENS
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some census source text.
3 QUAY 3
3 NOTE A census source note.
2 NOTE Census event note (the event of the periodic count of the population for a designated
3 CONC locality, such as a national or state Census).
1 RETI
2 DATE 11 NIVO 0006
2 PLAC The place
2 TYPE RETI
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some retirement source text.
3 QUAY 3
3 NOTE A retirement source note.
2 NOTE Retirement event note (an event of exiting an occupational relationship with an
3 CONC employer after a qualifying time period).
1 PROB
2 DATE FROM 25 SVN 5757 TO 26 IYR 5757
2 PLAC The place
2 TYPE PROB
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some probate source text.
3 QUAY 3
3 NOTE A probate source note.
2 NOTE Probate event note (an event of judicial determination of the validity of a will. May
3 CONC indicate several related court activities over several dates).
1 BURI
2 DATE 5 VEND 0010
2 PLAC The place
2 TYPE BURI
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some burial source text.
3 QUAY 3
3 NOTE A burial source note.
2 NOTE Burial event note (the event of the proper disposing of the mortal remains of a
3 CONC deceased person).
1 WILL
2 DATE INT 2 TVT 5758 (interpreted Hebrew date)
2 PLAC The place
2 TYPE WILL
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some will source text.
3 QUAY 3
3 NOTE A will source note.
2 NOTE Will event note (a legal document treated as an event, by which a person disposes of
3 CONC his or her estate, to take effect after death. The event date is the date the will was
3 CONC signed while the person was alive. See also Probate).
1 CREM Y
1 EVEN
2 DATE 5 MAY 0005
2 PLAC The place
2 TYPE EVEN
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some generic event source text.
3 QUAY 3
3 NOTE A generic event source note.
2 NOTE Generic event note (a noteworthy happening related to an individual, a group, or an
3 CONC organization). The TYPE tag specifies the type of event.
1 BAPL
2 DATE 5 MAY 0005 B.C.
2 PLAC Salt Lake City
2 STAT Cleared
2 TEMP Mormon Temple
2 SOUR @SOURCE1@
2 NOTE @N5@
1 CONL Y
1 ENDL
2 DATE BET 5 APR 1712/13 AND 28 SEP 1714/15
1 SLGC
2 DATE 27 OCT 1699/00
2 FAMC @PARENTS@
1 RESI
2 DATE 31 DEC 1997
2 PLAC The place
2 AGE 35
2 TYPE RESI
2 ADDR Address in Free Form Line 1
3 CONT Address in Free Form Line 2
3 CONT Address in Free Form Line 3
3 ADR1 Special Address Line 1
3 ADR2 Special Address Line 2
3 CITY City Name
3 STAE State name
3 POST Postal Code
3 CTRY USA
2 PHON +1-800-555-5555
2 CAUS Needed housing
2 AGNC None
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some residence source text.
3 QUAY 3
3 NOTE A residence source note.
2 NOTE Residence attribute note (the act of dwelling at an address for a period of time).
1 OCCU Occupation
2 DATE 31 DEC 1997
2 AGE 40
2 PLAC The place
2 TYPE OCCU
2 ADDR Work address line 1
3 CONT Work address line 2
3 CONT Work address line 3
2 CAUS Need for money
2 AGNC Employer
2 OBJE
3 FORM gif
3 TITL GIF Image File
3 FILE ImgFile.GIF
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some occupation source text.
3 QUAY 3
3 NOTE An occupation source note.
2 NOTE Occupation attribute note (the type of work or profession of an individual).
1 OCCU Another occupation
2 DATE 31 DEC 1998
2 PLAC The place
2 TYPE OCCU
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some occupation source text.
3 QUAY 3
3 NOTE An occupation source note.
2 NOTE Occupation attribute note. This is the second occupation attribute in the record.
1 EDUC Education
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE EDUC
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some education source text.
3 QUAY 3
3 NOTE An education source note.
2 NOTE Education attribute note (indicator of a level of education attained).
1 DSCR Physical description
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE PHYS
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some physical description source text.
3 QUAY 3
3 NOTE A physical description source note.
2 NOTE Physical description attribute note (the physical characteristics of a person, place, or
3 CONC thing).
1 RELI Religion
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE RELI
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some religion source text.
3 QUAY 3
3 NOTE A religion source note.
2 NOTE Religion attribute note (a religious denomination to which a person is affiliated or for
3 CONC which a record applies).
1 SSN 6942
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE SSN
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some Social security number source text.
3 QUAY 3
3 NOTE An Social security number source note.
2 NOTE Social security number attribute note (a number assigned by the United States Social
3 CONC Security Administration. Used for tax identification purposes).
1 IDNO 6942
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE IDNO
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some national identification number source text.
3 QUAY 3
3 NOTE An national identification number source note.
2 NOTE National identification number attribute note (a number assigned to identify a person
3 CONC within some significant external system).
1 PROP Possessions
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE PROP
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some possessions source text.
3 QUAY 3
3 NOTE @N11@
2 NOTE Possessions or property attribute note (pertaining to possessions such as real estate
3 CONC or other property of interest).
1 CAST Cast name
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE CAST
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some caste name source text.
3 QUAY 3
3 NOTE A caste name source note.
2 NOTE Caste name attribute note (the name of an individual's rank or status in society, based
3 CONC on racial or religious differences, or differences in wealth, inherited rank, profession,
3 CONC occupation, etc).
1 NCHI 42
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE NCHI
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some number of children source text.
3 QUAY 3
3 NOTE Am number of children source note.
2 NOTE Number of children attribute note.
1 NMR 42
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE NMR
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some number of marriages source text.
3 QUAY 3
3 NOTE An number of marriages source note.
2 NOTE Number of marriages attribute note.
1 TITL Nobility title
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE TITL
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some title source text.
3 QUAY 3
3 NOTE A title source note.
2 NOTE Title attribute note (a description of a specific writing or other work, such as the title
3 CONC of a book when used in a source context, or a formal designation used by an
3 CONC individual in connection with positions of royalty or other social status,
3 CONT such as Grand Duke).
1 NATI National or tribe origin
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE NATI
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Some nationality source text.
3 QUAY 3
3 NOTE An nationality source note.
2 NOTE Nationality attribute note (the national heritage of an individual).
1 NOTE @N4@
2 SOUR @SOURCE1@
1 NOTE This is a second set of notes for this single individual record. It is embedded in the
2 CONC INDIVIDUAL record instead of being in a separate NOTE record.
2 CONT
2 CONT These notes also have a source citation to a SOURCE record. In GEDCOM
2 CONC this source can only be a single line and links to a SOURCE record.
2 SOUR @SOURCE1@
1 SOUR @SOURCE1@
2 PAGE 42
2 DATA
3 DATE 31 DEC 1900
3 TEXT Some sample text from the first source on this record.
2 QUAY 0
2 NOTE A source note.
1 SOUR @SR2@
2 NOTE @N12@
1 SOUR This source is embedded in the record instead of being a link to a
2 CONC separate SOURCE record.
2 CONT The source description can use any number of lines
2 TEXT Text from a source. The preferred approach is to cite sources by
3 CONC links to SOURCE records.
3 CONT Here is a new line of text from the source.
2 NOTE @N17@
1 OBJE
2 FORM gif
2 TITL GIF Image File
2 FILE ImgFile.GIF
1 ALIA @I9@
1 ASSO @I9@
2 RELA Has multimedia links
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Sample text about this source on an association.
2 NOTE Note on association link.
1 ASSO @PERSON5@
2 RELA Father
1 SUBM @SUBMITTER@
1 ANCI @SUBMITTER@
1 DESI @SUBMITTER@
1 REFN User reference number
2 TYPE Type of user number
1 RIN 12
1 RFN Record File Number
1 AFN Ancestral File Number
1 CHAN
2 DATE 17 Feb 2003
3 TIME 9:55:13
0 @PERSON7@ INDI
1 NAME Pat Smith /Torture/
1 BIRT
2 DATE 1 JAN 2001
2 PLAC London, UK
1 FAMC @FAMILY2@
1 NOTE @N30@
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:56:49
1 RIN 13
0 @PERSON4@ INDI
1 NAME Sandy Privacy /Torture/
1 RESN privacy
1 BIRT
2 DATE 15 FEB 2000
2 PLAC Chicago, IL, USA
1 FAMC @FAMILY1@
1 NOTE @N29@
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:56:15
1 RIN 14
0 @PERSON5@ INDI
1 NAME William Joseph /Torture/
1 SEX M
1 BIRT
2 DATE ABT 1930
1 DEAT Y
2 DATE INT 1995 (from estimated age)
2 AGE 65
2 CAUS Old age
1 FAMS @PARENTS@
1 FAMC @F6@
1 NOTE @N28@
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:59:40
1 RIN 15
0 @FAMILY1@ FAM
1 HUSB @PERSON1@
1 WIFE @PERSON2@
1 MARR
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE Man and Wife
2 ADDR A Church
3 CONT Main Street, USA
2 CAUS Love
2 AGNC Catholic Church
2 HUSB
3 AGE 42y
2 WIFE
3 AGE 42y 6m
2 OBJE
3 FORM jpeg
3 TITL Multimedia link about the marriage event
3 FILE ImgFile.JPG
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Text from marriage source.
3 QUAY 3
3 NOTE A note about the marriage source.
2 NOTE Marriage event note (a legal, common-law, or customary event of creating a family
3 CONC unit of a man and a woman as husband and wife).
1 CHIL @PERSON3@
1 CHIL @PERSON4@
1 NCHI 42
1 ENGA Y
2 DATE 31 DEC 1997
2 PLAC The place
2 AGE 42
2 TYPE ENGA
2 ADDR The house
3 CONT Anytown, USA
2 CAUS Desire
2 AGNC None
2 HUSB
3 AGE 42y
2 WIFE
3 AGE STILLBORN
2 OBJE
3 FORM bmp
3 TITL BMP Image File
3 FILE ImgFile.BMP
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Sample text from engagement source.
3 QUAY 3
3 NOTE A note about this engagement source.
2 NOTE Engagement event note (an event of recording or announcing an agreement between
3 CONC two people to become married).
1 MARB
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE MARB
2 HUSB
3 AGE 42y
2 WIFE
3 AGE 42y 6m
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Sample text from marriage banns source.
3 QUAY 3
3 NOTE A note about this marriage banns source.
2 NOTE Marriage banns event note (an event of an official public notice given that two people
3 CONC intend to marry).
1 MARC
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE MARC
2 HUSB
3 AGE 42y
2 WIFE
3 AGE >42y 6m
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Sample text from marriage contract source.
3 QUAY 3
3 NOTE A note about this marriage contract source.
2 NOTE Marriage contract event note (an event of recording a formal agreement of marriage,
3 CONC including the prenuptial agreement in which marriage partners reach agreement about
3 CONC the property rights of one or both, securing property to their children).
1 MARL
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE MARL
2 HUSB
3 AGE 42y
2 WIFE
3 AGE <42y 6m
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Sample text from marriage license source.
3 QUAY 3
3 NOTE A note about this marriage license source.
2 NOTE Marriage license event note (an event of obtaining a legal license to marry).
1 MARS
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE MARS
2 HUSB
3 AGE 42y
2 WIFE
3 AGE INFANT
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Sample text from marriage settlement source.
3 QUAY 3
3 NOTE A note about this marriage settlement source.
2 NOTE Marriage settlement event note (an event of creating an agreement between two
3 CONC people contemplating marriage, at which time they agree to release or modify
3 CONC property rights that would otherwise arise from the marriage).
1 DIV
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE DIV
2 HUSB
3 AGE 42y 3d
2 WIFE
3 AGE 42m
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Sample text from divorce source.
3 QUAY 3
3 NOTE A note about this divorce source.
2 NOTE Divorce event note (an event of dissolving a marriage through civil action).
1 DIVF
2 DATE 31 DEC 1997
2 PLAC The place
2 HUSB
3 AGE 42d
2 WIFE
3 AGE CHILD
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Sample text from divorce filing source.
3 QUAY 3
3 NOTE A note about this divorce filing source.
2 NOTE DIVORCE_FILED event note (an event of filing for a divorce by a spouse).
1 ANUL Y
2 DATE 31 DEC 1997
1 CENS
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE CENS
2 HUSB
3 AGE 42y 6m 9d
2 WIFE
3 AGE 6m 9d
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Sample text from census source.
3 QUAY 3
3 NOTE A note about this census source.
2 NOTE Census event note (the event of the periodic count of the population for a designated
3 CONC locality, such as a national or state Census).
1 EVEN
2 DATE 31 DEC 1997
2 PLAC The place
2 TYPE EVEN
2 HUSB
3 AGE 42y
2 WIFE
3 AGE 42y 6m
2 SOUR @SOURCE1@
3 PAGE 42
3 DATA
4 DATE 31 DEC 1900
4 TEXT Sample text from generic family event source.
3 QUAY 3
3 NOTE A note about this generic family event source.
2 NOTE Generic family vent note (a noteworthy happening related to an individual, a group, or
3 CONC an organization).
1 SLGS
2 DATE 12 DEC 1976
2 PLAC Temple
2 STAT Child
2 TEMP Temple Code
2 SOUR @SOURCE1@
3 DATA
4 TEXT Sample text from LDS spouse sealing source.
3 NOTE @N19@
2 NOTE @N6@
1 NOTE Comments on "Joseph Tag Torture-Mary First Jones" FAMILY Record.
2 CONT
2 CONT This record contains all possible types of data that can be stored in a FAMILY
2 CONC (FAM) GEDCOM record. Here are some comments on the data tested here and
2 CONC things to look for when this file is imported into any GEDCOM application:
2 CONT
2 CONT 1. The marriage event (MARR) uses all possible tags for such a structure including
2 CONC notes, sources, and a link to a multimedia file.
2 CONT
2 CONT 2. This family has two children.
2 CONT
2 CONT 3. This family has all possible family events (including a generic event or EVEN
2 CONC structure). Some notes are:
2 CONT      a. The engaged structure has all possible tags for event detail.
2 CONT      b. The annulment event (ANUL) has no data except a "Y" in the first line to
2 CONC indicate that the event has occurred. The importing software should keep this event in
2 CONC this record even though it contains no data.
2 CONT      c. The LDS Spouse Sealing event tests all possible detail tags for an LDS.
2 CONT      d. The TYPE tag of each event has the name of the GEDCOM tag for that event.
2 CONC There is no TYPE tag in the annulment event because that structure is empty.
2 CONT
2 CONT 4. This record has this one note structure which is to a set of embedded notes (and
2 CONC which you are reading now).
2 CONT
2 CONT 5. This record has one source citation.
2 CONT
2 CONT 6. This record is linked a submitter.
2 CONT
2 CONT 7. This record has all remaining tags allowed in FAMILY records for user reference
2 CONC number, record ID, and the changed date.
1 SOUR @SOURCE1@
2 PAGE 42
2 DATA
3 DATE 31 DEC 1900
3 TEXT A sample text from a source of this family
2 QUAY 0
2 NOTE A note this source on the FAMILY record.
1 OBJE
2 FORM bmp
2 TITL BMP Image File
2 FILE ImgFile.BMP
1 SUBM @SUBMITTER@
1 REFN User Reference Number
2 TYPE Type of user number
1 RIN 1
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:18:40
0 @PARENTS@ FAM
1 HUSB @PERSON5@
1 CHIL @PERSON1@
1 NOTE @N33@
1 CHAN
2 DATE 13 Jun 2000
3 TIME 17:00:35
1 RIN 2
0 @ADOPTIVE_PARENTS@ FAM
1 WIFE @PERSON6@
1 CHIL @PERSON1@
1 NOTE @N34@
1 CHAN
2 DATE 13 Jun 2000
3 TIME 17:01:18
1 RIN 3
0 @FAMILY2@ FAM
1 HUSB @PERSON1@
1 WIFE @PERSON8@
1 CHIL @PERSON7@
1 NOTE @N35@
1 CHAN
2 DATE 13 Jun 2000
3 TIME 17:01:46
1 RIN 4
0 @F5@ FAM
1 HUSB @I9@
1 WIFE @I15@
1 CHIL @I10@
1 CHIL @I11@
1 CHIL @I12@
1 NOTE @N36@
1 RIN 5
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:50:37
0 @F6@ FAM
1 HUSB @I14@
1 WIFE @I13@
1 CHIL @PERSON5@
1 NOTE @N37@
1 RIN 6
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:51:48
0 @F7@ FAM
1 WIFE @I10@
1 CHIL @I14@
1 NOTE @N38@
1 RIN 7
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:52:53
0 @SOURCE1@ SOUR
1 TITL Everything You Every Wanted to Know about GEDCOM Tags, But
2 CONC Were Afraid to Ask!
2 CONT You can start new lines in this field too.
1 ABBR All About GEDCOM Tags
1 AUTH Author or Authorss of this Source using multiple lines if
2 CONC necessary.
2 CONT Here is a new line in this field
1 PUBL Details of the publisher of this source using multiple lines
2 CONC if necessary.
2 CONT Here is a new line in this field
1 REPO @R1@
2 CALN 920.23
3 MEDI Book (or other description of this source)
2 NOTE A short note about the repository link. This note is about the repository (if more
3 CONC information is needed other than call number and simple description). Notes about
3 CONC the Source itself are usually entered elsewhere.
1 TEXT This section is used to generic text from the course. It will usually be a
2 CONC quote from the text that is relevant to the use of this source in the current
2 CONC GEDCOM file.
2 CONT
2 CONT It may use as many lines as needed.
1 DATA
2 EVEN BIRT, CHR
3 DATE FROM 1 JAN 1980 TO 1 FEB 1982
3 PLAC Anytown, Anycounty, USA
2 EVEN DEAT
3 DATE FROM 1 JAN 1980 TO 1 FEB 1982
3 PLAC County Some, Ireland
2 AGNC Responsible agency for data in this source
2 NOTE A note about data in source.
3 CONT
3 CONT This note includes a blank line before this text. These notes are used to describe the
3 CONC data in this source. Notes about the source itself are usually entered in a different set
3 CONC of notes.
1 NOTE @N15@
1 NOTE These are notes embedded in the SOURCE Record instead of in a separate NOTE
2 CONC RECORD.
1 OBJE
2 TITL JPEG image file link
2 FORM jpeg
2 NOTE @N14@
2 FILE ImgFile.JPG
1 REFN User Reference Number
2 TYPE User Reference Type
1 RIN 1
1 CHAN
2 DATE 14 Jan 2001
3 TIME 14:29:25
0 @SR2@ SOUR
1 TITL All I Know About GEDCOM, I Learned on the Internet
1 ABBR What I Know About GEDCOM
1 AUTH Second Source Author
1 NOTE @N16@
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:21:39
1 RIN 2
0 @R1@ REPO
1 NAME Family History Library
1 ADDR 35 North West Temple
2 CONT Salt Lake City, UT 84111
2 CONT USA
2 ADR1 35 North West Temple
2 ADR2 Across the street from Temple Square
2 CITY Salt Lake City
2 STAE Utah
2 POST 84111
2 CTRY USA
1 PHON +1-801-240-2331 (information)
1 PHON +1-801-240-1278 (gifts & donations)
1 PHON +1-801-240-2584 (support)
1 NOTE @N2@
1 REFN User Ref Number
2 TYPE Sample
1 RIN 1
1 CHAN
2 DATE 12 Mar 2000
3 TIME 10:36:02
0 @N1@ NOTE
1 CONC Test link to a graphics file about the main Submitter of this file.
1 CHAN
2 DATE 24 May 1999
3 TIME 16:39:55
0 @N2@ NOTE
1 CONC Comments on "Family History Library" REPOSITORY Record.
1 CONT
1 CONT This record uses all possible GEDCOM tags for a REPOSITORY record. Some
1 CONC things to look for are:
1 CONT
1 CONT 1. The address is specified twice. Once in a multi-line address record and once in
1 CONC separate lines. The first method is usually enough. The second method is to be more
1 CONC specific about parts of the address. Is everything imported?
1 CONT
1 CONT 2. There are multiple phone numbers. Are they all imported?
1 SOUR @SOURCE1@
2 PAGE 1
2 DATA
3 DATE 1 MAY 1999
3 TEXT Text from the source about this repository.
2 QUAY 3
1 CHAN
2 DATE 12 Mar 2000
3 TIME 11:44:05
0 @N4@ NOTE
1 CONC Comments on "Joseph Tag Torture" INDIVIDUAL Record.
1 CONT
1 CONT This record contains all possible types of data that can be stored in an INDIVIDUAL (INDI)
1 CONC GEDCOM record. Here are some comments on the data tested here and things to look for
1 CONC when this file is imported into any GEDCOM application:
1 CONT
1 CONT 1. This record has two NAME structures. How will a program handle this type of data which
1 CONC is allowed in GEDCOM? (Because some GEDCOM files get very bothered by a second
1 CONC name, the files TGC551.ged and TGC551LF files are identical to the TGC55.ged and
1 CONC TGC55LF.ged files except only one name structure is used for this individual - hence the "1"
1 CONC in their names).
1 CONT
1 CONT 2. The first NAME structure has all possible subordinate tags for a NAME structure
1 CONC including source and notes a source citation and some notes. The second NAME structure
1 CONC (when used) has a source citation and some notes. Are these all imported?
1 CONT
1 CONT 3. The Birth and Death events use all possible fields including subordinate tags, sources,
1 CONC multimedia links (in Birth), and notes. The birth data has an attached family link which is
1 CONC sometimes needed in case of ambiguous parentage.
1 CONT
1 CONT 4. This individual has two spouses. The links to the spouses have attached notes.
1 CONT
1 CONT 5. This individual has two sets of parents - natural parents and adoptive parents. Each parent
1 CONC link has attached notes. The adoptive parents has a subordinate pedigree (PEDI) tag.
1 CONT
1 CONT 6. This individual has all possible events (including a generic event or EVEN structure). The
1 CONC GEDCOM tags for the events are given in the TYPE tag of each event. Some comments are:
1 CONT      a. The baptism record has all possible tags for event detail.
1 CONT      b. There are 2 christening records to see how programs react to duplicate events (which
1 CONC are allowed).
1 CONT      c. The adoption event has a family link to give more information about adoptive parentage.
1 CONT      d. The cremation event (CREM) has no data except a "Y" in the first line to indicate that
1 CONC the event has occurred. The importing software should keep this event in this record even
1 CONC though it contains no data (The GEDCOM tag is not in this TYPE tag).
1 CONT      e. The LDS Baptism event tests all possible detail tags for an LDS ordinance.
1 CONT      f. The LDS confirmation has no data except a "Y" in the first line to indicate that the event
1 CONC has occurred. The importing software should keep this event in this record even though it
1 CONC contains no data.
1 CONT      g. The date fields in the various events test the possible GEDCOM methods for
1 CONC expressing dates, approximate dates, date ranges, and interpreted dates. There are also a few
1 CONC Hebrew dates, French Republic dates. and "B.C" dates.
1 CONT
1 CONT 7. The residence structure use all possible subordinate tags in the address part of the
1 CONC residence.
1 CONT
1 CONT 8. This individual has all possible attributes. The GEDCOM tags for the attributes are given
1 CONC in the TYPE tag of each attribute. Some notes are:
1 CONT      a. There are 2 occupation attributes to test how programs handle multiple tags of the same
1 CONC type (which is allowed).
1 CONT      b. The first OCCU attribute uses all possible subordinate tags for an attribute.
1 CONT
1 CONT 9. This record has three note structures. The first is this set of notes which is in a separate
1 CONC NOTE record. The other two are NOTE structures embedded in the record. Are all imported
1 CONC and kept separate? Furthermore, the two embedded note structures have subordinate source
1 CONC citations. The second set of notes has a source citation to a SOURCE record and the third set
1 CONC of notes has an embedded source citation.
1 CONT
1 CONT 10. This record has three source citations. Two are citations to a SOURCE record; one is an
1 CONC embedded source citation (used in older GEDCOM files).
1 CONT
1 CONT 11. This record has one link to a multimedia file. For more testing of multimedia links, see
1 CONC the "Standard GEDCOM Filelinks," "Nonstandard Multimedia Filelinks," "General Custom
1 CONC Filelinks," and "Extra URL Filelinks" INDIVIDUAL records.
1 CONT
1 CONT 12. This individual has one alias and two associations. All possible tags in the first
1 CONC association link are used.
1 CONT
1 CONT 13. This record is linked to a submitter and to two submitters with interest in the ancestors
1 CONC and descendants of this individual.
1 CONT
1 CONT 14. This record has all remaining tags allowed in individual records for user reference
1 CONC number, record ID, record file number, ancestral file number, and the changed date.
1 CHAN
2 DATE 12 Jan 2001
3 TIME 0:36:39
0 @N5@ NOTE
1 CONC Notes on this LDS event. All possible LDS ordinance detail tags are used in
1 CONC this event.
1 CHAN
2 DATE 6 Mar 2000
3 TIME 22:05:42
0 @N6@ NOTE
1 CONC Notes on this LDS Spouse Sealing Event.
1 SOUR @SOURCE1@
1 CHAN
2 DATE 26 May 1999
3 TIME 22:38:25
0 @N8@ NOTE
1 CONC Some specific note about the birth event.
1 CONT
1 CONT These notes are in a separate NOTE record. These notes also have their own source
1 CONC citation structure.
1 SOUR @SR2@
2 DATA
3 DATE 1 JUN 1945
3 TEXT Here is some text from the source. The source is about the notes
4 CONC for the birth event.
2 QUAY 3
2 NOTE @N9@
2 PAGE 102
2 EVEN Event type cited in source
3 ROLE Role in cited event
1 CHAN
2 DATE 18 Jun 2000
3 TIME 1:09:46
0 @N9@ NOTE
1 CONC These are notes in a NOTE record. It is a bit redundant, but you can add source
1 CONC citations directly to NOTE records in addition to adding source citations to the
1 CONC initial GEDCOM structure that the notes are about.
1 CONT
1 CONT This example source citation in a NOTE record has all possible source citation
1 CONC fields filled in.
1 CHAN
2 DATE 9 Jun 1999
3 TIME 13:16:57
0 @N11@ NOTE
1 CONC A possessions source note.
1 CHAN
2 DATE 18 Jun 2000
3 TIME 1:37:42
0 @N12@ NOTE
1 CONC This is a second source citation in this record.
1 CHAN
2 DATE 6 Mar 2000
3 TIME 22:18:51
0 @N14@ NOTE
1 CONC These notes can be used to add more information about the multimedia file linked to
1 CONC this SOURCE record.
1 CHAN
2 DATE 12 Mar 2000
3 TIME 9:49:23
0 @N15@ NOTE
1 CONC Comments on "Everything You Every Wanted to Know about GEDCOM Tags" SOURCE Record.
1 CONT
1 CONT This is a set of notes about this SOURCE record. These notes are for anything else
1 CONC needed. There are other places to enter notes about the storage of the source (in the
1 CONC Repository link) and about the data in the source (in the DATA structure).
1 CONT
1 CONT This particular SOURCE record uses all possible GEDCOM tags for a SOURCE
1 CONC record. Some things to check are:
1 CONT
1 CONT 1. Are the separate notes structures in the Repository link and the DATA structure
1 CONC preserved on importing?
1 CONT
1 CONT 2. Does the software recognize two sets of event types in the DATA structure?
1 CONT
1 CONT 3. Are the multimedia links preserved?
1 CONT
1 CONT 4. This record as two sets of notes - this one in a separate record and a second one
1 CONC embedded in the SOURCE record. Are they both imported and kept separate?
1 CHAN
2 DATE 13 Jun 2000
3 TIME 17:04:24
0 @N16@ NOTE
1 CONC Comments on "All I Know About GEDCOM, I Learned on the Internet" SOURCE record.
1 CONT
1 CONT This is another SOURCE record. How does the importing software handle multiple
1 CONC sources in the GEDCOM file? This source only fills a few GEDCOM structures.
1 CHAN
2 DATE 12 Mar 2000
3 TIME 12:46:21
0 @N17@ NOTE
1 CONC How does software handle embedded SOURCE records on import? Such source
1 CONC citations are common in old GEDCOM files. More modern GEDCOM files should
1 CONC use source citations to SOURCE records.
1 CHAN
2 DATE 12 Mar 2000
3 TIME 10:56:56
0 @N18@ NOTE
1 CONC Comments on "Standard GEDCOM Filelinks" INDIVIDUAL Record.
1 CONT
1 CONT The GEDCOM standard lets you link records to multimedia objects kept in separate
1 CONC files. When GEDCOM 5.5 was released, it only mentioned allowing links to a small
1 CONC number of multimedia files types and some of them are Windows-only file types.
1 CONC The recommended list is
1 CONT
1 CONT      bmp - Windows but map file
1 CONT      gif - Bit map, 256 color GIF files (common on the Internet)
1 CONT      jpeg - Bit-mapped files developed for photographs (also common on the Internet)
1 CONT      ole - Linked object
1 CONT      pcx - Windows paintbrush file
1 CONT      tiff - Tagged image format file
1 CONT      wav - Windows sound file
1 CONT
1 CONT This INDIVIDUAL record has links to this limited set of multimedia files (except
1 CONC for ole). These links are created by having an OBJE structure with the path name to
1 CONC the file in a subordinate FILE tag and the format of the file in a subordinate FORM
1 CONC tag.
1 CONT
1 CONT It does not make sense to limit files links to this small set of file types. It does not
1 CONC allow for future file types and, for example, it ignores movie files types. You can visit
1 CONC the "Nonstandard Multimedia Filelinks" record to see links to other types of multimedia files.
1 CONC You can visit the "General Custom Filelinks" and the "Extra URL Filelinks" records to see links to
1 CONC any file type and to universal resource locators.
1 CONT
1 CONT NOTE: The path names for the linked files here are just the file names. A good
1 CONC GEDCOM program should search for the files and might look first in the same
1 CONC folder as this test GEDCOM file. A weaker program might be unable to locate these
1 CONC files and you will have to enter the full path names.
1 CONT
1 CONT EMBEDDED Multimedia Object:
1 CONT      GEDCOM 5.5 has a method for encoding multimedia objects and storing them in
1 CONC MULTIMEDIA Records. This INDIVIDUAL has a link to such an embedded
1 CONC object. The object has encoded data, written using the GEDCOM 5.5 encoding
1 CONC algorithm, for the image of a small flower. To my knowledge, there are no genealogy
1 CONC programs that can actually read and decode such objects. The main reason for
1 CONC inclusion of the object here is to see how programs will treat this record. Good
1 CONC programs will leave them in the file (it is bad manners to delete someone's data). Bad
1 CONC programs will simple delete the object from the file.
1 REFN User Reference Number
2 TYPE User Reference Type
1 RIN 1
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:41:51
0 @N19@ NOTE
1 CONC A note about this LDS spouse sealing source.
1 CHAN
2 DATE 12 Mar 2000
3 TIME 12:32:13
0 @N20@ NOTE
1 CONC Comments on "Chris Locked Torture" record.
1 CONT
1 CONT These notes test line breaking in note records with multiple lines. These notes are for
1 CONC a locked individual and thus you should not be able to edit them.
1 CONT
1 CONT TEST #1: Line breaks in the middle of a word
1 CONT      These lines appear together. The word TE
1 CONC ST should appear as a single word and
1 CONC not be broken onto two lines.
1 CONT
1 CONT TEST #2: Translation of "at" signs
1 CONT      The GEDCOM standard says the "@@" sign should appear in any text in the file
1 CONC as double "@@@@" signs. This recommendation is superfluous, because there is
1 CONC never a case when an "@@" sign in data can be confused with other GEDCOM uses
1 CONC of the "@@" sign. The question here is how does the software import:
1 CONT
1 CONT      A single @@ sign in some notes entered by using two characters.
1 CONT
1 CONT If all "at" signs above appear above as 2 or 4 at signs, that GEDCOM software is not
1 CONC converting double at signs to single at signs.
1 CONT
1 CONT TEST #3: Bad line breaks between word but a forgotten space
1 CONT      A little below, the words "End" and "Start" are on two lines in the note record.
1 CONC The line with "End," however, forgot the required trailing blank. Thus, a proper
1 CONC importing of these bad notes should combine the two words with no space between
1 CONC "End" and "Start". Here is End
1 CONC Start as described above. They should appear as one
1 CONC word.
1 CONT
1 CONT TEST #4: Blank lines
1 CONT      The above paragraphs should have blank lines between them.
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:35:25
0 @N21@ NOTE
1 CONC Comments on "Nonstandard Multimedia Filelinks" INDIVIDUAL Record.
1 CONT
1 CONT File links in GEDCOM are created by having an OBJE structure with the path name
1 CONC to the file in a subordinate FILE tag and the format of the file in a subordinate
1 CONC FORM tag. It does not make sense to limit file links to the small set of file types
1 CONC mentioned in the GEDCOM standard (see INDIVIDUAL record "Standard GEDCOM Filelinks"
1 CONC for those file types). This INDIVIDUAL record has links to
1 CONC other types of multimedia files including movie files, other image file types, and some
1 CONC Macintosh file types.
1 CONT
1 CONT What will a genealogy program do when in encounters to logical extensions to
1 CONC GEDCOM file links? Good programs will follow the links. Weaker programs will
1 CONC simply delete them from your file (it is bad manners to delete someone's data).
1 CONT
1 CONT Some other possible multimedia file type not yet linked to this record are:
1 CONT    avi - Microsoft movie file
1 CONT    midi - sound file
1 CONT    mp3 - music file
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:43:04
0 @N22@ NOTE
1 CONC Comments on "General Custom Filelinks" INDIVIDUAL Record.
1 CONT
1 CONT File links in GEDCOM are created by having an OBJE structure with the path name
1 CONC to the file in a subordinate FILE tag and the format of the file in a subordinate
1 CONC FORM tag. It does not make sense to limit file links to the small set of multimedia
1 CONC file types mentioned in the GEDCOM standard (see INDIVIDUAL record
1 CONC "Standard GEDCOM Filelinks" for those file types). The INDIVIDUAL record
1 CONC "Nonstandard Multimedia Filelinks" has sample links to other types of multimedia files not
1 CONC included in the standard GEDCOM list. This INDIVIDUAL record has links to
1 CONC some non-multimedia files types.
1 CONT
1 CONT What will a genealogy program do when it encounters such logical extensions to
1 CONC GEDCOM file links? Good programs will follow the links. Weaker programs will
1 CONC simply delete them from your file (it is bad manners to delete someone's data).
1 CHAN
2 DATE 20 Jun 2000
3 TIME 1:06:34
0 @N23@ NOTE
1 CONC Comments on "Extra URL Filelinks" INDIVIDUAL Record.
1 CONT
1 CONT File links in GEDCOM are created by having an OBJE structure with the path name
1 CONC to the file in a subordinate FILE tag and the format of the file in a subordinate
1 CONC FORM tag. It does not make sense to limit file links to the small set of multimedia
1 CONC file types mentioned in the GEDCOM standard (see INDIVIDUAL record
1 CONC "Standard GEDCOM Filelinks" for those file types) or even to limit them to local
1 CONC files. This INDIVIDUAL record has a series of links with universal resource
1 CONC locators (URL) in the FILE tag and the file "URL" in the FORM tag.
1 CONT
1 CONT The sample URL links include links to a web sites, a link to an FTP site, and a link to
1 CONC send email.
1 CONT
1 CONT This extension of file links to URL links is non-standard GEDCOM. What will a
1 CONC genealogy program do when in encounters URL file links? Cleaver programs will
1 CONC find the file on the Internet using your default browser, FTP program, or email
1 CONC program. Weaker programs will simply delete them from your file (it is bad manners
1 CONC to delete someone's data).
1 CHAN
2 DATE 20 Jun 2000
3 TIME 1:09:48
0 @N24@ NOTE
1 CONC Comments on "Charlie Accented ANSEL" INDIVIDUAL Record.
1 CONT
1 CONT To represent accented characters, the ANSEL character set uses two-byte codes. The
1 CONC first byte is E0 to FB or FE (hexadecimal); the second byte is the letter to be
1 CONC accented.
1 CONT
1 CONT These notes have all possible accented characters. How many of the characters are
1 CONC represented correctly? Even programs that fully support ANSEL will not draw all
1 CONC these accented characters correctly. Many of them correspond to accents that can not
1 CONC be found in any langauge and therefore do not correspond to any computer fonts.
1 CONT
1 CONT code: E0 (Unicode: hook above, 0309) low rising tone mark
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: E1 (Unicode: grave, 0300) grave accent
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: E2 (Unicode: acute, 0301) acute accent:
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�i�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: E3 (Unicode: circumflex, 0302) circumflex accent
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: E4 (Unicode: tilde, 0303) tilde
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �N�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: E5 (Unicode: macron, 0304) macron
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: E6 (Unicode: breve, 0306) breve
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: E7 (Unicode: dot above, 0307) dot above
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: E8 (Unicode: diaeresis, 0308) umlaut (dieresis)
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: E9 (Unicode: caron, 030C) hacek
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: EA (Unicode: ring above, 030A) circle above (angstrom)
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: EB (Unicode: ligature left half, FE20) ligature, left half
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: EC (Unicode: ligature right half, FE21) ligature, right half
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: ED (Unicode: comma above right, 0315) high comma, off center
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: EE (Unicode: double acute, 030B) double acute accent
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: EF (Unicode: candrabindu, 0310) candrabindu
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: F0 (Unicode: cedilla, 0327) cedilla
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: F1 (Unicode: ogonek, 0328) right hook
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: F2 (Unicode: dot below, 0323) dot below
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: F3 (Unicode: diaeresis below, 0324) double dot below
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: F4 (Unicode: ring below, 0325) circle below
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: F5 (Unicode: double low line, 0333) double underscore
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: F6 (Unicode: line below, 0332) underscore
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: F7 (Unicode: comma below, 0326) left hook
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: F8 (Unicode: left half ring below, 031C) right cedilla
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: F9 (Unicode: breve below, 032E) half circle below
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: FA (Unicode: double tilde left half, FE22) double tilde, left half
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: FB (Unicode: double tilde right half, FE23) double tilde, right half
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CONT
1 CONT code: FE (Unicode: comma above, 0313) high comma, centered
1 CONT      �A�B�C�D�E�F�G�H�I�J�K�L�M
1 CONT      �N�O�P�Q�R�S�T�U�V�W�X�Y�Z
1 CONT      �a�b�c�d�e�f�g�h�i�j�k�l�m
1 CONT      �n�o�p�q�r�s�t�u�v�w�x�y�z
1 CHAN
2 DATE 12 Jan 2001
3 TIME 0:32:24
0 @N25@ NOTE
1 CONC Comments on "Lucy Special ANSEL" INDIVIDUAL Record.
1 CONT
1 CONT The following are the special characters supported by the ANSEL character set. The first two letters
1 CONC are the Hex code. The following text describes the character.
1 CONC Finally, that character, or a character as close as possible to that
1 CONC character, should appear in the parentheses.
1 CONT
1 CONT A1 slash l - uppercase (�)
1 CONT A2 slash o - uppercase (�)
1 CONT A3 slash d - uppercase (�)
1 CONT A4 thorn - uppercase (�)
1 CONT A5 ligature ae - uppercase (�)
1 CONT A6 ligature oe - uppercase (�)
1 CONT A7 single prime (�)
1 CONT A8 middle dot (�)
1 CONT A9 musical flat (�)
1 CONT AA registered sign (�)
1 CONT AB plus-or-minus (�)
1 CONT AC hook o - uppercase (�)
1 CONT AD hook u - uppercase (�)
1 CONT AE left half ring (�)
1 CONT BO right half ring (�)
1 CONT B1 slash l - lowercase (�)
1 CONT B2 slash o - lowercase (�)
1 CONT B3 slash d - lowercase (�)
1 CONT B4 thorn - lowercase (�)
1 CONT B5 ligature ae - lowercase (�)
1 CONT B6 ligature oe - lowercase (�)
1 CONT B7 double prime (�)
1 CONT B8 dotless i - lowercase (�)
1 CONT B9 british pound (�)
1 CONT BA eth (�)
1 CONT BC hook o - lowercase (�)
1 CONT BD hook u - lowercase (�)
1 CONT BE empty box - LDS extension (�)
1 CONT BF black box - LDS extensions (�)
1 CONT CO degree sign (�)
1 CONT C1 script l (�)
1 CONT C2 phonograph copyright mark (�)
1 CONT C3 copyright symbol (�)
1 CONT C4 musical sharp (�)
1 CONT C5 inverted question mark (�)
1 CONT C6 inverted exclamation mark (�)
1 CONT CD midline e - LDS extension (�)
1 CONT CE midline o - LDS extension (�)
1 CONT CF es zet (�)
1 CHAN
2 DATE 13 Jun 2000
3 TIME 16:28:45
0 @N27@ NOTE
1 CONC Comments on "Teresa Mary Caregiver" INDIVIDUAL Record.
1 CONT
1 CONT This record is the adoptive mother of "Joseph Tag Torture". She is linked to a family
1 CONC record, but there is no husband in that record.
1 CHAN
2 DATE 13 Jun 2000
3 TIME 17:14:28
0 @N28@ NOTE
1 CONC Comments on "William Joseph Torture" INDIVIDUAL Record.
1 CONT
1 CONT This record is the natural father of "Joseph Tag Torture". He is linked to a family
1 CONC record, but there is no wife in that record.
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:31:12
0 @N29@ NOTE
1 CONC Comments on "Sandy Privacy Torture" INDIVIDUAL Record.
1 CONT
1 CONT This record has a restriction setting of "privacy." In public applications of
1 CONC GEDCOM files, "privacy" records should be hidden from all viewing and printing. It
1 CONC is less clear how GEDCOM software on your own PC reading your own copies of
1 CONC GEDCOM files should treat "privacy" records. At a minimum, it should import and
1 CONC preserve the "privacy" setting.
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:36:50
0 @N30@ NOTE
1 CONC Comments on "Pat Smith Torture" INDIVIDUAL Record.
1 CONT
1 CONT The record simply provides a child to "Joseph Tag Torture" in his family with "Mary First
1 CONC Jones" as his spouse.
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:40:04
0 @N31@ NOTE
1 CONC Comments on "Mary First Jones" INDIVIDUAL Record.
1 CONT
1 CONT This record is used to provide the first wife to "Joseph Tag Torture." Not many other
1 CONC tags are used.
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:38:17
0 @N32@ NOTE
1 CONC Comments on "Elizabeth Second Smith" INDIVIDUAL Record.
1 CONT
1 CONT This record is used to provide a second wife to "Joseph Tag Torture." Not many
1 CONC other tags are used.
1 CHAN
2 DATE 11 Jan 2001
3 TIME 15:38:55
0 @N33@ NOTE
1 CONC Comments on "William Joseph Torture-<unknown>" FAMILY Record.
1 CONT
1 CONT This record has the natural father of "Joseph Tag Torture." The wife is not known.
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:49:33
0 @N34@ NOTE
1 CONC Comments on "<unknown>-Teresa Mary Caregiver" FAMILY Record.
1 CONT
1 CONT This record has the adoptive mother of "Joseph Tag Torture." The husband is not
1 CONC known.
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:50:06
0 @N35@ NOTE
1 CONC Comments on "Joseph Tag Torture-Elizabeth Second Smith" FAMILY Record.
1 CONT
1 CONT This record has a second marriage for "Joseph Tag Torture" and the family has one
1 CONC child.
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:50:21
0 @N36@ NOTE
1 CONC Comments on "Standard GEDCOM Filelinks-Torture GEDCOM Matriarch"
1 CONC FAMILY record.
1 CONT
1 CONT The children in this family test logical extensions to the GEDCOM method for
1 CONC linking to a multimedia file.
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:51:33
0 @N37@ NOTE
1 CONC Comments on "Charlie Accented ANSEL-Lucy Special ANSEL" FAMILY Record.
1 CONT
1 CONT The two spouses in this family test reading of the ANSEL character set.
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:52:38
0 @N38@ NOTE
1 CONC Comments on "<unknown>-Nonstandard Multimedia Filelinks" FAMILY Record.
1 CONT
1 CONT The record is simply used to make family connections between records in this file.
1 CHAN
2 DATE 11 Jan 2001
3 TIME 16:53:38
0 @M1@ OBJE
1 TITL Dummy Multimedia Object
1 FORM PICT
1 BLOB
2 CONT .HM.......k.1..F.jwA.Dzzzzw............A....1.........0U.66..E.8
2 CONT .......A..k.a6.A.......A..k.........../6....G.......0../..U.....
2 CONT .w1/m........HC0..../...zzzzzzzz..5zzk..AnA..U..W6U....2rRrRrRrR
2 CONT .Dw...............k.1.......1..A...5ykE/zzzx/.g//.Hxzk6/.Tzy/.k1
2 CONT /Dw/.Tvz.E5zzUE9/kHz.Tw2/DzzzEEA.kE2zk5yzk2/zzs21.U2/Dw/.Tw/.Tzy
2 CONT /.fy/.HzzkHzzzo21Ds00.E2.UE2.U62/.k./Ds0.UE0/Do0..E8/UE2.U62.U9w
2 CONT /.Tx/.20.jg2/jo2..9u/.0U.6A.zk
1 NOTE Here are some notes on this multimedia object.
2 CONT If decoded it should be an image of a flower.
1 REFN User Reference Number
2 TYPE User Reference Type
1 RIN 1
1 CHAN
2 DATE 14 Jan 2001
3 TIME 14:10:31
0 TRLR
''';
