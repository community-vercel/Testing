// ignore_for_file: unused_local_variable

import 'dart:developer';
import 'dart:convert';
import 'package:code_structure/core/services/call_minutes_service.dart';
import 'package:code_structure/ui/screens/call/audio_call_screen.dart';
import 'package:code_structure/ui/screens/call/incoming_call_screen.dart';
import 'package:code_structure/ui/screens/call/video_call_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter/material.dart';
import '../repositories/call_repository.dart';
import '../models/call.dart';
import '../services/notification_service.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
class CallService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final CallRepository _callRepository = CallRepository();
  final NotificationService _notificationService = NotificationService();
  bool _callKeepInitialized = false;
  final GlobalKey<NavigatorState> navigatorKey;
  Call? _currentCall;
  static const String _activeCallKey = 'active_call_data';

  CallService({required this.navigatorKey});

  Future<void> initialize() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        print('Notification permission denied');
      }
    }

    // Check for saved call data when app initializes
    // await _checkSavedCallData();

    // Configure flutter_callkeep
    if (!_callKeepInitialized) {
      try {
        final config = CallKeepConfig(
          appName: 'Buzz Me',
          android: CallKeepAndroidConfig(
            logo: 'mipmap/ic_launcher',
            notificationIcon: 'mipmap/ic_launcher',
            ringtoneFileName: 'system_ringtone_default',
            accentColor: '#0955fa',
            incomingCallNotificationChannelName: 'Incoming Calls',
            missedCallNotificationChannelName: 'Missed Calls',
            showMissedCallNotification: true,
            showCallBackAction: true,
          ),
          ios: CallKeepIosConfig(
            iconName: 'CallKitLogo',
            maximumCallGroups: 2,
            maximumCallsPerCallGroup: 1,
          ),
          headers: <String, dynamic>{},
        );

        CallKeep.instance.configure(config);
        _callKeepInitialized = true;

        // Register event handlers
        _registerCallKeepEventHandlers();

        // Check for active calls when app is initialized
        await checkAndNavigateToCallScreen();
      } catch (e) {
        print('Error initializing CallKeep: $e');
      }
    }

    // Handle incoming call notifications
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Future<void> _checkSavedCallData() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final savedCallData = prefs.getString(_activeCallKey);

  //     if (savedCallData != null) {
  //       log('Found saved call data: $savedCallData');
  //       final Map<String, dynamic> callData =
  //           Map<String, dynamic>.from(json.decode(savedCallData));

  //       // Navigate to call screen
  //       if (navigatorKey.currentContext != null) {
  //         final call = Call.fromMap(callData);
  //         _currentCall = call;
  //         await checkAndNavigateToCallScreen();
  //       }

  //       // Remove saved data after handling
  //       await prefs.remove(_activeCallKey);
  //     }
  //   } catch (e) {
  //     log('Error checking saved call data: $e');
  //   }
  // }

  Future<void> _saveCallData(Call call) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeCallKey, json.encode(call.toMap()));
      log('Saved call data for ID: ${call.callId}');
    } catch (e) {
      log('Error saving call data: $e');
    }
  }
  

  void _registerCallKeepEventHandlers() {
    CallKeep.instance.handler = CallEventHandler(
      onCallAccepted: handleAnswerCall,
      onCallEnded: _handleEndCallEvent,
      onCallDeclined: _handleDeclineCall,
    );
  }

  // Make a call
  Future<void> makeCall({
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required String receiverFcmToken,
    required String callType,
  }) async {
    log('Starting makeCall process');
    final callerFcmToken = await getFCMToken();
    if (callerFcmToken == null) {
      log('Failed to get FCM token for caller');
      return;
    }
    log('Got caller FCM token: $callerFcmToken');

    try {
      final call = await _callRepository.createCall(
        callerId: callerId,
        callerName: callerName,
        callerFcmToken: callerFcmToken,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverFcmToken: receiverFcmToken,
        callType: callType,
      );
      log('Call created successfully: ${call.toMap()}');

      _currentCall = call;

      // Start an outgoing call with CallKeep
      final callEvent = CallEvent(
        uuid: call.callId,
        callerName: callerName,
        handle: call.receiverId,
        hasVideo: callType == 'video',
        extra: <String, dynamic>{
          'callerId': callerId,
          'receiverId': receiverId,
          'callType': callType,
        },
      );

      log('Starting CallKeep call with event: ${callEvent.uuid}');
      await CallKeep.instance.startCall(callEvent);
      log('CallKeep call started successfully');

      // Send notification to receiver
      log('Sending call notification to receiver');
      await _notificationService.sendCallNotification(
        recipientToken: receiverFcmToken,
        callerName: callerName,
        callerId: callerId,
        callType: callType,
        callId: call.callId,
      );
      log('Call notification sent successfully');

      // Listen to call updates
      _listenToCallUpdates(call.callId);
      log('Call update listener started');
    } catch (e) {
      log('Error in makeCall: $e');
    }
  }

  // Listen to call updates
  void _listenToCallUpdates(String callId) {
    _callRepository.getCallStream(callId).listen((call) {
      if (call == null) return;

      _currentCall = call;
      switch (call.status) {
        case 'rejected':
          _handleCallRejected(call);
          break;
        case 'ended':
          _handleCallEnded(call);
          break;
        case 'ongoing':
          // Handle call accepted
          break;
      }
    });
  }

  // Handle when a call is rejected
  void _handleCallRejected(Call call) async {
    await _notificationService.sendCallRejectedNotification(
      recipientToken: call.callerFcmToken,
      callId: call.callId,
    );
    _currentCall = null;
  }

  // Handle when a call is ended
  void _handleCallEnded(Call call) async {
    await _notificationService.sendCallEndedNotification(
      recipientToken: call.receiverFcmToken,
      callId: call.callId,
    );
    _currentCall = null;
    Navigator.of(navigatorKey.currentContext!)
        .popUntil((route) => route.isFirst);
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    if (message.data['type'] == 'call') {
      final String callId = message.data['callId'];
      final bool hasVideo = message.data['callType'] == 'video';

      // Save call data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_call_data', json.encode(message.data));

      final callEvent = CallEvent(
        uuid: callId,
        callerName: message.data['callerName'] ?? 'Unknown',
        handle: message.data['callerName'] ?? 'Unknown',
        hasVideo: hasVideo,
        extra: <String, dynamic>{
          'callerId': message.data['callerId'],
          'callType': message.data['callType'],
        },
      );

      await CallKeep.instance.displayIncomingCall(callEvent);
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Received foreground message: ${message.data}');
    if (message.data['type'] == 'call') {
      final String callId = message.data['callId'];
      final bool hasVideo = message.data['callType'] == 'video';
      log('Processing call notification - ID: $callId, Type: ${message.data['callType']}');

      try {
        // Get call details from repository
        final call = await _callRepository.getCallStream(callId).first;
        if (call == null) {
          log('Call not found in database for ID: $callId');
          return;
        }
        log('Call details fetched successfully: ${call.toMap()}');

        _currentCall = call;
        await _saveCallData(call);

        // Navigate to our custom incoming call screen
        if (navigatorKey.currentContext != null) {
          log('Navigating to incoming call screen');
          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => Provider<CallService>.value(
                value: this,
                child: IncomingCallScreen(
                  call: call,
                ),
              ),
            ),
          );
          log('Navigation completed');
        } else {
          log('No navigator context available');
        }

        // Start listening to call updates
        _listenToCallUpdates(callId);
        log('Call update listener started');
      } catch (e) {
        log('Error in _handleForegroundMessage: $e');
      }
    }
  }

  // Check for active calls and navigate to call screen if needed
  Future<void> checkAndNavigateToCallScreen() async {
    final CallMinutesService callMinutesService = CallMinutesService();
    log('Checking for active calls');
    try {
      // Get active calls from CallKeep

      final prefs = await SharedPreferences.getInstance();
      final savedCallData = prefs.getString(_activeCallKey);

      if (savedCallData != null) {
        final callData = jsonDecode(savedCallData);
        final String callId = callData['callId'];
        final bool hasVideo = callData['callType'] == 'video';
        final callEvent = CallEvent(
          uuid: callId,
          callerName: callData['callerName'] ?? 'Unknown',
          handle: callData['callerName'] ?? 'Unknown',
          hasVideo: hasVideo,
          extra: <String, dynamic>{
            'callerId': callData['callerId'],
            'callType': callData['callType'],
          },
        );
        log('Found active call: ${callEvent.toMap()}');
        prefs.clear();

        final call = await _callRepository.getCallStream(callId).first;

        if (call != null) {
          log('Call details found: ${call.toMap()}');
          _currentCall = call;

          // Navigate to appropriate call screen
          if (navigatorKey.currentContext != null) {
            log('Navigating to ${call.callType} call screen');
            if (call.callType == 'video') {
              Navigator.pushReplacement(
                navigatorKey.currentContext!,
                MaterialPageRoute(
                  builder: (context) => Provider<CallService>.value(
                    value: this,
                    child: VideoCallScreen(
                      call: call,
                      onCallEnd: (duration) async {
                        // Record the actual minutes used when call ends
                        final minutesUsed = (duration.inSeconds / 60).ceil();
                        await callMinutesService.recordUsedMinutes(
                          call.receiverId,
                          call.callType,
                          minutesUsed,
                        );
                        endCall(callId);
                      },
                    ),
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) => Provider<CallService>.value(
                      value: this,
                      child: AudioCallScreen(
                        call: call,
                        onCallEnd: (duration) async {
                          // Record the actual minutes used when call ends
                          final minutesUsed = (duration.inSeconds / 60).ceil();
                          await callMinutesService.recordUsedMinutes(
                            call.receiverId,
                            call.callType,
                            minutesUsed,
                          );
                          endCall(callId);
                        },
                      ),
                    ),
                  ));
            }
            log('Navigation completed');
          } else {
            log('No navigator context available');
          }
        } else {
          log('Call not found in database for ID: $callId');
        }
      } else {
        log('No active calls found');
      }
    } catch (e) {
      log('Error checking active calls: $e');
    }
  }

  // Update handleAnswerCall to use the new navigation logic
  void handleAnswerCall(CallEvent event) async {
    log('handleAnswerCall started with event: ${event.uuid}');

    if (_currentCall == null) {
      log('No current call found, fetching call details for ID: ${event.uuid}');
      final callId = event.uuid;
      try {
        final call = await _callRepository.getCallStream(callId).first;

        if (call == null) {
          log('Call not found in database for ID: $callId');
          return;
        }
        // Save call data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('active_call_data', json.encode(call.toMap()));
        log('Call details fetched successfully: ${call.toMap()}');
        _currentCall = call;
        checkAndNavigateToCallScreen();
      } catch (e) {
        log('Error fetching call: $e');
        return;
      }
    } else {
      log('Using existing current call: ${_currentCall!.toMap()}');
    }

    try {
      log('Updating call status to ongoing for call ID: ${_currentCall!.callId}');
      await _callRepository.updateCallStatus(_currentCall!.callId, 'ongoing');
      log('Call status updated successfully');

      // Use the same navigation logic as checkAndNavigateToCallScreen
      await checkAndNavigateToCallScreen();
    } catch (e) {
      log('Error in handleAnswerCall: $e');
    }
  }

  void _handleEndCallEvent(CallEvent event) async {
    await endCall(event.uuid);
  }

  void _handleDeclineCall(CallEvent event) async {
    await rejectCall(event.uuid);
  }

  Future<void> endCall(String callId) async {
    // End the call in CallKeep
    await CallKeep.instance.endCall(callId);
    await CallKeep.instance.endAllCalls();

    // Update call in repository
    await _callRepository.endCall(callId);

    if (_currentCall?.callId == callId) {
      _currentCall = null;
    }

    // Remove saved call data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeCallKey);

    // Return to home screen
    if (navigatorKey.currentContext != null) {
      Navigator.of(navigatorKey.currentContext!)
          .popUntil((route) => route.isFirst);
    }
  }

  Future<void> endCurrentCall() async {
    if (_currentCall == null) return;
    await endCall(_currentCall!.callId);
  }

  Future<void> rejectCall(String callId) async {
    // Reject the call in CallKeep
    await CallKeep.instance
        .endCall(callId); // Using endCall as rejectCall isn't available

    // Update call in repository
    await _callRepository.rejectCall(callId);

    if (_currentCall?.callId == callId) {
      _currentCall = null;
    }
  }

  Future<void> rejectCurrentCall() async {
    if (_currentCall == null) return;
    await rejectCall(_currentCall!.callId);
  }

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  Call? get currentCall => _currentCall;
}
