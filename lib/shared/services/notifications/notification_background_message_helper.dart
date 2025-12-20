import 'package:videocalling/core/config/app_imports.dart';

void onCallAcceptedWhenTerminated(CallEvent callEvent) {
  print('Call accepted when terminated: ${callEvent.sessionId}');
  // Handle call acceptance with Agora
}

void onCallRejectedWhenTerminated(CallEvent callEvent) {
  print('Call rejected when terminated: ${callEvent.sessionId}');
  // Handle call rejection
}

void processIncomingCallEvent(RemoteMessage event) {
  print('Processing incoming call event: ${event.data}');
  // Process with Agora instead of ConnectyCube
}

void processCallStartEvent(RemoteMessage event) {
  print('Processing call start event: ${event.data}');
  // Process with Agora instead of ConnectyCube
}

// Simple call event class to replace ConnectyCube CallEvent
class CallEvent {
  final String sessionId;
  final int callType;
  final int callerId;
  final String callerName;
  final String? callPhoto;
  final List<int> opponentsIds;

  CallEvent({
    required this.sessionId,
    required this.callType,
    required this.callerId,
    required this.callerName,
    this.callPhoto,
    required this.opponentsIds,
  });
}
