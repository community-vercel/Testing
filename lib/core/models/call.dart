class Call {
  final String callId;
  final String callerId;
  final String callerName;
  final String callerFcmToken;
  final String receiverId;
  final String receiverName;
  final String receiverFcmToken;
  final String channelName;
  final String token;
  final String callType; // 'audio' or 'video'
  final String status; // 'pending', 'ongoing', 'ended', 'rejected'
  final DateTime createdAt;
  final DateTime? endedAt;
  final List<String> participants;

  Call({
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.callerFcmToken,
    required this.receiverId,
    required this.receiverName,
    required this.receiverFcmToken,
    required this.channelName,
    required this.token,
    required this.callType,
    required this.status,
    required this.createdAt,
    this.endedAt,
    required this.participants,
  });

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'callerName': callerName,
      'callerFcmToken': callerFcmToken,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverFcmToken': receiverFcmToken,
      'channelName': channelName,
      'token': token,
      'callType': callType,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'participants': participants,
    };
  }

  factory Call.fromMap(Map<String, dynamic> map) {
    return Call(
      callId: map['callId'],
      callerId: map['callerId'],
      callerName: map['callerName'],
      callerFcmToken: map['callerFcmToken'],
      receiverId: map['receiverId'],
      receiverName: map['receiverName'],
      receiverFcmToken: map['receiverFcmToken'],
      channelName: map['channelName'],
      token: map['token'],
      callType: map['callType'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      endedAt: map['endedAt'] != null ? DateTime.parse(map['endedAt']) : null,
      participants: List<String>.from(map['participants'] ?? []),
    );
  }
}
