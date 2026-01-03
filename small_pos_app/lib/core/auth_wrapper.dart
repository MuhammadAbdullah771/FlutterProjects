import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_screen.dart';
import '../auth/login_screen.dart';

/// Widget that checks authentication state and routes accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final session = snapshot.data?.session;
        
        // If user is authenticated, show dashboard
        if (session != null) {
          return const DashboardScreen();
        }
        
        // If user is not authenticated, show login screen
        return const LoginScreen();
      },
    );
  }
}

