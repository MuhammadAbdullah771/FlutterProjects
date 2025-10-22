// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/gpa_calculator_screen.dart';
import 'screens/cgpa_history_screen.dart';
// Note: SemesterResultScreen ko routes mein shamil karne ki zaroorat nahi kyunki
// yeh sirf GPA Calculator screen se navigate ho raha hai.

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CgpaCalculatorApp());
}

class CgpaCalculatorApp extends StatelessWidget {
  const CgpaCalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGPA Calculator', // CGPA Calculator App
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter', // Inter font ka istemal (Agar available ho)
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      // Home screen CGPA History wali hogi, jahan se user GPA Calculator par ja sakta hai
      initialRoute: '/cgpa_history',
      routes: {
        '/cgpa_history': (context) => const CgpaHistoryScreen(),
        '/gpa_calculator': (context) => const GpaCalculatorScreen(),
      },
    );
  }
}