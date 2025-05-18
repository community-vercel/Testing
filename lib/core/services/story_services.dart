import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_structure/core/constants/collection_identifiers.dart';
import 'package:code_structure/core/model/story.dart';

class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Story>> getStories() {
    // Get stories that haven't expired yet
    return _firestore
        .collection(StoriesCollection)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('expiresAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Story.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  Future<List<Story>> getStoriesForUser(String userId) async {
    final snapshot = await _firestore
        .collection(StoriesCollection)
        .where('userId', isEqualTo: userId)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('expiresAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Story.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> createStory({
    required String userId,
    required String mediaUrl,
    required StoryType type,
    String? caption,
  }) async {
    final now = DateTime.now();
    final story = Story(
      id: '', // Will be set by Firestore
      userId: userId,
      mediaUrl: mediaUrl,
      type: type,
      createdAt: now,
      expiresAt: now.add(Duration(hours: 24)), // Stories expire after 24 hours
      caption: caption,
    );

    await _firestore.collection(StoriesCollection).add(story.toJson());
  }

  Future<void> viewStory(String storyId, String userId) async {
    await _firestore.collection(StoriesCollection).doc(storyId).update({
      'viewedBy': FieldValue.arrayUnion([userId]),
      'viewCount': FieldValue.increment(1),
    });
  }

  Future<void> addComment(String storyId) async {
    await _firestore.collection(StoriesCollection).doc(storyId).update({
      'commentCount': FieldValue.increment(1),
    });
  }
}
