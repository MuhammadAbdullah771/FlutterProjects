import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_screen.dart';
import '../auth/login_screen.dart';
import 'screens/splash_screen.dart';

/// Widget that checks authentication state and routes accordingly
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasTimedOut = false;
  bool _showSplash = true;
  Timer? _timeoutTimer;
  Timer? _splashTimer;
  
  static bool _splashShownGlobally = false;

  @override
  void initState() {
    super.initState();
    // Show splash only once on app start (use static variable to persist across rebuilds)
    if (!_splashShownGlobally) {
      _splashTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSplash = false;
            _splashShownGlobally = true;
          });
        }
      });
    } else {
      _showSplash = false;
    }
    
    // Set a timeout to prevent infinite loading
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _hasTimedOut = true;
          _showSplash = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _splashTimer?.cancel();
    super.dispose();
  }

  void _onSplashComplete() {
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen only once on app start (not on navigation)
    if (_showSplash && !_splashShownGlobally) {
      return SplashScreen(onLoadingComplete: _onSplashComplete);
    }

    try {
      final supabase = Supabase.instance.client;
      
      // If timeout, show login screen
      if (_hasTimedOut) {
        return const LoginScreen();
      }
      
      return StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Show loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return const Scaffold(
              backgroundColor: Color(0xFF0D7377),
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4CAF50),
                ),
              ),
            );
          }

          // Cancel timeout if we got data
          _timeoutTimer?.cancel();

          // Handle errors
          if (snapshot.hasError) {
            print('Auth state error: ${snapshot.error}');
            // Show login screen on error
            return const LoginScreen();
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
    } catch (e) {
      print('Error in AuthWrapper: $e');
      // Fallback to login screen on any error
      return const LoginScreen();
    }
  }
}

