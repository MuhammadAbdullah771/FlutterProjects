import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routes.dart';
import 'core/auth_wrapper.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/backup_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_notification_service.dart';
import 'core/services/printer_service.dart';
import 'auth/login_screen.dart';
import 'inventory/inventory_screen.dart';
import 'pos/pos_screen.dart';
import 'customers/customers_screen.dart';
import 'reports/reports_screen.dart';
import 'sync/sync_screen.dart';
import 'core/screens/settings_screen.dart';
import 'pos/returns_screen.dart';
import 'core/screens/expenses_screen.dart';
import 'core/screens/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handle Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  // Handle platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    print('Platform Error: $error');
    print('Stack trace: $stack');
    return true;
  };

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://ilbwbgqpbeqsxmtanvri.supabase.co',
      anonKey: 'sb_publishable_0N51uH9VqirJh0eYtyhUSw_sgyQNYlS',
    );
  } catch (e) {
    print('Error initializing Supabase: $e');
    // Continue anyway - app can work offline
  }

  try {
    // Initialize backup service (loads stored Google client IDs if any)
    await BackupService.instance.init();
  } catch (e) {
    print('Error initializing BackupService: $e');
    // Continue anyway - backup is optional
  }

  try {
    // Initialize local notification service
    await NotificationService.instance.initialize();
  } catch (e) {
    print('Error initializing NotificationService: $e');
    // Continue anyway - notifications are optional
  }

  try {
    // Initialize Supabase real-time push notifications
    await SupabaseNotificationService.instance.initialize();
  } catch (e) {
    print('Error initializing SupabaseNotificationService: $e');
    // Continue anyway - real-time notifications are optional
  }

  try {
    // Load saved printer preference
    await PrinterService.instance.loadSavedPrinter();
  } catch (e) {
    print('Error loading printer: $e');
    // Continue anyway - printer setup is optional
  }

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
            title: 'VendoraX POS',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.theme,
            home: Builder(
              builder: (context) {
                try {
                  return const AuthWrapper();
                } catch (e) {
                  print('Error building AuthWrapper: $e');
                  return const LoginScreen();
                }
              },
            ),
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
              AppRoutes.notifications: (context) => const NotificationsScreen(),
            },
            builder: (context, child) {
              // Ensure we always have a widget to display
              if (child == null) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return child;
            },
          );
        },
      ),
    );
  }
}
