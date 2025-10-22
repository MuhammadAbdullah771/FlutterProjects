// lib/screens/gpa_calculator_screen.dart

import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../utils/constants.dart';
import '../widgets/course_input_card.dart';
import 'semester_result_screen.dart';

class GpaCalculatorScreen extends StatefulWidget {
  const GpaCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  // Shuruat mein 3 default subjects
  List<Subject> _subjects = [
    Subject(name: '', grade: 'A', creditHours: 3),
    Subject(name: '', grade: 'B+', creditHours: 4),
    Subject(name: '', grade: 'A-', creditHours: 3),
  ];

  void _addCourse() {
    setState(() {
      _subjects.add(Subject(name: '', grade: 'A', creditHours: 3));
    });
  }

  void _deleteCourse(int index) {
    setState(() {
      _subjects.removeAt(index);
    });
  }

  void _updateSubject(int index, Subject updatedSubject) {
    // Ye function CourseInputCard se data update karta hai
    _subjects[index] = updatedSubject;
    // Koi zaroorat nahi setState() call karne ki kyunki sirf data model mein change ho raha hai
    // lekin hum isko future mein validation ya live preview ke liye istemal kar sakte hain.
    // For now, hum sirf list update kar rahe hain.
  }

  void _calculateGPA() {
    // Valid data filter karna (name khali na ho aur credits > 0 ho)
    final validCourses = _subjects.where((s) => s.name.isNotEmpty && s.creditHours > 0).toList();

    if (validCourses.isEmpty) {
      // User ko batana ke courses add karein
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one valid course.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // Courses ko Map mein convert karna taake utility function use ho sake
    final coursesForCalculation = validCourses.map((s) => s.toMap()).toList();

    // GPA calculate karna
    final gpa = calculateGPA(coursesForCalculation);
    final totalCredits = validCourses.fold<int>(0, (sum, item) => sum + item.creditHours);


    // Result screen par navigate karna
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SemesterResultScreen(
          gpa: gpa,
          subjects: validCourses,
          totalCredits: totalCredits,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Calculator'), // GPA Calculator
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your course details below to calculate your GPA.', // Apne courses ki tafseelat darj karein
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  // List of Course Input Cards
                  ..._subjects.asMap().entries.map((entry) {
                    int index = entry.key;
                    Subject subject = entry.value;
                    return CourseInputCard(
                      key: ValueKey(subject), // Unique key for widget stability
                      subject: subject,
                      onDelete: () => _deleteCourse(index),
                      onUpdate: (updatedSubject) => _updateSubject(index, updatedSubject),
                    );
                  }).toList(),

                  // Add Another Course button
                  TextButton.icon(
                    onPressed: _addCourse,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Another Course'), // Aur Course Shamil Karein
                  ),
                  const SizedBox(height: 80), // Bottom space
                ],
              ),
            ),
          ),
          // Calculate GPA button (Bottom fixed bar)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateGPA,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Calculate GPA'), // GPA Calculate Karein
              ),
            ),
          ),
        ],
      ),
    );
  }
}
