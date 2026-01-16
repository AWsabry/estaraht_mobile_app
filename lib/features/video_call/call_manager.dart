import 'package:videocalling/core/config/app_imports.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallManager {
  static CallManager? _instance;
  static CallManager get instance => _instance ??= CallManager._internal();
  CallManager._internal();

  RtcEngine? _engine;
  String? _currentChannelName;
  bool _isInCall = false;

  // Initialize Agora engine
  Future<void> init() async {
    try {
      final appId = dotenv.get('AGORA_APP_ID', fallback: '');
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        const RtcEngineContext(
          appId: 'YOUR_AGORA_APP_ID', // Replace with your actual Agora App ID
        ),
      );

      await _engine!.enableVideo();
      print('✅ Agora engine initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Agora engine: $e');
    }
  }

  // Start a call
  Future<void> startCall({
    required String channelName,
    required String token,
    required bool isVideoCall,
    required String opponentName,
    String? bookingId, // Optional for session completion
    String? patientId, // Optional for session completion
    String? doctorId, // Optional for session completion
  }) async {
    if (_engine == null) {
      await init();
    }

    try {
      _currentChannelName = channelName;
      _isInCall = true;

      // Navigate to call screen
      Get.to(
        () => CallScreen(
          channelName: channelName,
          token: token,
          isVideoCall: isVideoCall,
          opponentName: opponentName,
          bookingId: bookingId,
          patientId: patientId,
          doctorId: doctorId,
        ),
      );
    } catch (e) {
      print('❌ Failed to start call: $e');
    }
  }

  // Accept incoming call
  void acceptCall({String? sessionId, bool? fromCallkit}) {
    print('✅ Call accepted');
    // Handle call acceptance with Agora
  }

  // Reject incoming call
  void rejectCall({String? sessionId, bool? fromCallkit}) {
    print('❌ Call rejected');
    // Handle call rejection
  }

  // End current call
  Future<void> endCall() async {
    try {
      if (_engine != null && _isInCall) {
        await _engine!.leaveChannel();
        _isInCall = false;
        _currentChannelName = null;
      }
      Get.back();
    } catch (e) {
      print('❌ Failed to end call: $e');
    }
  }

  // Mute/unmute call
  void muteCall(String sessionId, bool mute) {
    _engine?.muteLocalAudioStream(mute);
  }

  // Cleanup resources
  Future<void> destroy() async {
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        await _engine!.release();
        _engine = null;
      }
      _isInCall = false;
      _currentChannelName = null;
    } catch (e) {
      print('❌ Failed to destroy call manager: $e');
    }
  }

  // Check if currently in a call
  bool get isInCall => _isInCall;

  // Get current channel name
  String? get currentChannelName => _currentChannelName;
}
