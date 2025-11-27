import 'package:flutter/material.dart';

class RepeatContainerCode extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final Color? color;

  const RepeatContainerCode({
    this.padding,
    this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
          color: color ?? Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: child,
      ),
    );
  }
}

