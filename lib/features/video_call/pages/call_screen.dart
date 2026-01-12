import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:videocalling/core/config/app_imports.dart';
import 'package:videocalling/shared/services/session_management_service.dart';

class CallScreen extends StatefulWidget {
  final String channelName;
  final String token;
  final bool isVideoCall;
  final String opponentName;
  final String? bookingId; // Optional booking ID for session completion
  final String? patientId; // Optional patient ID for session completion
  final String? doctorId; // Optional doctor ID for session completion

  const CallScreen({
    Key? key,
    required this.channelName,
    required this.token,
    required this.isVideoCall,
    required this.opponentName,
    this.bookingId,
    this.patientId,
    this.doctorId,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // --- Votre App ID Agora est inséré ici ---
  final String _appId = "15f7b6b0ab4842d086941d04f7eda2f1";

  late RtcEngine _engine;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isEngineInitialized = false; // Track engine initialization
  // Changed: Support multiple remote users instead of just one
  final List<int> _remoteUids = [];

  // Minuteur pour la durée de l'appel
  Duration _callDuration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _isVideoEnabled = widget.isVideoCall;
    _initAgora();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _disposeAgora();
    super.dispose();
  }

  Future<void> _initAgora() async {
    try {
      // Request camera and microphone permissions first
      print('🔐 Requesting permissions...');
      await [Permission.microphone, Permission.camera].request();
      print('✅ Permissions granted');

      // Créer le moteur RTC
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _appId));

      if (widget.isVideoCall) {
        print('📹 Enabling video...');
        await _engine.enableVideo();
        // Set video encoder configuration for better quality
        await _engine.setVideoEncoderConfiguration(
          const VideoEncoderConfiguration(
            dimensions: VideoDimensions(width: 640, height: 360),
            frameRate: 15,
            bitrate: 0,
          ),
        );
        await _engine.startPreview();
        print('✅ Video preview started');
      } else {
        await _engine.disableVideo();
      }

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print(
              '✅ Successfully joined channel: ${connection.channelId} with UID: ${connection.localUid}',
            );
            if (mounted) {
              setState(() {
                _isJoined = true;
              });
            }
          },
          onUserJoined: (RtcConnection connection, int uid, int elapsed) {
            print('👤 User joined: $uid in channel ${connection.channelId}');
            if (mounted) {
              setState(() {
                if (!_remoteUids.contains(uid)) {
                  _remoteUids.add(uid);
                  print(
                    '📺 Added remote user $uid to list. Total remote users: ${_remoteUids.length}',
                  );
                }
              });
            }
          },
          onUserOffline:
              (
                RtcConnection connection,
                int uid,
                UserOfflineReasonType reason,
              ) {
                print('👋 User offline: $uid, reason: $reason');
                if (mounted) {
                  setState(() {
                    _remoteUids.remove(uid);
                    print(
                      '📺 Removed remote user $uid. Total remote users: ${_remoteUids.length}',
                    );
                  });
                }
              },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            print('📞 Left channel');
            if (mounted) {
              setState(() {
                _isJoined = false;
                _remoteUids.clear();
              });
            }
          },
          onRemoteVideoStateChanged:
              (
                RtcConnection connection,
                int remoteUid,
                RemoteVideoState state,
                RemoteVideoStateReason reason,
                int elapsed,
              ) {
                print(
                  '📹 Remote video state changed for user $remoteUid: state=$state, reason=$reason',
                );
                // Detect remote users when their video state changes (works for users already in channel)
                if (mounted) {
                  setState(() {
                    // Add user when video starts decoding (they're active in channel)
                    if (state == RemoteVideoState.remoteVideoStateDecoding &&
                        !_remoteUids.contains(remoteUid)) {
                      _remoteUids.add(remoteUid);
                      print(
                        '✅ Detected remote user $remoteUid via video state. Total remote users: ${_remoteUids.length}',
                      );
                    }
                    // Also handle audio-only users or users with video disabled
                    if (state == RemoteVideoState.remoteVideoStateStopped &&
                        reason ==
                            RemoteVideoStateReason
                                .remoteVideoStateReasonRemoteUnmuted) {
                      // User is in channel but video is off (audio call or video disabled)
                      if (!_remoteUids.contains(remoteUid)) {
                        _remoteUids.add(remoteUid);
                        print(
                          '✅ Detected remote user $remoteUid (audio only). Total remote users: ${_remoteUids.length}',
                        );
                      }
                    }
                  });
                }
              },
          onRemoteAudioStateChanged:
              (
                RtcConnection connection,
                int remoteUid,
                RemoteAudioState state,
                RemoteAudioStateReason reason,
                int elapsed,
              ) {
                print(
                  '🔊 Remote audio state changed for user $remoteUid: state=$state, reason=$reason',
                );
                // Also detect users via audio state (for audio-only calls or when video is disabled)
                if (mounted) {
                  setState(() {
                    if (state == RemoteAudioState.remoteAudioStateDecoding &&
                        !_remoteUids.contains(remoteUid)) {
                      _remoteUids.add(remoteUid);
                      print(
                        '✅ Detected remote user $remoteUid via audio state. Total remote users: ${_remoteUids.length}',
                      );
                    }
                  });
                }
              },
          onError: (ErrorCodeType err, String msg) {
            print('❌ Agora Error: $err - $msg');
          },
        ),
      );

      // Mark engine as initialized and trigger UI update
      if (mounted) {
        setState(() {
          _isEngineInitialized = true;
        });
        print('✅ Engine initialized, UI should update now');
      }

      // Join channel after everything is set up
      print('🔗 Joining channel: ${widget.channelName}');
      await _engine.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishMicrophoneTrack: true,
          publishCameraTrack: true,
        ),
      );
      print('✅ Join channel request sent');
    } catch (e) {
      print('❌ Error initializing Agora: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = Duration(seconds: timer.tick);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  Future<void> _disposeAgora() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  void _onCallEnd() async {
    // Auto-complete session when video call ends (if booking info provided)
    if (widget.bookingId != null &&
        widget.patientId != null &&
        widget.doctorId != null) {
      try {
        loggerNoStack.i(
          '📞 Video call ended - Auto-completing session: ${widget.bookingId}',
        );

        // Mark booking as completed automatically
        await supabaseHelper.client
            .from('bookings')
            .update({
              'status': 'completed',
              'completed_at': DateTime.now().toIso8601String(),
              'doctor_confirmed': true, // Auto-confirm from video call end
              'patient_confirmed': true, // Auto-confirm from video call end
            })
            .eq('id', widget.bookingId!);

        // Use session management service for payment transfer
        final sessionService = SessionManagementService();
        await sessionService.completeSession(widget.patientId!);

        // Transfer payment to doctor
        await sessionService.confirmSessionFromDoctor(
          bookingId: widget.bookingId!,
          patientId: widget.patientId!,
          doctorId: widget.doctorId!,
        );

        loggerNoStack.i('✅ Session auto-completed after video call');
      } catch (e, stackTrace) {
        loggerNoStack.e('❌ Error auto-completing session after call: $e');
        loggerNoStack.e('Stack trace: $stackTrace');
        // Don't block call ending if completion fails
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onToggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _engine.muteLocalAudioStream(_isMuted);
  }

  void _onToggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    if (_isVideoEnabled) {
      _engine.enableLocalVideo(true);
    } else {
      _engine.enableLocalVideo(false);
    }
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vue principale de la vidéo - Changed to show multiple participants
          Center(child: _remoteVideos()),

          // Aperçu de la vidéo locale (petite fenêtre)
          Positioned(
            top: 40,
            right: 20,
            child: SizedBox(
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _isEngineInitialized && _isVideoEnabled
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isEngineInitialized
                                  ? Icons.person
                                  : Icons.hourglass_empty,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 60,
                            ),
                            if (!_isEngineInitialized)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'initializing'.tr,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ),

          Positioned(
            top: 80,
            left: 20,
            right: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.opponentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isJoined
                      ? '${_formatDuration(_callDuration)} • ${_remoteUids.length} ${_remoteUids.length == 1 ? "participant".tr : "participants".tr}'
                      : 'connecting'.tr,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          // Boutons de contrôle
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Bouton Mute
                _controlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  onPressed: _onToggleMute,
                ),

                // Bouton Vidéo (uniquement pour les appels vidéo)
                if (widget.isVideoCall)
                  _controlButton(
                    icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    onPressed: _onToggleVideo,
                  ),

                // Bouton Changer de caméra (uniquement pour les appels vidéo)
                if (widget.isVideoCall && _isVideoEnabled)
                  _controlButton(
                    icon: Icons.switch_camera,
                    onPressed: _onSwitchCamera,
                  ),

                // Bouton Raccrocher
                _controlButton(
                  icon: Icons.call_end,
                  backgroundColor: Colors.redAccent,
                  onPressed: _onCallEnd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Changed: Support multiple remote users
  Widget _remoteVideos() {
    if (_remoteUids.isNotEmpty) {
      print('🎥 Rendering ${_remoteUids.length} remote video(s): $_remoteUids');
      return widget.isVideoCall
          ? _buildVideoGrid()
          : _audioCallView(); // Vue pour l'appel audio
    } else {
      print('⏳ No remote users yet');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'waiting_for_participants'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Status: ${_isJoined ? "connected".tr : "connecting".tr}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      );
    }
  }

  // New method: Build video grid for multiple participants
  Widget _buildVideoGrid() {
    print('🏗️ Building video grid for ${_remoteUids.length} users');
    if (_remoteUids.length == 1) {
      // Single participant - full screen
      print('📺 Rendering single remote user ${_remoteUids[0]} in full screen');
      return Stack(
        children: [
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine,
              canvas: VideoCanvas(uid: _remoteUids[0]),
              connection: RtcConnection(channelId: widget.channelName),
            ),
          ),
          // Debug overlay
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Remote User: ${_remoteUids[0]}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      );
    } else {
      // Multiple participants - grid layout
      print('📺 Rendering ${_remoteUids.length} users in grid layout');
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _remoteUids.length <= 4 ? 2 : 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _remoteUids.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final uid = _remoteUids[index];
          print('📺 Rendering remote user $uid at grid position $index');
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(uid: uid),
                    connection: RtcConnection(channelId: widget.channelName),
                  ),
                ),
              ),
              // Debug overlay
              Positioned(
                bottom: 5,
                left: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'User: $uid',
                    style: const TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _audioCallView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blueGrey[800],
          child: const Icon(Icons.person, size: 80, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          widget.opponentName,
          style: const TextStyle(color: Colors.white, fontSize: 22),
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return RawMaterialButton(
      onPressed: onPressed,
      shape: const CircleBorder(),
      elevation: 2.0,
      fillColor: backgroundColor ?? Colors.white.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(15.0),
      child: Icon(icon, color: Colors.white, size: 30.0),
    );
  }
}
