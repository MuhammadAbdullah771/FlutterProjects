// lib/models/semester_model.dart

import 'subject_model.dart';
import 'dart:convert';

// Semester ka data store karne ke liye model
class Semester {
  int? id; // Database ID (nullable kyunki naye semester ka ID null hoga)
  String semesterName; // Semester ka naam (e.g., Spring 2023) - Hum isko 'Semester' + ID use karenge
  double gpa; // Semester ka calculated GPA
  int totalCreditHours; // Total credit hours of the semester
  List<Subject> subjects; // Is semester ke subjects

  Semester({
    this.id,
    required this.semesterName,
    required this.gpa,
    required this.totalCreditHours,
    required this.subjects,
  });

  // Map se Semester object banane ke liye
  factory Semester.fromMap(Map<String, dynamic> map) {
    // Subjects JSON string ko List<Subject> mein convert karna
    final List<dynamic> subjectMaps = jsonDecode(map['subjects'] as String);
    final subjectsList = subjectMaps.map((s) => Subject.fromMap(s)).toList();

    return Semester(
      id: map['id'],
      semesterName: map['semesterName'] ?? 'Unknown Semester',
      gpa: map['gpa'] ?? 0.0,
      totalCreditHours: map['totalCreditHours'] ?? 0,
      subjects: subjectsList,
    );
  }

  // Semester object ko Map mein badalne ke liye (database ke liye)
  Map<String, dynamic> toMap() {
    // List<Subject> ko JSON string mein convert karna
    final subjectsMapList = subjects.map((s) => s.toMap()).toList();
    final subjectsJsonString = jsonEncode(subjectsMapList);

    return {
      'id': id,
      'semesterName': semesterName,
      'gpa': gpa,
      'totalCreditHours': totalCreditHours,
      'subjects': subjectsJsonString,
    };
  }
}
