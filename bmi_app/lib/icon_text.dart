import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final double iconSize;
  final double textSize;
  final Color iconColor;
  final Color textColor;
  final double spacing;

  const IconText({
    required this.icon,
    required this.text,
    this.iconSize = 100.0,
    this.textSize = 20.0,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.spacing = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
        SizedBox(height: spacing),
        Text(
          text,
          style: TextStyle(
            fontSize: textSize,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

