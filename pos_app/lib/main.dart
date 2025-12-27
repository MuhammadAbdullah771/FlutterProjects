import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'core/constants/app_constants.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';

/// Main entry point of the application
/// Initializes dependencies and sets up the app structure
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all dependencies (Supabase, local storage, etc.)
  await ServiceLocator().initialize();
  
  // Run the app
  runApp(const MyApp());
}

/// Root widget of the application
/// Manages app-wide configuration and routing
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Customize app theme here
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper widget that handles authentication state
/// Shows LoginScreen if user is not authenticated, HomeScreen if authenticated
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen to auth state changes
    ServiceLocator().authProvider.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    ServiceLocator().authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  /// Called when authentication state changes
  /// Rebuilds the widget to show appropriate screen
  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = ServiceLocator().authProvider;
    
    // Show loading indicator while checking auth state
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Show HomeScreen if authenticated, LoginScreen otherwise
    if (authProvider.isAuthenticated) {
      return HomeScreen(authProvider: authProvider);
    } else {
      return LoginScreen(authProvider: authProvider);
    }
  }
}
