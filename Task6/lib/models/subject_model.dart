// lib/models/subject_model.dart

// Subject/Course ka data store karne ke liye model
class Subject {
  String name; // Course ka naam (e.g., Introduction to Psychology)
  String grade; // Grade (e.g., A, B+, C-)
  int creditHours; // Credit hours

  Subject({
    required this.name,
    required this.grade,
    required this.creditHours,
  });

  // Map se Subject object banane ke liye factory
  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      name: map['name'] ?? '',
      grade: map['grade'] ?? 'A', // Default grade
      creditHours: map['creditHours'] ?? 3, // Default credit
    );
  }

  // Subject object ko Map mein badalne ke liye
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'grade': grade,
      'creditHours': creditHours,
    };
  }
}
