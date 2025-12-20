import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/core/utils/logger.dart';

/// FCM Service to handle Firebase Cloud Messaging
class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  /// Initialize FCM service
  static Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        loggerNoStack.i('✅ FCM: User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        loggerNoStack.i('⚠️ FCM: User granted provisional permission');
      } else {
        loggerNoStack.w('❌ FCM: User declined or has not accepted permission');
      }

      // Get FCM token
      await getFCMToken();

      // Configure foreground notification presentation
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Set up message handlers
      _setupMessageHandlers();

      loggerNoStack.i('🔔 FCM Service initialized successfully');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ FCM initialization failed: $e');
      logErrorToCrashlytics(e, stackTrace, reason: 'FCM initialization failed');
    }
  }

  /// Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        loggerNoStack.i('📱 FCM Token: $_fcmToken');
        // Store token in local storage for future use
        final box = GetStorage();
        await box.write('fcm_token', _fcmToken);
      }
      return _fcmToken;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Failed to get FCM token: $e');
      logErrorToCrashlytics(e, stackTrace, reason: 'Failed to get FCM token');
      return null;
    }
  }

  /// Get cached FCM token from storage
  static String? getCachedFCMToken() {
    final box = GetStorage();
    return box.read('fcm_token') ?? _fcmToken;
  }

  /// Setup message handlers for different app states
  static void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle messages when app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle messages when app is terminated
    _handleTerminatedMessage();

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      _fcmToken = token;
      final box = GetStorage();
      box.write('fcm_token', token);
      loggerNoStack.i('🔄 FCM Token refreshed: $token');
    });
  }

  /// Handle messages when app is in foreground
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    loggerNoStack.i('📨 Foreground message received: ${message.messageId}');

    if (kDebugMode) {
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.title}');
    }

    // Show local notification or handle based on your app's logic
    await _processNotificationData(message);
  }

  /// Handle messages when app is opened from background
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    loggerNoStack.i('📨 Background message opened: ${message.messageId}');

    if (kDebugMode) {
      print('Message data: ${message.data}');
    }

    // Navigate to appropriate screen based on notification data
    await _processNotificationData(message);
  }

  /// Handle messages when app is terminated
  static Future<void> _handleTerminatedMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      loggerNoStack.i('📨 Terminated message opened: ${initialMessage.messageId}');

      if (kDebugMode) {
        print('Initial message data: ${initialMessage.data}');
      }

      // Process the notification that opened the app
      await _processNotificationData(initialMessage);
    }
  }

  /// Process notification data and navigate accordingly
  static Future<void> _processNotificationData(RemoteMessage message) async {
    final data = message.data;
    final notificationType = data['type'];

    switch (notificationType) {
      case 'payment_completed':
        await _handlePaymentCompletedNotification(data);
        break;
      case 'appointment_booked':
        await _handleAppointmentNotification(data);
        break;
      case 'chat_message':
        await _handleChatNotification(data);
        break;
      case 'video_call':
        await _handleVideoCallNotification(data);
        break;
      default:
        loggerNoStack.w('⚠️ Unknown notification type: $notificationType');
    }
  }

  /// Handle payment completed notification
  static Future<void> _handlePaymentCompletedNotification(Map<String, dynamic> data) async {
    final appointmentId = data['appointment_id'];
    final doctorId = data['doctor_id'];

    if (doctorId != null) {
      // Navigate to doctor's appointment details
      Get.toNamed(Routes.dAppointmentDetailScreen, arguments: {'id': appointmentId});
    }
  }

  /// Handle appointment notification
  static Future<void> _handleAppointmentNotification(Map<String, dynamic> data) async {
    final appointmentId = data['appointment_id'];
    final isDoctor = data['is_doctor'] == 'true';

    if (isDoctor) {
      Get.toNamed(Routes.dAppointmentDetailScreen, arguments: {'id': appointmentId});
    } else {
      Get.toNamed(Routes.uAppointmentDetailScreen, arguments: {'id': appointmentId});
    }
  }

  /// Handle chat notification
  static Future<void> _handleChatNotification(Map<String, dynamic> data) async {
    final userName = data['user_name'];
    final uid = data['uid'];
    final isUser = data['is_user'] == 'true';

    Get.toNamed(Routes.chatScreen, arguments: {
      'userName': userName,
      'uid': uid,
      'isUser': isUser,
    });
  }

  /// Handle video call notification
  static Future<void> _handleVideoCallNotification(Map<String, dynamic> data) async {
    // Handle video call logic here
    loggerNoStack.i('📹 Video call notification received');
    // You can add your video call handling logic here
  }

  /// Subscribe to topic for broadcast notifications
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      loggerNoStack.i('✅ Subscribed to topic: $topic');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Failed to subscribe to topic $topic: $e');
      logErrorToCrashlytics(e, stackTrace, reason: 'Failed to subscribe to FCM topic');
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      loggerNoStack.i('✅ Unsubscribed from topic: $topic');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Failed to unsubscribe from topic $topic: $e');
      logErrorToCrashlytics(e, stackTrace, reason: 'Failed to unsubscribe from FCM topic');
    }
  }

  /// Delete FCM token
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      final box = GetStorage();
      await box.remove('fcm_token');
      loggerNoStack.i('🗑️ FCM token deleted');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Failed to delete FCM token: $e');
      logErrorToCrashlytics(e, stackTrace, reason: 'Failed to delete FCM token');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp();

  if (kDebugMode) {
    print('📨 Background message received: ${message.messageId}');
    print('Message data: ${message.data}');
  }

  // You can perform background tasks here
  // Note: Don't call Navigator or show dialogs from here
}
