import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:code_structure/core/services/call_minutes_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StripeService {
  // Your Stripe keys
  static const String _publishableKey = 'pk_test_51AfCnUJe629jCerG7NnU9oPBuXIx5L3HSN4frG4Zr0rwZY1NSVoKsIATdwzabHOESGHJX8xjXi3YeECrbUwsfIUQ00ct31yWNx';
  static const String _secretKey = 'sk_test_51AfCnUJe629jCerG6cwy5wfbS1BIe3IutGdznoVV57kzBUkJxznnU0C7RBH37oqWCUbM9ZFRm68bA8Ohjz7PoQv900C0KApFmU'; // Add your secret key here

  // Account IDs for seller and owner (these should be connected Stripe accounts)
  static const String _sellerAccountId = 'acct_1RPlBMQson788bGB'; // Replace with actual seller Stripe account ID
  static const String _ownerAccountId = 'acct_1AfCnUJe629jCerG';   // Replace with actual owner Stripe account ID

  static final CallMinutesService _callMinutesService = CallMinutesService();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize Stripe
  static Future<void> initialize() async {
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
  }
 final String _baseUrl = 'https://api.stripe.com/v1';

  Future<Map<String, dynamic>> createConnectAccount(String email) async {
    final url = Uri.parse('$_baseUrl/accounts');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'type': 'express',
        'email': email,
        'country': 'US',
        'capabilities[card_payments][requested]': 'true',
        'capabilities[transfers][requested]': 'true',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create Connect account: ${response.body}');
    }
  }

  Future<String> createAccountLink({required String accountId}) async {
    final url = Uri.parse('$_baseUrl/account_links');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'account': accountId,
        'refresh_url': 'https://brainbank.com/reauth',
        'return_url': 'https://brainbank.com/reauth/success',
        'success_url': 'https://brainbank.com/success',
        'type': 'account_onboarding',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['url'];
    } else {
      throw Exception('Failed to create account link: ${response.body}');
    }
  }
  // Create direct charge with split payments
static Future<Map<String, dynamic>> _createPaymentMethod(
    Map<String, dynamic> cardDetails,
  ) async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: _auth.currentUser?.email,
              name: _auth.currentUser?.displayName,
            ),
          ),
        ),
      );
      return {'success': true, 'paymentMethod': paymentMethod};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
   static Future<Map<String, dynamic>> createPaymentIntent(
  String amount,
  
  String currency, {
  String? description,
  Map<String, dynamic>? metadata,
required String stripeid,
}) async {
  try {
    // Convert amount to cents
    final amountInCents = (double.parse(amount) * 100).round();
    final ownerAmount = (amountInCents * 0.1).round();

    final body = {
      'amount': amountInCents.toString(),
      'currency': currency,
      'description': description ?? '',
      'payment_method_types[]': 'card',
      // Remove confirm: true - we'll confirm client-side
      'on_behalf_of': _sellerAccountId,
      'transfer_data[destination]': _sellerAccountId,
      'application_fee_amount': ownerAmount.toString(),
    };

    if (metadata != null) {
      metadata.forEach((key, value) {
        body['metadata[$key]'] = value.toString();
      });
    }

    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $_secretKey',
      },
      body: body.keys.map((key) => '$key=${Uri.encodeComponent(body[key]!)}').join('&'),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error'];
      throw Exception(error['message'] ?? 'Failed to create payment intent');
    }

    return jsonDecode(response.body);
  } catch (e) {
    debugPrint('Error creating payment intent: $e');
    rethrow;
  }
}
 
 static Future<PaymentIntentResult> purchaseCallMinutes(
  BuildContext context,
  double amount,
  int audioMinutes,
  int videoMinutes,
  String paymentMethod,
  String stripeid,
) async {
  try {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Create metadata
    final metadata = {
      'userId': userId,
      'audioMinutes': audioMinutes,
      'videoMinutes': videoMinutes,
      'purchase_type': 'call_minutes',
    };

    final description = 'Purchase: ${audioMinutes}min audio + ${videoMinutes}min video calls';

    // 1. Create payment intent (without confirming)
    final paymentIntent = await createPaymentIntent(
      amount.toString(),
      'USD',
      description: description,
      metadata: metadata,
      stripeid:stripeid,
    );

    // 2. Initialize payment sheet with the client secret
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent['client_secret'],
        merchantDisplayName: 'Buzz Me',
        style: ThemeMode.light,
        billingDetails: BillingDetails(
          email: _auth.currentUser?.email,
          name: _auth.currentUser?.displayName,
        ),
      ),
    );

    // 3. Present payment sheet to collect payment details
    await Stripe.instance.presentPaymentSheet();

    // 4. Payment succeeded - update user's call minutes
    await _callMinutesService.addPurchasedMinutes(
      userId,
      audioMinutes,
      videoMinutes,
    );

    // 5. Record successful transaction
    await _callMinutesService.createTransaction(
      userId: userId,
      amount: amount,
      status: 'succeeded',
      paymentMethod: paymentMethod,
      paymentIntentId: paymentIntent['id'],
      items: {'audioMinutes': audioMinutes, 'videoMinutes': videoMinutes},
    );

    return PaymentIntentResult(
      status: 'succeeded',
      paymentIntentId: paymentIntent['id'],
    );
  } on StripeException catch (e) {
    // Handle Stripe-specific errors
    final errorMessage = e.error.localizedMessage;
    debugPrint('Stripe error: $errorMessage');

    if (_auth.currentUser?.uid != null) {
      await _callMinutesService.createTransaction(
        userId: _auth.currentUser!.uid,
        amount: amount,
        status: 'failed',
        paymentMethod: paymentMethod,
        paymentIntentId: 'error_${DateTime.now().millisecondsSinceEpoch}',
        items: {
          'audioMinutes': audioMinutes,
          'videoMinutes': videoMinutes,
          'error': errorMessage,
        },
      );
    }

    return PaymentIntentResult(
      status: 'failed',
      errorMessage: errorMessage,
    );
  } catch (e) {
    debugPrint('General error: $e');
    
    if (_auth.currentUser?.uid != null) {
      await _callMinutesService.createTransaction(
        userId: _auth.currentUser!.uid,
        amount: amount,
        status: 'failed',
        paymentMethod: paymentMethod,
        paymentIntentId: 'error_${DateTime.now().millisecondsSinceEpoch}',
        items: {
          'audioMinutes': audioMinutes,
          'videoMinutes': videoMinutes,
          'error': e.toString(),
        },
      );
    }

    return PaymentIntentResult(
      status: 'failed',
      errorMessage: e.toString(),
    );
  }
}


