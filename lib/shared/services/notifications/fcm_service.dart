import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:videocalling/core/config/app_imports.dart';

/// FCM Service to handle Firebase Cloud Messaging
class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static String? _fcmToken;
  static final SupabaseHelper _supabaseHelper = SupabaseHelper();

  /// Initialize FCM service
  static Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
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
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
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

        // Save token to Supabase database
        await saveFCMTokenToDatabase(_fcmToken!);
      }
      return _fcmToken;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Failed to get FCM token: $e');
      logErrorToCrashlytics(e, stackTrace, reason: 'Failed to get FCM token');
      return null;
    }
  }

  /// Save FCM token to Supabase database
  static Future<void> saveFCMTokenToDatabase(String token) async {
    try {
      final userId = StorageService.readData(key: LocalStorageKeys.userId);
      if (userId == null || userId.isEmpty) {
        loggerNoStack.w('⚠️ Cannot save FCM token: No user ID found');
        return;
      }

      final isDoctor =
          StorageService.readData(key: LocalStorageKeys.isLoggedInAsDoctor) ==
          true;
      final tableName = isDoctor ? 'doctors' : 'patients';
      final idColumn = isDoctor ? 'doctor_id' : 'patient_id';

      await _supabaseHelper.client
          .from(tableName)
          .update({'fcm_token': token})
          .eq(idColumn, userId);

      loggerNoStack.i('✅ FCM token saved to $tableName for user: $userId');
    } catch (e) {
      loggerNoStack.e('❌ Failed to save FCM token to database: $e');
    }
  }

  /// Clear FCM token from database (on logout)
  static Future<void> clearFCMTokenFromDatabase() async {
    try {
      final userId = StorageService.readData(key: LocalStorageKeys.userId);
      if (userId == null || userId.isEmpty) return;

      final isDoctor =
          StorageService.readData(key: LocalStorageKeys.isLoggedInAsDoctor) ==
          true;
      final tableName = isDoctor ? 'doctors' : 'patients';
      final idColumn = isDoctor ? 'doctor_id' : 'patient_id';

      await _supabaseHelper.client
          .from(tableName)
          .update({'fcm_token': null})
          .eq(idColumn, userId);

      loggerNoStack.i('✅ FCM token cleared from database');
    } catch (e) {
      loggerNoStack.e('❌ Failed to clear FCM token from database: $e');
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
    _firebaseMessaging.onTokenRefresh.listen((String token) async {
      _fcmToken = token;
      final box = GetStorage();
      await box.write('fcm_token', token);
      await saveFCMTokenToDatabase(token);
      loggerNoStack.i('🔄 FCM Token refreshed and saved: $token');
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
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();

    if (initialMessage != null) {
      loggerNoStack.i(
        '📨 Terminated message opened: ${initialMessage.messageId}',
      );

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
  static Future<void> _handlePaymentCompletedNotification(
    Map<String, dynamic> data,
  ) async {
    final appointmentId = data['appointment_id'];
    final doctorId = data['doctor_id'];

    if (doctorId != null) {
      // Navigate to doctor's appointment details
      Get.toNamed(
        Routes.dAppointmentDetailScreen,
        arguments: {'id': appointmentId},
      );
    }
  }

  /// Handle appointment notification
  static Future<void> _handleAppointmentNotification(
    Map<String, dynamic> data,
  ) async {
    final appointmentId = data['appointment_id'];
    final isDoctor = data['is_doctor'] == 'true';

    if (isDoctor) {
      Get.toNamed(
        Routes.dAppointmentDetailScreen,
        arguments: {'id': appointmentId},
      );
    } else {
      Get.toNamed(
        Routes.uAppointmentDetailScreen,
        arguments: {'id': appointmentId},
      );
    }
  }

  /// Handle chat notification
  static Future<void> _handleChatNotification(Map<String, dynamic> data) async {
    final userName = data['user_name'];
    final uid = data['uid'];
    final isUser = data['is_user'] == 'true';

    Get.toNamed(
      Routes.chatScreen,
      arguments: {'userName': userName, 'uid': uid, 'isUser': isUser},
    );
  }

  /// Handle video call notification
  static Future<void> _handleVideoCallNotification(
    Map<String, dynamic> data,
  ) async {
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
      logErrorToCrashlytics(
        e,
        stackTrace,
        reason: 'Failed to subscribe to FCM topic',
      );
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      loggerNoStack.i('✅ Unsubscribed from topic: $topic');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Failed to unsubscribe from topic $topic: $e');
      logErrorToCrashlytics(
        e,
        stackTrace,
        reason: 'Failed to unsubscribe from FCM topic',
      );
    }
  }

  /// Delete FCM token
  static Future<void> deleteToken() async {
    try {
      await clearFCMTokenFromDatabase();
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      final box = GetStorage();
      await box.remove('fcm_token');
      loggerNoStack.i('🗑️ FCM token deleted');
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Failed to delete FCM token: $e');
      logErrorToCrashlytics(
        e,
        stackTrace,
        reason: 'Failed to delete FCM token',
      );
    }
  }

  /// Send notification via Supabase database (with realtime)
  /// This stores the notification in the database and uses Supabase Realtime
  /// for instant delivery to connected clients
  static Future<bool> sendPushNotification({
    required String recipientId,
    required bool isDoctor,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Insert notification into database
      await _supabaseHelper.client.from('notifications').insert({
        'recipient_id': recipientId,
        'recipient_type': isDoctor ? 'doctor' : 'patient',
        'title': title,
        'body': body,
        'notification_type': data?['type'] ?? 'general',
        'data': data ?? {},
        'is_read': false,
      });

      loggerNoStack.i('✅ Notification stored successfully for $recipientId');
      return true;
    } catch (e) {
      loggerNoStack.e('❌ Error storing notification: $e');
      return false;
    }
  }

  /// Subscribe to realtime notifications for the current user
  static RealtimeChannel? _notificationChannel;

  static void subscribeToNotifications({
    required String userId,
    required bool isDoctor,
    required Function(Map<String, dynamic>) onNotification,
  }) {
    final recipientType = isDoctor ? 'doctor' : 'patient';

    _notificationChannel = _supabaseHelper.client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord['recipient_id'] == userId &&
                newRecord['recipient_type'] == recipientType) {
              loggerNoStack.i(
                '📬 New notification received: ${newRecord['title']}',
              );
              onNotification(newRecord);
            }
          },
        )
        .subscribe();

    loggerNoStack.i('🔔 Subscribed to realtime notifications for $userId');
  }

  /// Unsubscribe from realtime notifications
  static Future<void> unsubscribeFromNotifications() async {
    if (_notificationChannel != null) {
      await _supabaseHelper.client.removeChannel(_notificationChannel!);
      _notificationChannel = null;
      loggerNoStack.i('🔕 Unsubscribed from realtime notifications');
    }
  }

  /// Get unread notifications count
  static Future<int> getUnreadCount(String userId, bool isDoctor) async {
    try {
      final response = await _supabaseHelper.client
          .from('notifications')
          .select('id')
          .eq('recipient_id', userId)
          .eq('recipient_type', isDoctor ? 'doctor' : 'patient')
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      loggerNoStack.e('Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _supabaseHelper.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      loggerNoStack.e('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead(String userId, bool isDoctor) async {
    try {
      await _supabaseHelper.client
          .from('notifications')
          .update({'is_read': true})
          .eq('recipient_id', userId)
          .eq('recipient_type', isDoctor ? 'doctor' : 'patient')
          .eq('is_read', false);
    } catch (e) {
      loggerNoStack.e('Error marking all notifications as read: $e');
    }
  }

  /// Send notification on booking status change
  static Future<void> notifyBookingStatusChange({
    required String bookingId,
    required String doctorId,
    required String patientId,
    required String status,
    required String doctorName,
    required String patientName,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'confirmed':
      case '1':
        title = 'Booking Confirmed';
        body = 'Your appointment has been confirmed';
        break;
      case 'cancelled':
      case '4':
        title = 'Booking Cancelled';
        body = 'The appointment has been cancelled';
        break;
      case 'completed':
      case '3':
        title = 'Session Completed';
        body = 'Your session has been marked as completed';
        break;
      case 'rejected':
      case '5':
        title = 'Booking Rejected';
        body = 'The appointment has been rejected';
        break;
      default:
        title = 'Booking Update';
        body = 'Your booking status has been updated';
    }

    // Notify patient
    await sendPushNotification(
      recipientId: patientId,
      isDoctor: false,
      title: title,
      body: '$body with $doctorName',
      data: {
        'type': 'booking_status_change',
        'booking_id': bookingId,
        'status': status,
      },
    );

    // Notify doctor
    await sendPushNotification(
      recipientId: doctorId,
      isDoctor: true,
      title: title,
      body: '$body with $patientName',
      data: {
        'type': 'booking_status_change',
        'booking_id': bookingId,
        'status': status,
      },
    );
  }

  /// Send notification for new chat message
  static Future<void> notifyNewMessage({
    required String recipientId,
    required bool recipientIsDoctor,
    required String senderName,
    required String message,
  }) async {
    await sendPushNotification(
      recipientId: recipientId,
      isDoctor: recipientIsDoctor,
      title: 'New Message from $senderName',
      body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      data: {'type': 'chat_message', 'sender_name': senderName},
    );
  }

  /// Send notification for incoming video call
  static Future<void> notifyIncomingCall({
    required String recipientId,
    required bool recipientIsDoctor,
    required String callerName,
    required String channelId,
  }) async {
    await sendPushNotification(
      recipientId: recipientId,
      isDoctor: recipientIsDoctor,
      title: 'Incoming Video Call',
      body: '$callerName is calling you',
      data: {
        'type': 'video_call',
        'caller_name': callerName,
        'channel_id': channelId,
      },
    );
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized

  if (kDebugMode) {
    print('📨 Background message received: ${message.messageId}');
    print('Message data: ${message.data}');
  }

  // You can perform background tasks here
  // Note: Don't call Navigator or show dialogs from here
}
