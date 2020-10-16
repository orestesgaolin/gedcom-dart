part of 'element.dart';

// ignore_for_file: constant_identifier_names
/// GEDCOM tags.
/// Ported from https://github.com/nickreynke/python-gedcom/blob/master/gedcom/tags.py

/// Relationship to a mother.
const GEDCOM_PROGRAM_DEFINED_TAG_MREL = '_MREL';

/// Relationship to a father.
const GEDCOM_PROGRAM_DEFINED_TAG_FREL = '_FREL';

/// The event of entering into life.
const GEDCOM_TAG_BIRTH = 'BIRT';

/// The event of the proper disposing of the mortal remains
/// of a deceased person.
const GEDCOM_TAG_BURIAL = 'BURI';

/// The event of the periodic count of the population for a designated locality,
/// such as a national or state Census.
const GEDCOM_TAG_CENSUS = 'CENS';

/// Indicates a change, correction, or modification. Typically
/// used in connection with a [GEDCOM_TAG_DATE]
/// to specify when a change in information occurred.
const GEDCOM_TAG_CHANGE = 'CHAN';

/// The natural, adopted, or sealed (LDS) child of a father and a mother.
const GEDCOM_TAG_CHILD = 'CHIL';

/// An indicator that additional data belongs to the superior value.
/// The information from the `CONC` value is to be connected to the value of
/// the superior preceding line without a space and without a carriage
/// return and/or new line character. Values that are split for a `CONC`
/// tag must always be split at a non-space. If the value is split on a
/// space the space will be lost when concatenation takes place.
/// This is because of the treatment that spaces get as a GEDCOM
/// delimiter, many GEDCOM values are trimmed of trailing spaces
/// and some systems look for the first non-space starting after
/// the tag to determine the beginning of the value.
const GEDCOM_TAG_CONCATENATION = 'CONC';

/// An indicator that additional data belongs to the superior value.
/// The information from the `CONT` value is to be connected to the
/// value of the superior preceding line with a carriage return and/or
/// new line character. Leading spaces could be important to the
/// formatting of the resultant text. When importing values from `CONT`
/// lines the reader should assume only one delimiter character
/// following the `CONT` tag. Assume that the rest of the leading
/// spaces are to be a part of the value.
const GEDCOM_TAG_CONTINUED = 'CONT';

/// The time of an event in a calendar format.
const GEDCOM_TAG_DATE = 'DATE';

/// The event when mortal life terminates.
const GEDCOM_TAG_DEATH = 'DEAT';

/// Identifies a legal, common law, or other customary relationship
/// of man and woman and their children, if any, or a family created
/// by virtue of the birth of a child to its biological father and mother.
const GEDCOM_TAG_FAMILY = 'FAM';

/// Identifies the family in which an individual appears as a child.
const GEDCOM_TAG_FAMILY_CHILD = 'FAMC';

/// Identifies the family in which an individual appears as a spouse.
const GEDCOM_TAG_FAMILY_SPOUSE = 'FAMS';

/// An information storage place that is ordered and arranged for
/// preservation and reference.
const GEDCOM_TAG_FILE = 'FILE';

/// A given or earned name used for official identification of a person.
const GEDCOM_TAG_GIVEN_NAME = 'GIVN';

/// An individual in the family role of a married man or father.
const GEDCOM_TAG_HUSBAND = 'HUSB';

/// A person.
const GEDCOM_TAG_INDIVIDUAL = 'INDI';

/// A legal, common-law, or customary event of creating a family
/// unit of a man and a woman as husband and wife.
const GEDCOM_TAG_MARRIAGE = 'MARR';

/// A word or combination of words used to help identify an individual,
/// title, or other item. More than one NAME line should be used
/// for people who were known by multiple names.
const GEDCOM_TAG_NAME = 'NAME';

/// Pertaining to a grouping of attributes used in describing something.
/// Usually referring to the data required to represent a multimedia
/// object, such an audio recording, a photograph of a person,
/// or an image of a document.
const GEDCOM_TAG_OBJECT = 'OBJE';

/// The type of work or profession of an individual.
const GEDCOM_TAG_OCCUPATION = 'OCCU';

/// A jurisdictional name to identify the place or location of an event.
const GEDCOM_TAG_PLACE = 'PLAC';

/// Flag for private address or event.
const GEDCOM_TAG_PRIVATE = 'PRIV';

/// Indicates the sex of an individual--male or female.
const GEDCOM_TAG_SEX = 'SEX';

/// The initial or original material from which information was obtained.
const GEDCOM_TAG_SOURCE = 'SOUR';

/// A family name passed on or used by members of a family.
const GEDCOM_TAG_SURNAME = 'SURN';

/// An individual in the role as a mother and/or married woman.
const GEDCOM_TAG_WIFE = 'WIFE';
