import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

/// Home screen shown after successful authentication
/// This is a placeholder for the main POS functionality
class HomeScreen extends StatelessWidget {
  final AuthProvider authProvider;
  
  const HomeScreen({
    super.key,
    required this.authProvider,
  });
  
  @override
  Widget build(BuildContext context) {
    final user = authProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              // Navigation will be handled by main.dart based on auth state
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (user != null) ...[
                Text(
                  'Email: ${user.email}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (user.fullName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Name: ${user.fullName}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ],
              const SizedBox(height: 48),
              const Text(
                'POS & Inventory Management features coming soon!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

