import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routes.dart';
import 'core/auth_wrapper.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/backup_service.dart';
import 'auth/login_screen.dart';
import 'inventory/inventory_screen.dart';
import 'pos/pos_screen.dart';
import 'customers/customers_screen.dart';
import 'reports/reports_screen.dart';
import 'sync/sync_screen.dart';
import 'core/screens/settings_screen.dart';
import 'pos/returns_screen.dart';
import 'core/screens/expenses_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ilbwbgqpbeqsxmtanvri.supabase.co',
    anonKey: 'sb_publishable_0N51uH9VqirJh0eYtyhUSw_sgyQNYlS',
  );

  // Initialize backup service (loads stored Google client IDs if any)
  await BackupService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Smart POS & Inventory Management',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.theme,
            home: const AuthWrapper(),
            routes: {
              AppRoutes.login: (context) => const LoginScreen(),
              AppRoutes.inventory: (context) => const InventoryScreen(),
              AppRoutes.pos: (context) => const POSScreen(),
              AppRoutes.customers: (context) => const CustomersScreen(),
              AppRoutes.reports: (context) => const ReportsScreen(),
              AppRoutes.sync: (context) => const SyncScreen(),
              AppRoutes.settings: (context) => const SettingsScreen(),
              AppRoutes.returns: (context) => const ReturnsScreen(),
              AppRoutes.expenses: (context) => const ExpensesScreen(),
            },
          );
        },
      ),
    );
  }
}
