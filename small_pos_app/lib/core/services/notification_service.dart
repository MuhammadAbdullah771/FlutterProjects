import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import '../../inventory/models/product_model.dart';

/// Service for handling local notifications
class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  NotificationService._init();

  /// Initialize notification service
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    // Request permissions
    await requestPermissions();
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    const lowStockChannel = AndroidNotificationChannel(
      'low_stock_channel',
      'Low Stock Alerts',
      description: 'Notifications for products with low stock',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(lowStockChannel);
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosImplementation = _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// Show low stock notification for a product
  Future<void> showLowStockNotification(Product product) async {
    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Low Stock Alerts',
      channelDescription: 'Notifications for products with low stock',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      largeIcon: DrawableResourceAndroidBitmap('@drawable/ic_notification'),
      styleInformation: BigTextStyleInformation(''),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final stockInfo = product.stockQuantity != null
        ? 'Current stock: ${product.stockQuantity}'
        : 'Stock level is low';

    await _notifications.show(
      product.id?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      'Low Stock Alert',
      '${product.name} is running low. $stockInfo',
      notificationDetails,
      payload: product.id,
    );
  }

  /// Show notification for multiple low stock products
  Future<void> showLowStockSummaryNotification(List<Product> lowStockProducts) async {
    if (lowStockProducts.isEmpty) return;

    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Low Stock Alerts',
      channelDescription: 'Notifications for products with low stock',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      largeIcon: DrawableResourceAndroidBitmap('@drawable/ic_notification'),
      styleInformation: BigTextStyleInformation(''),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final count = lowStockProducts.length;
    final title = count == 1
        ? 'Low Stock Alert'
        : '$count Products Low in Stock';

    final body = count == 1
        ? '${lowStockProducts.first.name} is running low'
        : '$count products need restocking. Tap to view details.';

    await _notifications.show(
      'low_stock_summary'.hashCode,
      title,
      body,
      notificationDetails,
      payload: 'low_stock_list',
    );
  }

  /// Check and notify for low stock products
  Future<void> checkLowStockAndNotify(List<Product> products) async {
    final lowStockProducts = products.where((p) => p.isLowStock).toList();

    if (lowStockProducts.isEmpty) return;

    // Show summary notification if multiple products
    if (lowStockProducts.length > 1) {
      await showLowStockSummaryNotification(lowStockProducts);
    } else {
      // Show individual notification for single product
      await showLowStockNotification(lowStockProducts.first);
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to inventory screen
    // This will be handled by the app's navigation system
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}

