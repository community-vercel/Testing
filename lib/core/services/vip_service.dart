// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:code_structure/core/constants/collection_identifiers.dart';
// import 'package:code_structure/core/model/app_user.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class VipService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Check if user is VIP
//   Future<bool> isVip() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return false;

//       final userDoc =
//           await _firestore.collection(AppUserCollection).doc(userId).get();
//       final userData = userDoc.data();

//       if (userData == null) return false;

//       final vipEndDate = (userData['vipEndDate'] as Timestamp).toDate();
//       final isVip = userData['isVip'] ?? false;

//       return isVip && DateTime.now().isBefore(vipEndDate);
//     } catch (e) {
//       print('Error checking VIP status: $e');
//       return false;
//     }
//   }

//   // Get VIP status details
//   Future<Map<String, dynamic>> getVipStatus() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) {
//         throw Exception('User not authenticated');
//       }

//       final userDoc =
//           await _firestore.collection(AppUserCollection).doc(userId).get();
//       final userData = userDoc.data();

//       if (userData == null) {
//         throw Exception('User data not found');
//       }

//       return {
//         'isVip': userData['isVip'] ?? false,
//         'vipStartDate': userData['vipStartDate'] != null
//             ? (userData['vipStartDate'] as Timestamp).toDate()
//             : null,
//         'vipEndDate': userData['vipEndDate'] != null
//             ? (userData['vipEndDate'] as Timestamp).toDate()
//             : null,
//         'subscriptionStatus': userData['subscriptionStatus'] ?? 'none',
//       };
//     } catch (e) {
//       print('Error getting VIP status: $e');
//       throw Exception('Failed to get VIP status');
//     }
//   }

//   // Check if a specific feature is available
//   Future<bool> isFeatureAvailable(String feature) async {
//     final isVipUser = await isVip();

//     // Define feature availability based on VIP status
//     switch (feature) {
//       case 'see_likes':
//       case 'see_visits':
//       case 'unlimited_rewinds':
//       case 'incognito_mode':
//       case 'extra_superlikes':
//       case 'spotlight':
//         return isVipUser;
//       default:
//         return true; // Non-VIP features are always available
//     }
//   }

//   // Get remaining trial days
//   Future<int?> getRemainingTrialDays() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return null;

//       final userDoc =
//           await _firestore.collection(AppUserCollection).doc(userId).get();
//       final userData = userDoc.data();

//       if (userData == null || userData['vipEndDate'] == null) return null;

//       final vipEndDate = (userData['vipEndDate'] as Timestamp).toDate();
//       final now = DateTime.now();

//       if (!now.isBefore(vipEndDate)) return 0;

//       return vipEndDate.difference(now).inDays;
//     } catch (e) {
//       print('Error getting remaining trial days: $e');
//       return null;
//     }
//   }

//   // Superlike related methods
//   Future<bool> canSuperlike() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return false;

//       final userDoc =
//           await _firestore.collection(AppUserCollection).doc(userId).get();
//       final userData = userDoc.data();

//       if (userData == null) return false;

//       final isVipUser = await isVip();
//       if (isVipUser) return true;

//       // For non-VIP users, check daily limit
//       final lastSuperlikeDate = userData['lastSuperlikeDate'] != null
//           ? (userData['lastSuperlikeDate'] as Timestamp).toDate()
//           : null;
//       final superlikeCount = userData['superlikeCount'] ?? 0;

//       final now = DateTime.now();
//       if (lastSuperlikeDate == null ||
//           !now.isAtSameMomentAs(lastSuperlikeDate)) {
//         // Reset count for new day
//         await _firestore.collection(AppUserCollection).doc(userId).update({
//           'superlikeCount': 0,
//           'lastSuperlikeDate': now,
//         });
//         return true;
//       }

//       return superlikeCount < 1; // Non-VIP users get 1 superlike per day
//     } catch (e) {
//       print('Error checking superlike availability: $e');
//       return false;
//     }
//   }

//   Future<void> incrementSuperlikeCount() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return;

//       final userDoc =
//           await _firestore.collection(AppUserCollection).doc(userId).get();
//       final userData = userDoc.data();

//       if (userData == null) return;

//       final isVipUser = await isVip();
//       if (isVipUser) return; // VIP users don't need to track count

