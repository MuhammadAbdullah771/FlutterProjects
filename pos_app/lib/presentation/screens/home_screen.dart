import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

/// Home screen shown after successful authentication
/// Redirects to Dashboard screen
class HomeScreen extends StatelessWidget {
  final AuthProvider authProvider;
  
  const HomeScreen({
    super.key,
    required this.authProvider,
  });
  
  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}

