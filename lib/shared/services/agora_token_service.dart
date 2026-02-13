import 'package:agora_token_generator/agora_token_generator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AgoraTokenService {
  static final AgoraTokenService _instance = AgoraTokenService._internal();

  late String _appId;
  late String _appCertificate;

  AgoraTokenService._internal() {
    // Load from environment variables
    _appId = dotenv.get('AGORA_APP_ID', fallback: '');
    _appCertificate = dotenv.get('AGORA_APP_CERTIFICATE', fallback: '');

    if (_appId.isEmpty || _appCertificate.isEmpty) {
      throw Exception(
        'Missing Agora credentials in .env file. '
        'Please ensure AGORA_APP_ID and AGORA_APP_CERTIFICATE are set.',
      );
    }
  }

  factory AgoraTokenService() {
    return _instance;
  }

  /// Generate RTC token for video/audio calls
  /// [channelName]: The channel name
  /// [uid]: User ID (0 for any user)
  /// [tokenExpireSeconds]: Token expiration time (default 24 hours)
  Future<String?> generateToken({
    required String channelName,
    int uid = 0,
    int tokenExpireSeconds = 86400, // 24 hours default
  }) async {
    try {
      final token = RtcTokenBuilder.buildTokenWithUid(
        appId: _appId,
        appCertificate: _appCertificate,
        channelName: channelName,
        uid: uid,
        tokenExpireSeconds: tokenExpireSeconds,
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
    int tokenExpireSeconds = 86400,
  }) async {
    return generateToken(
      channelName: channelName,
      uid: uid,
      tokenExpireSeconds: tokenExpireSeconds,
    );
  }

  /// Generate token for wildcard channel (works for any channel)
  Future<String?> generateWildcardToken({
    int tokenExpireSeconds = 86400,
  }) async {
    return generateToken(
      channelName: '*',
      uid: 0,
      tokenExpireSeconds: tokenExpireSeconds,
    );
  }
}
