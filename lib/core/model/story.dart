import 'package:cloud_firestore/cloud_firestore.dart';

enum StoryType { image, video, text }

class Story {
  final String id;
  final String userId;
  final String mediaUrl;
  final StoryType type;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewedBy;
  final int commentCount;
  final String? caption;

  Story({
    required this.id,
    required this.userId,
    required this.mediaUrl,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
    this.commentCount = 0,
    this.caption,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mediaUrl': mediaUrl,
      'type': type.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'viewedBy': viewedBy,
      'commentCount': commentCount,
      'caption': caption,
    };
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      userId: json['userId'],
      mediaUrl: json['mediaUrl'],
      type: StoryType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => StoryType.image,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      expiresAt: (json['expiresAt'] as Timestamp).toDate(),
      viewedBy: List<String>.from(json['viewedBy'] ?? []),
      commentCount: json['commentCount'] ?? 0,
      caption: json['caption'],
    );
  }
}
