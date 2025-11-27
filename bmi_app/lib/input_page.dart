import 'package:flutter/material.dart';
import 'package:bmi_app/repeat_container_code.dart';
import 'package:bmi_app/icon_text.dart';
import 'package:bmi_app/const.dart';
import 'package:bmi_app/result_page.dart';

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

  Widget buildCounterCard(String label, int value, VoidCallback onDecrement, VoidCallback onIncrement) {
    return Expanded(
      child: RepeatContainerCode(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(fontSize: AppSizes.mediumTextSize, color: AppColors.textColor, letterSpacing: 1.2)),
            SizedBox(height: AppSizes.mediumSpacing),
            Text(value.toString(), style: TextStyle(fontSize: AppSizes.largeTextSize, fontWeight: FontWeight.bold, color: AppColors.textColor, letterSpacing: 1.0)),
            SizedBox(height: AppSizes.largeSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "${label}_decrement",
                  onPressed: onDecrement,
                  backgroundColor: AppColors.buttonBackground,
                  mini: true,
                  child: Icon(Icons.remove, color: AppColors.textColor),
                ),
                SizedBox(width: AppSizes.largeSpacing),
                FloatingActionButton(
                  heroTag: "${label}_increment",
                  onPressed: onIncrement,
                  backgroundColor: AppColors.buttonBackground,
                  mini: true,
                  child: Icon(Icons.add, color: AppColors.textColor),
                ),
              ],
            ),
          ],
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
                        letterSpacing: 1.2,
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
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(width: AppSizes.smallSpacing),
                        Text(
                          AppStrings.cm,
                          style: TextStyle(
                            fontSize: AppSizes.mediumTextSize,
                            color: AppColors.textColor.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.largeSpacing),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.sliderActiveColor,
                        inactiveTrackColor: AppColors.sliderInactiveColor.withValues(alpha: 0.3),
                        thumbColor: AppColors.sliderActiveColor,
                        overlayColor: AppColors.sliderActiveColor.withValues(alpha: 0.2),
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: 30.0),
                        trackHeight: 4.0,
                      ),
                      child: Slider(
                        value: height.toDouble(),
                        min: AppDefaults.heightMin,
                        max: AppDefaults.heightMax,
                        onChanged: (double newValue) {
                          setState(() {
                            height = newValue.round();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  buildCounterCard(AppStrings.weight, weight, () => setState(() => weight--), () => setState(() => weight++)),
                  buildCounterCard(AppStrings.age, age, () => setState(() => age--), () => setState(() => age++)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.defaultPadding, vertical: AppSizes.mediumSpacing),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultPage(),
                    ),
                  );
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
                      "CALCULATE",
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

