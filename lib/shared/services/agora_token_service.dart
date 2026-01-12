import 'package:agora_token_generator/agora_token_generator.dart';

class AgoraTokenService {
  final String appId;
  final String appCertificate;

  AgoraTokenService({required this.appId, required this.appCertificate});

  /// Generate RTC token for video/audio calls
  /// [channelName]: The channel name
  /// [uid]: User ID (0 for any user)
  /// [role]: 1 for publisher (can publish), 0 for subscriber (receive only)
  /// [expirationSeconds]: Token expiration time (default 24 hours)
  Future<String?> generateToken({
    required String channelName,
    int uid = 0,
    int role = 1, // 1 = RTC_USER (publisher), 0 = subscriber
    int expirationSeconds = 86400, // 24 hours default
  }) async {
    try {
      final token = RtcTokenBuilder.buildTokenWithUid(
        appId: appId,
        appCertificate: appCertificate,
        channelName: channelName,
        uid: uid,
        tokenExpireSeconds: expirationSeconds,
      );

      print('✅ Token generated for channel: $channelName');
      return token;
    } catch (e) {
      print('❌ Error generating token: $e');
      return null;
    }
  }

  /// Generate RTC token for specific user
  Future<String?> generateUserToken({
    required String channelName,
    required int uid,
    int expirationSeconds = 86400,
  }) async {
    return generateToken(
      channelName: channelName,
      uid: uid,
      role: 1,
      expirationSeconds: expirationSeconds,
    );
  }

  /// Generate token for wildcard channel (works for any channel)
  Future<String?> generateWildcardToken({int expirationSeconds = 86400}) async {
    return generateToken(
      channelName: '*',
      uid: 0,
      role: 1,
      expirationSeconds: expirationSeconds,
    );
  }
}
