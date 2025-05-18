// ignore_for_file: unused_field

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../models/call.dart';
import '../repositories/call_repository.dart';
import '../services/call_service.dart';
import '../services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:code_structure/core/providers/call_minutes_provider.dart';

class CallProvider extends ChangeNotifier {
  final CallRepository _callRepository = CallRepository();
  final NotificationService _notificationService = NotificationService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final CallService _callService;
  Call? _currentCall;
  Stream<Call?>? _callStream;
  DateTime? _callStartTime;

  CallProvider(
    this._callService,
  );

  Call? get currentCall => _currentCall;
  Stream<Call?>? get callStream => _callStream;

  // Start a new call
  Future<void> startCall({
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required String receiverFcmToken,
    required String callType,
    BuildContext? context,
  }) async {
    final callerFcmToken = await _firebaseMessaging.getToken();
    if (callerFcmToken == null) return;

    // Record call start time
    _callStartTime = DateTime.now();

    final call = await _callRepository.createCall(
      callerId: callerId,
      callerName: callerName,
      callerFcmToken: callerFcmToken,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverFcmToken: receiverFcmToken,
      callType: callType,
    );

    _currentCall = call;
    _listenToCallUpdates(call.callId);
    notifyListeners();

    // Send notification to receiver
    await _notificationService.sendCallNotification(
      recipientToken: receiverFcmToken,
      callerName: callerName,
      callerId: callerId,
      callType: callType,
      callId: call.callId,
    );
  }

  // Listen to call updates
  void _listenToCallUpdates(String callId) {
    _callStream = _callRepository.getCallStream(callId);
    _callStream?.listen((call) {
      _currentCall = call;
      notifyListeners();
    });
  }

  // Listen to active calls for a user
  void listenToActiveCalls(String userId) {
    _callStream = _callRepository.getActiveCallStream(userId);
    _callStream?.listen((call) {
      _currentCall = call;
      notifyListeners();
    });
  }

  // End current call and record used minutes
  Future<void> endCurrentCall({BuildContext? context}) async {
    if (_currentCall == null) return;

    // Calculate call duration in minutes
    if (_callStartTime != null && context != null) {
      final endTime = DateTime.now();
      final durationInMinutes = endTime.difference(_callStartTime!).inMinutes;

      // Only record minutes if call lasted at least 1 minute
      if (durationInMinutes > 0) {
        final callMinutesProvider =
            Provider.of<CallMinutesProvider>(context, listen: false);
        final callType = _currentCall!.callType; // 'audio' or 'video'

        // Record the actual used minutes
        await callMinutesProvider.recordUsedMinutes(
            callType, durationInMinutes);
      }
    }

    await _callRepository.endCall(_currentCall!.callId);
    _currentCall = null;
    _callStartTime = null;
    notifyListeners();
  }

  // Reject current call
  Future<void> rejectCurrentCall() async {
    if (_currentCall == null) return;
    await _callRepository.rejectCall(_currentCall!.callId);
    _currentCall = null;
    _callStartTime = null;
    notifyListeners();
  }

  // Accept current call
  Future<void> acceptCurrentCall() async {
    if (_currentCall == null) return;

    // Record call start time when the call is accepted
    _callStartTime = DateTime.now();

    await _callRepository.updateCallStatus(_currentCall!.callId, 'ongoing');
    notifyListeners();
  }
}