// static Future<Map<String, dynamic>> createSplitPayment(
//   String amount,
//   String currency,
//   String paymentMethodId, {
//   String? description,
//   Map<String, dynamic>? metadata,
// }) async {
//   try {
//     final amountInCents = (double.parse(amount) * 100).round();
//     final ownerAmount = (amountInCents * 0.1).round(); // 10%
//     final sellerAmount = amountInCents - ownerAmount; // 90%

//     final response = await http.post(
//       Uri.parse('https://api.stripe.com/v1/payment_intents'),
//       headers: {
//         'Content-Type': 'application/x-www-form-urlencoded',
//         'Authorization': 'Bearer $_secretKey',
//       },
//       body: {
//         'amount': amountInCents.toString(),
//         'currency': currency,
//         'payment_method': paymentMethodId,
//         'confirm': 'true',
//         'description': description ?? '',
//         // metadata should be a flat map of key-value pairs (not JSON string)
//         if (metadata != null)
//           ...metadata.map((key, value) => MapEntry('metadata[$key]', value.toString())),
//         'on_behalf_of': _sellerAccountId,
//         'transfer_data[destination]': _sellerAccountId,
//         'application_fee_amount': ownerAmount.toString(),
//       },
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Payment failed: ${response.body}');
//     }

//     return jsonDecode(response.body);
//   } catch (e) {
//     throw Exception('Payment failed: $e');
//   }
// }

// static Future<PaymentIntentResult> processPayment(
//   BuildContext context,
//   double amount,
//   int audioMinutes,
//   int videoMinutes,
//   CardFieldInputDetails cardDetails,
// ) async {
//   try {
//     // Validate card details
//     if (!cardDetails.complete) {
//       throw Exception('Card details are incomplete. Please enter valid card information.');
//     }

//     final userId = _auth.currentUser?.uid;
//     if (userId == null) {
//       throw Exception('User not authenticated');
//     }

//     // 1. Create payment method
//     final paymentMethod = await Stripe.instance.createPaymentMethod(
//       params: PaymentMethodParams.card(
//         paymentMethodData: PaymentMethodData(
//           billingDetails: BillingDetails(
//             email: _auth.currentUser?.email,
//             name: _auth.currentUser?.displayName,
//           ),
//         ),
//       ),
//     );

//     // 2. Create payment intent with split using createSplitPayment
//     final paymentIntent = await createSplitPayment(
//       amount.toString(),
//       'USD',
//       paymentMethod.id,
//       description: '${audioMinutes}min audio + ${videoMinutes}min video calls',
//       metadata: {
//         'userId': userId,
//         'audioMinutes': audioMinutes,
//         'videoMinutes': videoMinutes,
//         'purchase_type': 'call_minutes',
//       },
//     );

//     debugPrint("paymentIntent: $paymentIntent");

//     // 3. Verify payment intent status
//     if (paymentIntent['status'] != 'succeeded') {
//       throw Exception('Payment intent not succeeded: ${paymentIntent['status']}');
//     }

//     // 4. Update user's call minutes
//     await _callMinutesService.addPurchasedMinutes(
//       userId,
//       audioMinutes,
//       videoMinutes,
//     );

