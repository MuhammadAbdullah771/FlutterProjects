import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routes.dart';
import 'core/auth_wrapper.dart';
import 'core/theme.dart';
import 'auth/login_screen.dart';
import 'inventory/inventory_screen.dart';
import 'pos/pos_screen.dart';
import 'customers/customers_screen.dart';
import 'reports/reports_screen.dart';
import 'sync/sync_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ilbwbgqpbeqsxmtanvri.supabase.co',
    anonKey: 'sb_publishable_0N51uH9VqirJh0eYtyhUSw_sgyQNYlS',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart POS & Inventory Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      routes: {
        // Dashboard route removed - handled by AuthWrapper via 'home' property
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.inventory: (context) => const InventoryScreen(),
        AppRoutes.pos: (context) => const POSScreen(),
        AppRoutes.customers: (context) => const CustomersScreen(),
        AppRoutes.reports: (context) => const ReportsScreen(),
        AppRoutes.sync: (context) => const SyncScreen(),
      },
    );
  }
}
