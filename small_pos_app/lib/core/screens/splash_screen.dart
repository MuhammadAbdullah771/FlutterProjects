import 'package:flutter/material.dart';
import 'dart:async';

/// Splash/Loading screen matching the design
class SplashScreen extends StatefulWidget {
  final VoidCallback onLoadingComplete;

  const SplashScreen({
    super.key,
    required this.onLoadingComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // Animation controller for loading bar
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      setState(() {
        _progress = _progressAnimation.value;
      });
    });

    // Start animation
    _controller.forward();

    // Simulate loading and navigate after completion
    Timer(const Duration(seconds: 3), () {
      widget.onLoadingComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D7377), // Dark teal/emerald green
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Logo Icon - Square with rounded corners and bar chart
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF0A5D61), // Darker shade for embossed effect
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildBarChartIcon(),
              ),
            ),

            const SizedBox(height: 40),

            // App Title
            const Text(
              'VendoraX POS',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 12),

            // Slogan
            const Text(
              'INTELLIGENCE IN RETAIL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB0B0B0),
                letterSpacing: 2,
              ),
            ),

            const Spacer(flex: 3),

            // Loading Bar Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                children: [
                  // Loading Bar
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A4A4A), // Light gray background
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Stack(
                      children: [
                        // Progress fill
                        FractionallySizedBox(
                          widthFactor: _progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50), // Vibrant green
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Loading Text
                  const Text(
                    'SYSTEM LOADING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB0B0B0),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Bottom Text
            const Text(
              'VENDORA X GLOBAL STANDARD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB0B0B0),
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Build bar chart/equalizer icon - Pattern: short, medium, tall, short, tall, medium, tall
  Widget _buildBarChartIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBar(0.3), // Short
        _buildBar(0.5), // Medium
        _buildBar(0.9), // Tall
        _buildBar(0.3), // Short
        _buildBar(0.9), // Tall
        _buildBar(0.5), // Medium
        _buildBar(0.9), // Tall
      ],
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 8,
      height: 60 * height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

