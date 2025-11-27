import 'package:flutter/material.dart';
import 'package:bmi_app/repeat_container_code.dart';
import 'package:bmi_app/icon_text.dart';
import 'package:bmi_app/const.dart';

enum Gender { male, female }

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  int height = AppDefaults.defaultHeight;
  int weight = AppDefaults.defaultWeight;
  int age = AppDefaults.defaultAge;
  Gender? selectedGender;

  Widget buildGestureDetector(VoidCallback onTap, Widget child) {
    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }

  Widget buildGenderCard(Gender gender, IconData icon, String label) {
    return Expanded(
      child: buildGestureDetector(
        () => setState(() => selectedGender = gender),
        RepeatContainerCode(
          color: selectedGender == gender ? AppColors.activeContainerColor : AppColors.containerColor,
          child: IconText(icon: icon, text: label, iconColor: AppColors.textColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  buildGenderCard(Gender.male, Icons.male, AppStrings.male),
                  buildGenderCard(Gender.female, Icons.female, AppStrings.female),
                ],
              ),
            ),
            Expanded(
              child: RepeatContainerCode(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.height,
                      style: TextStyle(
                        fontSize: AppSizes.mediumTextSize,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: AppSizes.mediumSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          height.toString(),
                          style: TextStyle(
                            fontSize: AppSizes.largeTextSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(width: AppSizes.smallSpacing),
                        Text(
                          AppStrings.cm,
                          style: TextStyle(
                            fontSize: AppSizes.mediumTextSize,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.largeSpacing),
                    Slider(
                      value: height.toDouble(),
                      min: AppDefaults.heightMin,
                      max: AppDefaults.heightMax,
                      activeColor: AppColors.sliderActiveColor,
                      inactiveColor: AppColors.sliderInactiveColor,
                      onChanged: (double newValue) {
                        setState(() {
                          height = newValue.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: RepeatContainerCode(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.weight,
                            style: TextStyle(
                              fontSize: AppSizes.mediumTextSize,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(height: AppSizes.mediumSpacing),
                          Text(
                            weight.toString(),
                            style: TextStyle(
                              fontSize: AppSizes.largeTextSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(height: AppSizes.largeSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    weight--;
                                  });
                                },
                                backgroundColor: AppColors.buttonBackground,
                                mini: true,
                                child: Icon(Icons.remove, color: AppColors.textColor),
                              ),
                              SizedBox(width: AppSizes.largeSpacing),
                              FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    weight++;
                                  });
                                },
                                backgroundColor: AppColors.buttonBackground,
                                mini: true,
                                child: Icon(Icons.add, color: AppColors.textColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: RepeatContainerCode(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.age,
                            style: TextStyle(
                              fontSize: AppSizes.mediumTextSize,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(height: AppSizes.mediumSpacing),
                          Text(
                            age.toString(),
                            style: TextStyle(
                              fontSize: AppSizes.largeTextSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(height: AppSizes.largeSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    age--;
                                  });
                                },
                                backgroundColor: AppColors.buttonBackground,
                                mini: true,
                                child: Icon(Icons.remove, color: AppColors.textColor),
                              ),
                              SizedBox(width: AppSizes.largeSpacing),
                              FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    age++;
                                  });
                                },
                                backgroundColor: AppColors.buttonBackground,
                                mini: true,
                                child: Icon(Icons.add, color: AppColors.textColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

