import 'package:videocalling/core/config/app_imports.dart';

class IncomingCallController extends GetxController {
  final String sessionId = Get.arguments['sessionId'] ?? '';
  final String callerName = Get.arguments['callerName'] ?? 'Unknown';
  final String callerImage = Get.arguments['callerImage'] ?? '';
  final int callType = Get.arguments['callType'] ?? CallType.VIDEO_CALL;

  String get callTypeText {
    switch (callType) {
      case CallType.VIDEO_CALL:
        return 'video_call'.tr;
      case CallType.AUDIO_CALL:
        return 'audio_call'.tr;
      default:
        return 'call'.tr;
    }
  }

  String getCallTitle() => callTypeText;

  Future<bool> onBackPressed(BuildContext context) async {
    return false;
  }

  void acceptCall(BuildContext context) {
    // Navigate to call screen with Agora
    Get.off(
      () => CallScreen(
        channelName: sessionId,
        token: '', // Get token from your backend
        isVideoCall: callType == CallType.VIDEO_CALL,
        opponentName: callerName,
      ),
    );
  }

  void rejectCall(BuildContext context, callSession) {
    // Handle call rejection
    Get.back();
  }
}
