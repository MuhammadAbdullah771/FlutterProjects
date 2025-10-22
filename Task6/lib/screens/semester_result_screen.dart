// lib/screens/semester_result_screen.dart

import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../models/semester_model.dart';
import '../database/db_helper.dart';
import 'cgpa_history_screen.dart';

class SemesterResultScreen extends StatelessWidget {
  final double gpa;
  final List<Subject> subjects;
  final int totalCredits;

  const SemesterResultScreen({
    Key? key,
    required this.gpa,
    required this.subjects,
    required this.totalCredits,
  }) : super(key: key);

  void _saveToCGPA(BuildContext context) async {
    // DBHelper ka instance
    final dbHelper = DBHelper();

    // Naya Semester object banana
    final semester = Semester(
      semesterName: 'Semester ${DateTime.now().year}-${DateTime.now().month}', // A simple unique name
      gpa: gpa,
      totalCreditHours: totalCredits,
      subjects: subjects,
    );

    // Database mein save karna
    await dbHelper.insertSemester(semester);

    // Success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semester saved to CGPA history successfully!'), backgroundColor: Colors.green),
    );

    // CGPA history screen par wapas jana aur usko refresh karna
    Navigator.of(context).popUntil((route) => route.isFirst); // Pehli screen par wapas
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CgpaHistoryScreen()), // Aur CGPA screen open karna
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semester GPA'), // Semester GPA
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
                  // GPA Display Card
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              gpa.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade600,
                              ),
                            ),
                            const Text(
                              'Grade Point Average', // Grade Point Average
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Course Breakdown', // Course ki Tafseel
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),

                  // Course Breakdown List
                  ...subjects.map((subject) {
                    // Yahan hum Course Breakdown dikha rahe hain
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: ListTile(
                        leading: const Icon(Icons.menu_book, color: Colors.blueAccent),
                        title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Credits: ${subject.creditHours}'),
                        trailing: Text(
                          subject.grade,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          // Action Buttons (Bottom fixed bar)
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
            child: Row(
              children: [
                // Recalculate button (wapas GPA screen par)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Recalculate'), // Dobara Calculate Karein
                  ),
                ),
                const SizedBox(width: 16),
                // Save to CGPA button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveToCGPA(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Save to CGPA'), // CGPA mein Save Karein
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
