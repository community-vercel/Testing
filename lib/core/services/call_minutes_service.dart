import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_structure/core/constants/collection_identifiers.dart';
import 'package:uuid/uuid.dart';
import 'package:code_structure/core/model/call_minutes.dart';
import 'package:code_structure/core/model/transaction.dart' as app_transaction;

class CallMinutesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get call minutes for a user
  Future<CallMinutes> getCallMinutes(String userId) async {
    try {
      final userDoc =
          await _firestore.collection(AppUserCollection).doc(userId).get();

      if (!userDoc.exists || !userDoc.data()!.containsKey('callMinutes')) {
        // Create default call minutes if not exists
        final defaultMinutes = CallMinutes();
        await _firestore.collection(AppUserCollection).doc(userId).update({
          'callMinutes': defaultMinutes.toMap(),
        });
        return defaultMinutes;
      }

      return CallMinutes.fromMap(userDoc.data()!['callMinutes']);
    } catch (e) {
      print('Error getting call minutes: $e');
      return CallMinutes(); // Return default if error
    }
  }

  // Update call minutes for a user
  Future<void> updateCallMinutes(String userId, CallMinutes callMinutes) async {
    try {
      await _firestore.collection(AppUserCollection).doc(userId).update({
        'callMinutes': callMinutes.toMap(),
      });
    } catch (e) {
      print('Error updating call minutes: $e');
      throw Exception('Failed to update call minutes');
    }
  }

  // Add minutes after purchase
  Future<void> addPurchasedMinutes(
      String userId, int audioMinutes, int videoMinutes) async {
    try {
      final currentMinutes = await getCallMinutes(userId);

      final updatedMinutes = currentMinutes.copyWith(
        audioPurchased: currentMinutes.audioPurchased + audioMinutes,
        videoPurchased: currentMinutes.videoPurchased + videoMinutes,
      );

      await updateCallMinutes(userId, updatedMinutes);
    } catch (e) {
      print('Error adding purchased minutes: $e');
      throw Exception('Failed to add purchased minutes');
    }
  }

  // Check if user has enough minutes for a call
  Future<bool> hasEnoughMinutes(
      String userId, String callType, int minutes) async {
    try {
      final callMinutes = await getCallMinutes(userId);

      if (callType == 'audio') {
        return callMinutes.audioAvailable >= minutes;
      } else if (callType == 'video') {
        return callMinutes.videoAvailable >= minutes;
      }

      return false;
    } catch (e) {
      print('Error checking minutes: $e');
      return false;
    }
  }

  // Record used minutes after a call
  Future<void> recordUsedMinutes(
      String userId, String callType, int minutes) async {
    try {
      final currentMinutes = await getCallMinutes(userId);

      if (callType == 'audio') {
        final updatedMinutes = currentMinutes.copyWith(
          audioUsed: currentMinutes.audioUsed + minutes,
        );
        await updateCallMinutes(userId, updatedMinutes);
      } else if (callType == 'video') {
        final updatedMinutes = currentMinutes.copyWith(
          videoUsed: currentMinutes.videoUsed + minutes,
        );
        await updateCallMinutes(userId, updatedMinutes);
      }
    } catch (e) {
      print('Error recording used minutes: $e');
      throw Exception('Failed to record used minutes');
    }
  }

  // Create transaction record
  Future<void> createTransaction({
    required String userId,
    required double amount,
    required String status,
    required String paymentMethod,
    required String paymentIntentId,
    required Map<String, dynamic> items,
  }) async {
    try {
      final id = const Uuid().v4();
      final transaction = app_transaction.Transaction(
        id: id,
        userId: userId,
        amount: amount,
        timestamp: DateTime.now(),
        status: status,
        paymentMethod: paymentMethod,
        paymentIntentId: paymentIntentId,
        items: items,
      );

      await _firestore
          .collection(TransactionsCollection)
          .doc(id)
          .set(transaction.toMap());
    } catch (e) {
      print('Error creating transaction: $e');
      throw Exception('Failed to create transaction record');
    }
  }

  // Get transaction history for a user
  Stream<List<app_transaction.Transaction>> getUserTransactions(String userId) {
    return _firestore
        .collection(TransactionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return app_transaction.Transaction.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}