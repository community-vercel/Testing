// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:code_structure/core/constants/collection_identifiers.dart';
// import 'package:code_structure/core/model/app_user.dart';
// import 'package:code_structure/core/services/stripe_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class SubscriptionService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<void> startFreeTrial(String userId) async {
//     try {
//       final now = DateTime.now();
//       final trialEndDate = now.add(const Duration(days: 7));

//       await _firestore.collection(AppUserCollection).doc(userId).update({
//         'isVip': true,
//         'vipStartDate': now,
//         'vipEndDate': trialEndDate,
//         'subscriptionStatus': 'trial',
//       });
//     } catch (e) {
//       print('Error starting free trial: $e');
//       rethrow;
//     }
//   }

//   Future<void> subscribeToVip(String userId, String paymentMethodId) async {
//     try {
//       // Create subscription using Stripe
//       final subscription = await StripeService.createSubscription(
//         userId,
//         paymentMethodId,
//         amount: 39.99,
//         interval: '2 months',
//       );

//       final now = DateTime.now();
//       final nextBillingDate = now.add(const Duration(days: 60)); // 2 months

//       await _firestore.collection(AppUserCollection).doc(userId).update({
//         'isVip': true,
//         'vipStartDate': now,
//         'vipEndDate': nextBillingDate,
//         'subscriptionId': subscription['id'],
//         'subscriptionStatus': 'active',
//       });
//     } catch (e) {
//       print('Error subscribing to VIP: $e');
//       rethrow;
//     }
//   }

//   Future<void> cancelSubscription(String userId) async {
//     try {
//       final userDoc =
//           await _firestore.collection(AppUserCollection).doc(userId).get();
//       final userData = userDoc.data();

//       if (userData != null && userData['subscriptionId'] != null) {
//         // Cancel subscription in Stripe
//         await StripeService.cancelSubscription(userData['subscriptionId']);

//         // Update user's subscription status
//         await _firestore.collection(AppUserCollection).doc(userId).update({
//           'subscriptionStatus': 'cancelled',
//           'vipEndDate': DateTime.now(),
//         });
//       }
//     } catch (e) {
//       print('Error cancelling subscription: $e');
//       rethrow;
//     }
//   }

//   Future<bool> isVipActive(String userId) async {
//     try {
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
// }
