/// Class levels offered in the form (spec section 3.2). Stored as-is.
final studentClassLevels = [
  for (var i = 1; i <= 12; i++) 'Class $i',
  'HSC',
  'Admission',
  'Other',
];

/// Subject suggestions as (Bangla, English) pairs. The label in the current
/// language is what gets stored.
const studentSubjectSuggestions = [
  ('বাংলা', 'Bangla'),
  ('ইংরেজি', 'English'),
  ('গণিত', 'Math'),
  ('পদার্থবিজ্ঞান', 'Physics'),
  ('রসায়ন', 'Chemistry'),
  ('জীববিজ্ঞান', 'Biology'),
  ('সাধারণ বিজ্ঞান', 'General Science'),
  ('তথ্য ও যোগাযোগ প্রযুক্তি', 'ICT'),
];

/// Weekdays in the order a Bangladeshi week reads: Saturday first.
/// Values are ISO weekdays (1 = Monday .. 7 = Sunday).
const studentWeekOrder = [6, 7, 1, 2, 3, 4, 5];
