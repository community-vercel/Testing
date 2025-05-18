import 'dart:developer';

import 'package:code_structure/core/services/agora_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/core/models/call.dart';
import 'package:code_structure/core/repositories/call_repository.dart';
import 'dart:async';

class AudioCallScreen extends StatefulWidget {
  final Call call;
  final Function(Duration)? onCallEnd;

  const AudioCallScreen({
    super.key,
    required this.call,
    this.onCallEnd,
  });

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  RtcEngine? engine;
  bool isMuted = false;
  bool isSpeakerOn = false;
  DateTime? _callStartTime;
  Duration _callDuration = Duration.zero;
  Timer? _durationTimer;
  Timer? _callTimeoutTimer;

  // Call status handling
  late Stream<Call?> _callStream;
  StreamSubscription<Call?>? _callSubscription;
  String _callStatus = 'pending';
  bool _isCallAccepted = false;

  @override
  void initState() {
    super.initState();
    _setupCallStatusListener();
    initializeAgora();
    _startCallTimeout();
  }

  void _setupCallStatusListener() {
    final callRepository = CallRepository();
    _callStream = callRepository.getCallStream(widget.call.callId);
    _callSubscription = _callStream.listen((call) {
      if (mounted && call != null) {
        setState(() {
          _callStatus = call.status;
          if (call.status == 'ongoing' && !_isCallAccepted) {
            _isCallAccepted = true;
            _startCallDurationTimer();
            _callTimeoutTimer?.cancel();
          } else if (call.status == 'ended' || call.status == 'rejected') {
            _handleCallEnd();
          }
        });
      }
    });
  }

  void _startCallDurationTimer() {
    _callStartTime = DateTime.now();
    _durationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = DateTime.now().difference(_callStartTime!);
        });
      }
    });
  }

  void _startCallTimeout() {
    _callTimeoutTimer = Timer(Duration(seconds: 30), () {
      if (mounted && _callStatus == 'pending') {
        _handleCallEnd();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  Future<void> initializeAgora() async {
    log('Starting Agora initialization for audio call');
    log('Call details: ${widget.call.toMap()}');

    try {
      // Request microphone permission
      log('Requesting microphone permission');
      final status = await Permission.microphone.request();
      log('Microphone permission status: $status');

      // Create RTC engine instance
      log('Creating RTC engine instance');
      engine = createAgoraRtcEngine();

      log('Initializing RTC engine with appId: ${AgoraService.appId}');
      await engine!.initialize(RtcEngineContext(
        appId: AgoraService.appId,
      ));
      log('RTC engine initialized successfully');

      // Set event handlers
      log('Setting up RTC engine event handlers');
      engine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          log('Successfully joined channel ${connection.channelId}');
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          log('Remote user joined: $remoteUid');
        },
        onUserOffline: (connection, remoteUid, reason) {
          log('Remote user left: $remoteUid, reason: $reason');
          // End call if remote user left
          _handleCallEnd();
        },
        onError: (err, msg) {
          log('Agora error occurred: $err, message: $msg');
        },
      ));
      log('Event handlers registered successfully');

      // Enable audio
      log('Enabling audio');
      await engine!.enableAudio();
      await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      log('Attempting to join channel with:');
      log('Token: ${widget.call.token}');
      log('Channel Name: ${widget.call.channelName}');

      // Join the channel
      await engine!.joinChannel(
        token: widget.call.token,
        channelId: widget.call.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      log('Channel join request sent successfully');
    } catch (e) {
      log('Error in initializeAgora: $e');
      if (e is AgoraRtcException) {
        log('Agora error code: ${e.code}, message: ${e.message}');
      }
      rethrow;
    }
  }

  void _handleCallEnd() {
    // Stop the duration timer
    _durationTimer?.cancel();

    // Calculate final duration and call the callback
    if (_callStartTime != null && widget.onCallEnd != null) {
      final duration = DateTime.now().difference(_callStartTime!);
      widget.onCallEnd!(duration);
    }

    Navigator.pop(context);
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      engine?.muteLocalAudioStream(isMuted);
    });
  }

  void _toggleSpeaker() {
    setState(() {
      isSpeakerOn = !isSpeakerOn;
      engine?.setEnableSpeakerphone(isSpeakerOn);
    });
  }

  _buildStatus() {
    String displayText = '';
    switch (_callStatus) {
      case 'ongoing':
        displayText = _formatDuration(_callDuration);
        break;
      case 'pending':
        displayText = 'Calling...';
        break;
      case 'ended':
        displayText = 'Call Ended';
        break;
      case 'rejected':
        displayText = 'Call Rejected';
        break;
      default:
        displayText = _callStatus;
    }

    return Text(
      displayText,
      style: style14.copyWith(
        color: subheadingColor2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: transparentColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Text(
              widget.call.receiverName,
              style: style17.copyWith(
                color: headingColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            _buildStatus(),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 100.r,
                        backgroundImage: AssetImage(AppAssets().pic),
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),

                // Bottom section with call controls
                Container(
                  padding: EdgeInsets.symmetric(vertical: 30.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_callStatus == 'ongoing') ...[
                        _buildCallControlButton(
                          icon: isMuted ? Icons.mic : Icons.mic_off,
                          color: PrimarybuttonColor,
                          onPressed: _toggleMute,
                        ),
                        _buildCallControlButton(
                          icon:
                              isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                          color: PrimarybuttonColor,
                          onPressed: _toggleSpeaker,
                        ),
                      ],
                      _buildCallControlButton(
                        icon: Icons.call_end,
                        color: SecondarybuttonColor,
                        onPressed: _handleCallEnd,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: whiteColor,
          size: 30.sp,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _callSubscription?.cancel();
    _durationTimer?.cancel();
    _callTimeoutTimer?.cancel();
    engine?.leaveChannel();
    engine?.release();
    super.dispose();
  }
}
