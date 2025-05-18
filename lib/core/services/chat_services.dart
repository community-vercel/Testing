// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_structure/core/constants/collection_identifiers.dart';
import 'package:code_structure/core/model/chat.dart';
import 'package:code_structure/core/model/message.dart';
import 'package:uuid/uuid.dart';
import 'package:code_structure/core/model/app_user.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  // Create a new chat or get existing one
  Future<String> createOrGetChat(List<String> participants,
      {bool isGroup = false, String? groupName, String? groupImage}) async {
    try {
      if (!isGroup) {
        // For personal chat, check if chat already exists
        final QuerySnapshot existingChats = await _firestore
            .collection(ChatCollection)
            .where('participants', arrayContainsAny: participants)
            .where('isGroup', isEqualTo: false)
            .get();

        for (var doc in existingChats.docs) {
          final chat = Chat.fromJson(doc.data() as Map<String, dynamic>);
          if (chat.participants.length == 2 &&
              chat.participants.contains(participants[0]) &&
              chat.participants.contains(participants[1])) {
            return doc.id;
          }
        }
      }

      // Create new chat
      final String chatId = uuid.v4();
      final Map<String, int> initialUnreadCounts = {};
      for (String participant in participants) {
        initialUnreadCounts[participant] = 0;
      }

      final Chat chat = Chat(
        id: chatId,
        participants: participants,
        groupName: groupName,
        groupImage: groupImage,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: participants[0],
        isGroup: isGroup,
        lastMessageType: MessageType.text,
        unreadCounts: initialUnreadCounts,
      );

      await _firestore
          .collection(ChatCollection)
          .doc(chatId)
          .set(chat.toJson());
      return chatId;
    } catch (e) {
      print('Error creating/getting chat: $e');
      throw Exception('Failed to create/get chat');
    }
  }

  // Send a message
  Future<void> sendMessage(Message message, String chatId) async {
    try {
      // Get the chat document to update unread counts
      final chatDoc =
          await _firestore.collection(ChatCollection).doc(chatId).get();
      final chat = Chat.fromJson(chatDoc.data()!);

      // Increment unread count for all participants except the sender
      final Map<String, int> newUnreadCounts = Map.from(chat.unreadCounts);
      for (String participantId in chat.participants) {
        if (participantId != message.senderId) {
          newUnreadCounts[participantId] =
              (newUnreadCounts[participantId] ?? 0) + 1;
        }
      }

      // Send the message
      await _firestore
          .collection(ChatCollection)
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());

      // Update last message and unread counts in chat
      final chatUpdate = {
        'lastMessage': message.content,
        'lastMessageType': message.type.toString(),
        'lastMessageTime': message.timestamp,
        'lastMessageSenderId': message.senderId,
        'unreadCounts': newUnreadCounts,
      };

      await _firestore
          .collection(ChatCollection)
          .doc(chatId)
          .update(chatUpdate);
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message');
    }
  }

  // Get chat messages stream
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection(ChatCollection)
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get user chats stream
  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection(ChatCollection)
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Chat.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Delete message
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection(ChatCollection)
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Error deleting message: $e');
      throw Exception('Failed to delete message');
    }
  }

  // Add new methods for group chat functionality
  Future<void> updateGroupInfo(String chatId,
      {String? groupName, String? groupImage}) async {
    try {
      final Map<String, dynamic> updates = {};
      if (groupName != null) updates['groupName'] = groupName;
      if (groupImage != null) updates['groupImage'] = groupImage;

      await _firestore.collection(ChatCollection).doc(chatId).update(updates);
    } catch (e) {
      print('Error updating group info: $e');
      throw Exception('Failed to update group info');
    }
  }

  Future<void> addGroupParticipants(
      String chatId, List<String> newParticipants) async {
    try {
      await _firestore.collection(ChatCollection).doc(chatId).update({
        'participants': FieldValue.arrayUnion(newParticipants),
      });
    } catch (e) {
      print('Error adding participants: $e');
      throw Exception('Failed to add participants');
    }
  }

  Future<void> removeGroupParticipant(
      String chatId, String participantId) async {
    try {
      await _firestore.collection(ChatCollection).doc(chatId).update({
        'participants': FieldValue.arrayRemove([participantId]),
      });
    } catch (e) {
      print('Error removing participant: $e');
      throw Exception('Failed to remove participant');
    }
  }

  // Get group participants with their user info
  Stream<List<AppUser>> getGroupParticipants(String chatId) {
    return _firestore
        .collection(ChatCollection)
        .doc(chatId)
        .snapshots()
        .asyncMap((chatDoc) async {
      if (!chatDoc.exists) return [];

      final chat = Chat.fromJson(chatDoc.data()! as Map<String, dynamic>);
      final List<AppUser> participants = [];

      for (String userId in chat.participants) {
        final userDoc =
            await _firestore.collection('AppUsers').doc(userId).get();
        if (userDoc.exists) {
          participants.add(AppUser.fromJson(userDoc.data()!));
        }
      }

      return participants;
    });
  }

  // Mark messages as read for a specific user
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      // Get all unread messages for this user in this chat
      final messagesSnapshot = await _firestore
          .collection(ChatCollection)
          .doc(chatId)
          .collection('messages')
          .where('readBy', isNotEqualTo: [userId]).get();

      // Update each message to mark it as read by this user
      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        final messageRef = _firestore
            .collection(ChatCollection)
            .doc(chatId)
            .collection('messages')
            .doc(doc.id);

        batch.update(messageRef, {
          'readBy': FieldValue.arrayUnion([userId])
        });
      }

      // Update the chat's unread count for this user
      final chatRef = _firestore.collection(ChatCollection).doc(chatId);
      batch.update(chatRef, {'unreadCounts.$userId': 0});

      // Commit all updates
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
      throw Exception('Failed to mark messages as read');
    }
  }
}
