// lib/utils/constants.dart

// Grade aur uske quality points ka map
const Map<String, double> gradePointMap = {
  'A+': 4.0,
  'A': 4.0,
  'A-': 3.7,
  'B+': 3.3,
  'B': 3.0,
  'B-': 2.7,
  'C+': 2.3,
  'C': 2.0,
  'C-': 1.7,
  'D+': 1.3,
  'D': 1.0,
  'F': 0.0,
};

// Grades ki list jo dropdown mein istemal hogi
const List<String> availableGrades = [
  'A+',
  'A',
  'A-',
  'B+',
  'B',
  'B-',
  'C+',
  'C',
  'C-',
  'D+',
  'D',
  'F',
];

// Calculation function (GPA nikalne ka tareeqa)
double calculateGPA(List<Map<String, dynamic>> courses) {
  double totalQualityPoints = 0.0;
  int totalCreditHours = 0;

  for (var course in courses) {
    final grade = course['grade'] as String;
    final credits = course['creditHours'] as int;

    if (gradePointMap.containsKey(grade)) {
      final qualityPoint = gradePointMap[grade]!;
      totalQualityPoints += qualityPoint * credits;
      totalCreditHours += credits;
    }
  }

  if (totalCreditHours == 0) return 0.0;

  return totalQualityPoints / totalCreditHours;
}
