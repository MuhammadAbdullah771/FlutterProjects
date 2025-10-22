// lib/screens/cgpa_history_screen.dart

import 'package:flutter/material.dart';
import '../models/semester_model.dart';
import '../database/db_helper.dart';
import '../widgets/semester_card.dart';

class CgpaHistoryScreen extends StatefulWidget {
  const CgpaHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CgpaHistoryScreen> createState() => _CgpaHistoryScreenState();
}

class _CgpaHistoryScreenState extends State<CgpaHistoryScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Semester> _semesters = [];
  double _cgpa = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  // Database se semesters load karna aur CGPA calculate karna
  void _loadSemesters() async {
    setState(() {
      _isLoading = true;
    });

    final semesters = await _dbHelper.getSemesters();
    _calculateCGPA(semesters);

    setState(() {
      _semesters = semesters;
      _isLoading = false;
    });
  }

  // CGPA calculate karne ka tareeqa
  void _calculateCGPA(List<Semester> semesters) {
    double totalQualityPoints = 0.0;
    int totalCreditHours = 0;

    for (var semester in semesters) {
      // Semester GPA * Total Credit Hours (Quality Points)
      totalQualityPoints += semester.gpa * semester.totalCreditHours;
      totalCreditHours += semester.totalCreditHours;
    }

    double calculatedCGPA = 0.0;
    if (totalCreditHours > 0) {
      calculatedCGPA = totalQualityPoints / totalCreditHours;
    }

    setState(() {
      _cgpa = calculatedCGPA;
    });
  }

  // Semester delete karna aur list refresh karna
  void _deleteSemester(int id) async {
    await _dbHelper.deleteSemester(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semester deleted.'), backgroundColor: Colors.orange),
    );
    _loadSemesters(); // List dobara load karein
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculate Your CGPA'), // Apni CGPA Calculate Karein
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CGPA Display Card
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Text(
                              'Your Cumulative GPA (CGPA) is:', // Aapka Cumulative GPA (CGPA) hai:
                              style: TextStyle(fontSize: 18, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _cgpa.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Semesters', // Semesters
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),

                  // Saved Semesters List
                  if (_semesters.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text('No semesters saved yet. Calculate a GPA first!'), // Koi semester save nahi kiya gaya
                      ),
                    ),
                  ..._semesters.map((semester) {
                    return SemesterCard(
                      semester: semester,
                      onDelete: () => _deleteSemester(semester.id!),
                    );
                  }).toList(),

                  // "Add Previous Semester" button - Hum isko GPA Calculator screen par le jayenge
                  // kyunki screen 1 wahi kaam kar rahi hai.
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/gpa_calculator').then((_) => _loadSemesters()),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.blue, width: 1),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add New Semester'), // Naya Semester Shamil Karein
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Calculate CGPA button (niche fixed bar)
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
                // Is button ka kaam sirf list load karna hai, jo humne pehle hi kar diya hai
                // Hum isko refresh button ke tor par istemal karenge
                onPressed: _loadSemesters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Recalculate CGPA'), // Dobara CGPA Calculate Karein
              ),
            ),
          ),
        ],
      ),
    );
  }
}
