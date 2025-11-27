import 'package:flutter/material.dart';
import 'package:bmi_app/const.dart';

class ResultPage extends StatelessWidget {
  final double bmi;
  final String result;
  final String interpretation;

  const ResultPage({
    required this.bmi,
    required this.result,
    required this.interpretation,
  });

  Color getResultColor() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMI Result"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: AppSizes.largeSpacing * 2),
                      Text(
                        "Your Result",
                        style: TextStyle(
                          fontSize: AppSizes.mediumTextSize + 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: AppSizes.largeSpacing * 2),
                      Text(
                        result.toUpperCase(),
                        style: TextStyle(
                          fontSize: AppSizes.largeTextSize + 10,
                          fontWeight: FontWeight.bold,
                          color: getResultColor(),
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: AppSizes.largeSpacing * 3),
                      Text(
                        bmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: AppSizes.largeTextSize + 50,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: AppSizes.largeSpacing * 2),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.defaultPadding),
                        child: Text(
                          interpretation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppSizes.mediumTextSize,
                            color: AppColors.textColor,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.defaultPadding, vertical: AppSizes.mediumSpacing),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: AppColors.sliderActiveColor,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                  child: Center(
                    child: Text(
                      "ReCalculate",
                      style: TextStyle(
                        fontSize: AppSizes.mediumTextSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

