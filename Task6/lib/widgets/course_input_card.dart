// lib/widgets/course_input_card.dart

import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../utils/constants.dart';

class CourseInputCard extends StatefulWidget {
  final Subject subject;
  final VoidCallback onDelete;
  final ValueChanged<Subject> onUpdate;

  const CourseInputCard({
    Key? key,
    required this.subject,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<CourseInputCard> createState() => _CourseInputCardState();
}

class _CourseInputCardState extends State<CourseInputCard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _creditsController = TextEditingController();
  late String _selectedGrade;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.subject.name;
    _creditsController.text = widget.subject.creditHours.toString();
    _selectedGrade = widget.subject.grade;

    // Controllers ke changes ko subject mein update karna
    _nameController.addListener(() => _updateSubject());
    _creditsController.addListener(() => _updateSubject());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  void _updateSubject() {
    final name = _nameController.text;
    final credits = int.tryParse(_creditsController.text) ?? 0;

    final updatedSubject = Subject(
      name: name,
      grade: _selectedGrade,
      creditHours: credits,
    );
    widget.onUpdate(updatedSubject);
    // Widget ki internal state update karne ki zaroorat nahi agar parent manage kar raha hai
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Course Name', // Course ka Naam
                      hintText: 'e.g. Calculus I',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: widget.onDelete,
                  tooltip: 'Delete Course', // Course delete karein
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Grade', style: TextStyle(fontSize: 12, color: Colors.grey)), // Grade
                      DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        items: availableGrades.map((String grade) {
                          return DropdownMenuItem<String>(
                            value: grade,
                            child: Text(grade),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedGrade = newValue;
                            });
                            _updateSubject();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Credit Hours', style: TextStyle(fontSize: 12, color: Colors.grey)), // Credit Hours
                      TextFormField(
                        controller: _creditsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'e.g. 3',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
