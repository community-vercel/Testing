import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_structure/core/constants/collection_identifiers.dart';
import 'package:uuid/uuid.dart';
import '../models/call.dart';
import '../services/agora_service.dart';

class CallRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AgoraService _agoraService = AgoraService();

  // Create a new call
  Future<Call> createCall({
    required String callerId,
    required String callerName,
    required String callerFcmToken,
    required String receiverId,
    required String receiverName,
    required String receiverFcmToken,
    required String callType,
  }) async {
    final String callId = const Uuid().v4();

    // Generate a shorter, Agora-friendly channel name
    // Using only the first 8 characters of each ID to keep it under 64 bytes
    final String channelName =
        '${callerId.substring(0, 8)}${receiverId.substring(0, 8)}${callId.substring(0, 8)}';

    final String token = await _agoraService.generateToken(channelName);

    final Call call = Call(
      callId: callId,
      callerId: callerId,
      callerName: callerName,
      callerFcmToken: callerFcmToken,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverFcmToken: receiverFcmToken,
      channelName: channelName,
      token: token,
      callType: callType,
      status: 'pending',
      createdAt: DateTime.now(),
      participants: [callerId, receiverId],
    );

    await _firestore.collection(CallsCollection).doc(callId).set(call.toMap());
    return call;
  }

  // Get call stream
  Stream<Call?> getCallStream(String callId) {
    return _firestore.collection(CallsCollection).doc(callId).snapshots().map(
        (snapshot) => snapshot.exists ? Call.fromMap(snapshot.data()!) : null);
  }

  // Get active call stream for a user
  Stream<Call?> getActiveCallStream(String userId) {
    return _firestore
        .collection(CallsCollection)
        .where('status', whereIn: ['pending', 'ongoing'])
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty
            ? Call.fromMap(snapshot.docs.first.data())
            : null);
  }

  // Update call status
  Future<void> updateCallStatus(String callId, String status) async {
    await _firestore.collection(CallsCollection).doc(callId).update({
      'status': status,
      if (status == 'ended') 'endedAt': DateTime.now().toIso8601String(),
    });
  }

  // End call
  Future<void> endCall(String callId) async {
    await updateCallStatus(callId, 'ended');
  }

  // Reject call
  Future<void> rejectCall(String callId) async {
    await updateCallStatus(callId, 'rejected');
  }

  // Get call history for a user
  Stream<List<Call>> getCallHistory(String userId) {
    return _firestore
        .collection(CallsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Call.fromMap(doc.data())).toList());
  }

  // Get call duration
  Duration getCallDuration(Call call) {
    if (call.endedAt == null || call.status != 'ended') {
      return Duration.zero;
    }
    return call.endedAt!.difference(call.createdAt);
  }
}
