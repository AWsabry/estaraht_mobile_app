import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/others/timezone_service.dart';

/// HTTP Push Notification Service for sending FCM notifications
class PushNotificationService {
  static const String _serviceAccountPath = 'service_account.json';
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  /// Get access token for Firebase Cloud Messaging API
  static Future<AccessCredentials?> _getAccessToken() async {
    try {
      // Load service account from assets
      String serviceAccountJson = await rootBundle.loadString(
        _serviceAccountPath,
      );

      final serviceAccount = ServiceAccountCredentials.fromJson(
        jsonDecode(serviceAccountJson),
      );

      final client = await clientViaServiceAccount(serviceAccount, _scopes);
      return client.credentials;
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Failed to get access token: $e');
      logErrorToCrashlytics(
        e,
        stackTrace,
        reason: 'Failed to get FCM access token',
      );
      return null;
    }
  }

  /// Send push notification to a specific device
  static Future<bool> sendPushNotification({
    required String deviceToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    if (deviceToken.isEmpty) {
      loggerNoStack.w('⚠️ Device token is empty');
      return false;
    }

    try {
      final credentials = await _getAccessToken();
      if (credentials == null) {
        loggerNoStack.e('❌ Failed to get credentials');
        return false;
      }

      final accessToken = credentials.accessToken.data;
      const projectId =
          'your-project-id'; // Replace with your Firebase project ID

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );

      final message = {
        'message': {
          'token': deviceToken,
          'notification': {
            'title': title,
            'body': body,
            if (imageUrl != null) 'image': imageUrl,
          },
          'data': data ?? {},
          'android': {
            'notification': {
              'channel_id': 'high_importance_channel',
              'priority': 'high',
              'sound': 'default',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'alert': {'title': title, 'body': body},
                'sound': 'default',
                'badge': 1,
              },
            },
          },
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        loggerNoStack.i(
          '✅ Notification sent successfully to device: ${deviceToken.substring(0, 10)}...',
        );
        return true;
      } else {
        loggerNoStack.e(
          '❌ Failed to send notification: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error sending notification: $e');
      logErrorToCrashlytics(
        e,
        stackTrace,
        reason: 'Failed to send push notification',
      );
      return false;
    }
  }

  /// Send notification to multiple devices
  static Future<Map<String, bool>> sendMultipleNotifications({
    required List<String> deviceTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    Map<String, bool> results = {};

    for (String token in deviceTokens) {
      if (token.isNotEmpty) {
        bool success = await sendPushNotification(
          deviceToken: token,
          title: title,
          body: body,
          data: data,
          imageUrl: imageUrl,
        );
        results[token] = success;
      }
    }

    return results;
  }

  /// Send payment completion notification to doctor
  static Future<bool> sendPaymentCompletionNotification({
    required String doctorToken,
    required String patientName,
    required String appointmentId,
    required double amount,
  }) async {
    const title = 'Payment Received! 💰';
    final body =
        '$patientName has completed payment for appointment. Amount: \$${amount.toStringAsFixed(2)}';

    final data = {
      'type': 'payment_completed',
      'appointment_id': appointmentId,
      'doctor_id': 'doctor_id_here', // Replace with actual doctor ID
      'patient_name': patientName,
      'amount': amount.toString(),
      'timestamp': TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch.toString(),
    };

    return await sendPushNotification(
      deviceToken: doctorToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Send appointment booking notification
  static Future<bool> sendAppointmentBookingNotification({
    required String recipientToken,
    required String patientName,
    required String doctorName,
    required String appointmentDate,
    required String appointmentTime,
    required String appointmentId,
    required bool isForDoctor,
  }) async {
    final title = isForDoctor
        ? 'New Appointment Booked! 📅'
        : 'Appointment Confirmed! ✅';

    final body = isForDoctor
        ? '$patientName has booked an appointment with you on $appointmentDate at $appointmentTime'
        : 'Your appointment with Dr. $doctorName is confirmed for $appointmentDate at $appointmentTime';

    final data = {
      'type': 'appointment_booked',
      'appointment_id': appointmentId,
      'patient_name': patientName,
      'doctor_name': doctorName,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'is_doctor': isForDoctor.toString(),
      'timestamp': TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch.toString(),
    };

    return await sendPushNotification(
      deviceToken: recipientToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Send appointment reminder notification
  static Future<bool> sendAppointmentReminderNotification({
    required String recipientToken,
    required String doctorName,
    required String patientName,
    required String appointmentTime,
    required String appointmentId,
    required bool isForDoctor,
  }) async {
    const title = 'Appointment Reminder ⏰';
    final body = isForDoctor
        ? 'You have an appointment with $patientName in 30 minutes at $appointmentTime'
        : 'Your appointment with Dr. $doctorName is in 30 minutes at $appointmentTime';

    final data = {
      'type': 'appointment_reminder',
      'appointment_id': appointmentId,
      'patient_name': patientName,
      'doctor_name': doctorName,
      'appointment_time': appointmentTime,
      'is_doctor': isForDoctor.toString(),
      'timestamp': TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch.toString(),
    };

    return await sendPushNotification(
      deviceToken: recipientToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Send chat message notification
  static Future<bool> sendChatMessageNotification({
    required String recipientToken,
    required String senderName,
    required String message,
    required String chatId,
    required String senderId,
    required bool isFromDoctor,
  }) async {
    final title = isFromDoctor ? 'Dr. $senderName' : senderName;
    final body = message.length > 50
        ? '${message.substring(0, 50)}...'
        : message;

    final data = {
      'type': 'chat_message',
      'chat_id': chatId,
      'sender_id': senderId,
      'sender_name': senderName,
      'message': message,
      'is_from_doctor': isFromDoctor.toString(),
      'timestamp': TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch.toString(),
    };

    return await sendPushNotification(
      deviceToken: recipientToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Send video call notification
  static Future<bool> sendVideoCallNotification({
    required String recipientToken,
    required String callerName,
    required String callId,
    required String channelId,
    required bool isFromDoctor,
  }) async {
    final title = isFromDoctor
        ? 'Incoming Call from Dr. $callerName 📞'
        : 'Incoming Call from $callerName 📞';

    const body = 'Tap to answer the video call';

    final data = {
      'type': 'video_call',
      'call_id': callId,
      'channel_id': channelId,
      'caller_name': callerName,
      'is_from_doctor': isFromDoctor.toString(),
      'timestamp': TimezoneService.getCurrentMauritaniaTime().millisecondsSinceEpoch.toString(),
    };

    return await sendPushNotification(
      deviceToken: recipientToken,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Send topic-based notification (broadcast)
  static Future<bool> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      final credentials = await _getAccessToken();
      if (credentials == null) {
        loggerNoStack.e('❌ Failed to get credentials for topic notification');
        return false;
      }

      final accessToken = credentials.accessToken.data;
      const projectId =
          'your-project-id'; // Replace with your Firebase project ID

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );

      final message = {
        'message': {
          'topic': topic,
          'notification': {
            'title': title,
            'body': body,
            if (imageUrl != null) 'image': imageUrl,
          },
          'data': data ?? {},
          'android': {
            'notification': {
              'channel_id': 'high_importance_channel',
              'priority': 'high',
              'sound': 'default',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'alert': {'title': title, 'body': body},
                'sound': 'default',
              },
            },
          },
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        loggerNoStack.i('✅ Topic notification sent successfully to: $topic');
        return true;
      } else {
        loggerNoStack.e(
          '❌ Failed to send topic notification: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e, stackTrace) {
      loggerNoStack.e('❌ Error sending topic notification: $e');
      logErrorToCrashlytics(
        e,
        stackTrace,
        reason: 'Failed to send topic notification',
      );
      return false;
    }
  }
}