//     // 5. Record transaction in Firebase
//     await _callMinutesService.createTransaction(
//       userId: userId,
//       amount: amount,
//       status: 'succeeded',
//       paymentMethod: 'card',
//       paymentIntentId: paymentIntent['id'],
//       items: {'audioMinutes': audioMinutes, 'videoMinutes': videoMinutes},
//     );

//     return PaymentIntentResult(
//       status: 'succeeded',
//       paymentIntentId: paymentIntent['id'],
//     );
//   } on StripeException catch (e) {
//     return PaymentIntentResult(
//       status: 'failed',
//       errorMessage: e.error.localizedMessage ?? 'Payment failed',
//     );
//   } catch (e) {
//     return PaymentIntentResult(
//       status: 'failed',
//       errorMessage: e.toString(),
//     );
//   }
// }
//   static Future<PaymentIntentResult> purchaseCallMinutess(
//     BuildContext context,
//     double amount,
//     int audioMinutes,
//     int videoMinutes,
//     String paymentMethod,
//   ) async {
//     try {
//       final userId = _auth.currentUser?.uid;
//     if (userId == null) {
//       throw Exception('User not authenticated');
//     }

//     // Create metadata
//     final metadata = {
//       'userId': userId,
//       'audioMinutes': audioMinutes,
//       'videoMinutes': videoMinutes,
//       'purchase_type': 'call_minutes',
//     };

  
//     // Create payment with split
//     final paymentIntent = await createSplitPayment(
//       amount.toString(),
//       'USD',
//               paymentMethod,
//       description: '',
//       metadata: metadata,
//     );

//     // Confirm the payment
// await Stripe.instance.confirmPayment(
//   paymentIntentClientSecret: paymentIntent['client_secret'],
//   data: PaymentMethodParams.card(
//     paymentMethodData: PaymentMethodData(
//       billingDetails: BillingDetails(
//         email: _auth.currentUser?.email,
//         name: _auth.currentUser?.displayName,
//       ),
//     ),
//   ),
// );
     
//       // Create metadata for the purchase
    

//       // Create description for the purchase
   
//       // Create payment with split
//       final payment = await createSplitPayment(
//         amount.toString(),
//         'USD',
//         '',
//         description: 'description',
//         metadata: metadata,
//       );

//       if (payment['error'] != null) {
//         throw Exception(payment['error']);
//       }

//       // Set up the payment sheet
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: payment['client_secret'],
//           merchantDisplayName: 'Buzz Me',
//           style: ThemeMode.light,
//           billingDetails: BillingDetails(
//             email: _auth.currentUser?.email,
//             name: _auth.currentUser?.displayName,
//           ),
//         ),
//       );

//       // Present the payment sheet
//       await Stripe.instance.presentPaymentSheet();

//       // Payment was successful, update the user's call minutes
//       await _callMinutesService.addPurchasedMinutes(
//         userId,
//         audioMinutes,
//         videoMinutes,
//       );

//       // Record transaction in Firebase
//       await _callMinutesService.createTransaction(
//         userId: userId,
//         amount: amount,
//         status: 'succeeded',
//         paymentMethod: paymentMethod,
//         paymentIntentId: payment['id'],
//         items: {'audioMinutes': audioMinutes, 'videoMinutes': videoMinutes},
//       );

//       return PaymentIntentResult(
//         status: 'succeeded',
//         paymentIntentId: payment['id'],
//       );
//     } on StripeException catch (e) {
//       print('Stripe error: ${e.error.localizedMessage}');

//       if (_auth.currentUser?.uid != null) {
//         await _callMinutesService.createTransaction(
//           userId: _auth.currentUser!.uid,
//           amount: amount,
//           status: 'failed',
//           paymentMethod: paymentMethod,
//           paymentIntentId: 'error_${DateTime.now().millisecondsSinceEpoch}',
//           items: {
//             'audioMinutes': audioMinutes,
//             'videoMinutes': videoMinutes,
//             'error': e.error.localizedMessage,
//           },
//         );
//       }

//       return PaymentIntentResult(
//         status: 'failed',
//         errorMessage: e.error.localizedMessage,
//       );
//     } catch (e) {
//       print('General error: $e');

//       if (_auth.currentUser?.uid != null) {
//         await _callMinutesService.createTransaction(
//           userId: _auth.currentUser!.uid,
//           amount: amount,
//           status: 'failed',
//           paymentMethod: paymentMethod,
//           paymentIntentId: 'error_${DateTime.now().millisecondsSinceEpoch}',
//           items: {
//             'audioMinutes': audioMinutes,
//             'videoMinutes': videoMinutes,
//             'error': e.toString(),
//           },
//         );
//       }

//       return PaymentIntentResult(status: 'failed', errorMessage: e.toString());
//     }
//   }


}

class PaymentIntentResult {
  final String status;
  final String? paymentIntentId;
  final String? errorMessage;

  PaymentIntentResult({
    required this.status,
    this.paymentIntentId,
    this.errorMessage,
  });

  bool get isSuccess => status == 'succeeded';
}