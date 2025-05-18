import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
}

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final String? fileName;
  final String? fileSize;
  final String? filePath;
  final int? audioDuration;
  final List<String> readBy;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.timestamp,
    this.fileName,
    this.fileSize,
    this.filePath,
    this.audioDuration,
    this.readBy = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.toString(),
      'timestamp': timestamp,
      'fileName': fileName,
      'fileSize': fileSize,
      'filePath': filePath,
      'audioDuration': audioDuration,
      'readBy': readBy,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'] ?? 'Unknown user',
      content: json['content'],
      type: MessageType.values.firstWhere((e) => e.toString() == json['type'],
          orElse: () => MessageType.text),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      filePath: json['filePath'],
      audioDuration: json['audioDuration'],
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }
}
