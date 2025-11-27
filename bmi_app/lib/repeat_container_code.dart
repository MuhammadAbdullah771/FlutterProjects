import 'package:flutter/material.dart';
import 'package:bmi_app/const.dart';

class RepeatContainerCode extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final Color? color;
  final bool useCard;
  final double? elevation;

  const RepeatContainerCode({
    this.padding,
    this.child,
    this.color,
    this.useCard = false,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(AppSizes.defaultPadding),
      child: useCard
          ? Card(
              color: color ?? AppColors.containerColor,
              elevation: elevation ?? 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: child,
            )
          : Container(
              decoration: BoxDecoration(
                color: color ?? AppColors.containerColor,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: child,
            ),
    );
  }
}

