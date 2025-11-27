import 'package:bmi_app/input_page.dart';
import 'package:bmi_app/const.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BMICalc());
}

class BMICalc extends StatelessWidget {
  const BMICalc({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InputPage(),
      theme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primaryBackground,
        scaffoldBackgroundColor: AppColors.primaryBackground,
      ),
    );
  }
}