//       final now = DateTime.now();
//       final lastSuperlikeDate = userData['lastSuperlikeDate'] != null
//           ? (userData['lastSuperlikeDate'] as Timestamp).toDate()
//           : null;

//       if (lastSuperlikeDate == null ||
//           !now.isAtSameMomentAs(lastSuperlikeDate)) {
//         // Reset count for new day
//         await _firestore.collection(AppUserCollection).doc(userId).update({
//           'superlikeCount': 1,
//           'lastSuperlikeDate': now,
//         });
//       } else {
//         // Increment count
//         await _firestore.collection(AppUserCollection).doc(userId).update({
//           'superlikeCount': FieldValue.increment(1),
//         });
//       }
//     } catch (e) {
//       print('Error incrementing superlike count: $e');
//     }
//   }

//   // Incognito mode methods
//   Future<bool> isIncognitoModeEnabled() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return false;

//       final userDoc =
//           await _firestore.collection(AppUserCollection).doc(userId).get();
//       final userData = userDoc.data();

//       if (userData == null) return false;

//       return userData['incognitoMode'] ?? false;
//     } catch (e) {
//       print('Error checking incognito mode: $e');
//       return false;
//     }
//   }

//   Future<void> toggleIncognitoMode(bool enabled) async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return;

//       await _firestore.collection(AppUserCollection).doc(userId).update({
//         'incognitoMode': enabled,
//       });
//     } catch (e) {
//       print('Error toggling incognito mode: $e');
//     }
//   }

//   // Rewind related methods
//   Future<bool> canRewind() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return false;

//       final userDoc =
//           await _firestore.collection(AppUserCollection).doc(userId).get();
//       final userData = userDoc.data();

//       if (userData == null) return false;

//       final isVipUser = await isVip();
//       if (isVipUser) return true;

//       // For non-VIP users, check daily limit
//       final lastRewindDate = userData['lastRewindDate'] != null
//           ? (userData['lastRewindDate'] as Timestamp).toDate()
//           : null;
//       final rewindCount = userData['rewindCount'] ?? 0;

//       final now = DateTime.now();
//       if (lastRewindDate == null || !now.isAtSameMomentAs(lastRewindDate)) {
//         // Reset count for new day
//         await _firestore.collection(AppUserCollection).doc(userId).update({
//           'rewindCount': 0,
//           'lastRewindDate': now,
//         });
//         return true;
//       }

//       return rewindCount < 3; // Non-VIP users get 3 rewinds per day
//     } catch (e) {
//       print('Error checking rewind availability: $e');
//       return false;
//     }
//   }

//   Future<void> incrementRewindCount() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return;

//       final userDoc =
//           await _firestore.collection(AppUserCollection).doc(userId).get();
//       final userData = userDoc.data();

//       if (userData == null) return;

//       final isVipUser = await isVip();
//       if (isVipUser) return; // VIP users don't need to track count

//       final now = DateTime.now();
//       final lastRewindDate = userData['lastRewindDate'] != null
//           ? (userData['lastRewindDate'] as Timestamp).toDate()
//           : null;

//       if (lastRewindDate == null || !now.isAtSameMomentAs(lastRewindDate)) {
//         // Reset count for new day
//         await _firestore.collection(AppUserCollection).doc(userId).update({
//           'rewindCount': 1,
//           'lastRewindDate': now,
//         });
//       } else {
//         // Increment count
//         await _firestore.collection(AppUserCollection).doc(userId).update({
//           'rewindCount': FieldValue.increment(1),
//         });
//       }
//     } catch (e) {
//       print('Error incrementing rewind count: $e');
//     }
//   }

//   // Spotlight related methods
//   Future<bool> isInSpotlight() async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return false;

//       final userDoc =
//           await _firestore.collection(AppUserCollection).doc(userId).get();
//       final userData = userDoc.data();

//       if (userData == null) return false;

//       return userData['inSpotlight'] ?? false;
//     } catch (e) {
//       print('Error checking spotlight status: $e');
//       return false;
//     }
//   }

//   Future<void> toggleSpotlight(bool enabled) async {
//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) return;

//       await _firestore.collection(AppUserCollection).doc(userId).update({
//         'inSpotlight': enabled,
//       });
//     } catch (e) {
//       print('Error toggling spotlight: $e');
//     }
//   }
// }
