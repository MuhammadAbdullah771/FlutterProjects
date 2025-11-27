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

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMI CALCULATOR"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: RepeatContainerCode(),
                  ),
                  Expanded(
                    child: RepeatContainerCode(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RepeatContainerCode(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: RepeatContainerCode(),
                  ),
                  Expanded(
                    child: RepeatContainerCode(color: Colors.blue),
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

