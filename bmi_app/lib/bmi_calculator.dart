import 'package:flutter/material.dart';

class BMICalculator {
  final int height;
  final int weight;

  BMICalculator({
    required this.height,
    required this.weight,
  });

  double calculateBMI() {
    return weight / ((height / 100) * (height / 100));
  }

  String getResult() {
    double bmi = calculateBMI();
    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi < 25) {
      return "Normal";
    } else if (bmi < 30) {
      return "Overweight";
    } else {
      return "Obese";
    }
  }

  String getInterpretation() {
    double bmi = calculateBMI();
    if (bmi < 18.5) {
      return "BMI is Low You Should have to Work More";
    } else if (bmi < 25) {
      return "You have a normal body weight. Good job!";
    } else if (bmi < 30) {
      return "BMI is High You Should have to Work More";
    } else {
      return "BMI is Very High You Should have to Work More";
    }
  }

  Color getResultColor() {
    double bmi = calculateBMI();
    if (bmi < 18.5) {
      return Colors.orange;
    } else if (bmi < 25) {
      return Colors.green;
    } else if (bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

