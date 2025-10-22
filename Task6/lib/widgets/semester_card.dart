// lib/widgets/semester_card.dart

import 'package:flutter/material.dart';
import '../models/semester_model.dart';

class SemesterCard extends StatelessWidget {
  final Semester semester;
  final VoidCallback onDelete;

  const SemesterCard({
    Key? key,
    required this.semester,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.school, size: 30, color: Colors.blueAccent), // Education icon
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semester: ${semester.id}', // Screen 3 par ID ke bajaye 'Semester GPA' ka text aur uski value dikhana hai.
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade800),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Semester GPA',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            '${semester.gpa.toStringAsFixed(2)}', // Calculated GPA
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Credit Hours',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            '${semester.totalCreditHours}', // Total Credit Hours
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
              tooltip: 'Delete Semester', // Semester delete karein
            ),
          ],
        ),
      ),
    );
  }
}
