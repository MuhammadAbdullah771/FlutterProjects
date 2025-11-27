import 'package:flutter/material.dart';
import 'package:bmi_app/const.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
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
                    "RE-CALCULATE",
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
        ),
      ),
    );
  }
}

