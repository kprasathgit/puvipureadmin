import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:puvipureadmin/src/storage/securestorage.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Local notifications plugin
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Android notification channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'admin_channel', // id
    'Admin Notifications', // name
    description: 'Channel for admin app notifications',
    importance: Importance.high,
  );

  /// Callback to handle navigation on notification tap
  static Function(Map<String, dynamic> data)? onNotificationTap;

  /// Pending notification for terminated state
  static Map<String, dynamic>? _pendingData;
  static Map<String, dynamic>? get pendingData => _pendingData;

  /// Initialize everything
  static Future<void> init({Function(Map<String, dynamic> data)? onTap}) async {
    // Set the callback
    onNotificationTap = onTap;
    await _initLocalNotifications();
    await requestPermission();
    await getAndSaveToken();
    _setupForegroundListener();
    _setupBackgroundListener();
    await _handleTerminatedState();
  }

  /// Initialize local notifications
  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        log("📩 Local notification tapped: ${details.payload}");
        // TODO: navigate to screen based on payload
        if (details.payload != null) {
          try {
            final data = {'orderid': details.payload};
            _pendingData = data;
            onNotificationTap?.call(data);
          } catch (e) {
            log("Error parsing payload: $e");
          }
        }
      },
    );

    // Create channel for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  /// Request Android/iOS permission
  static Future<void> requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log("🔔 Notification Permission: ${settings.authorizationStatus}");
  }

  /// Get FCM token and save securely
  static Future<String?> getAndSaveToken() async {
    final token = await _fcm.getToken();
    if (token != null) {
      log("📲 Admin FCM Token: $token");
      await AppSecureStorage.saveToken(token);
    }
    return token;
  }

  /// Foreground notifications → show local notification
  static void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((message) async {
      log(
        "📩 Foreground notification: ${message.notification?.title} | ${message.notification?.body}",
      );
      if (message.data.isNotEmpty) log("📄 Payload: ${message.data}");

      // Show local notification
      await _localNotifications.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['orderid'] ?? message.data.toString(),
      );
    });
  }

  /// Background notification tapped (app minimized)
  static void _setupBackgroundListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log(
        "📩 Background opened notification: ${message.notification?.title} | ${message.notification?.body}",
      );
      if (message.data.isNotEmpty) {
        log("📄 Payload: ${message.data}");
        // TODO: navigate to screen based on payload
        onNotificationTap?.call(message.data);
        _pendingData = message.data;
      }
    });
  }

  /// App opened from terminated state
  static Future<void> _handleTerminatedState() async {
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      log(
        "📩 App launched from terminated notification: ${initialMessage.notification?.title} | ${initialMessage.notification?.body}",
      );
      if (initialMessage.data.isNotEmpty) {
        log("📄 Payload: ${initialMessage.data}");
        // TODO: navigate to screen based on payload
        // onNotificationTap?.call(initialMessage.data);
        _pendingData = initialMessage.data; // store it temporarily
      }
    }
  }

  /// Call this after the app has built its first frame
  static void handlePendingNavigation() {
    if (_pendingData != null && onNotificationTap != null) {
      onNotificationTap!(_pendingData!);
      _pendingData = null;
    }
  }

  static void setPending(Map<String, dynamic> data) {
    _pendingData = data;
  }

  static void clearPending() {
    _pendingData = null;
  }
}
