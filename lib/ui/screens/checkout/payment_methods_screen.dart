import 'package:code_structure/core/services/database_services.dart';
import 'package:code_structure/ui/screens/checkout/card_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/ui/screens/checkout/checkout_success_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:code_structure/core/providers/call_minutes_provider.dart';
import 'package:code_structure/core/services/stripe_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final double totalAmount;
  final int audioMinutes;
  final int videoMinutes;
  final String paymentMethod;

  const PaymentMethodsScreen({
    super.key,
    required this.totalAmount,
    required this.audioMinutes,
    required this.videoMinutes,
    required this.paymentMethod,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String selectedPaymentMethod = 'creditCard';
  bool _isProcessing = false;
  final DatabaseServices _databaseServices = DatabaseServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Purchase summary
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purchase Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.call, size: 16, color: Colors.green),
                        SizedBox(width: 8.w),
                        Text('Audio Call'),
                      ],
                    ),
                    Text('${widget.audioMinutes} min'),
                  ],
                ),
                SizedBox(height: 5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.videocam, size: 16, color: Colors.red),
                        SizedBox(width: 8.w),
                        Text('Video Call'),
                      ],
                    ),
                    Text('${widget.videoMinutes} min'),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Credit Card Option
                  _buildPaymentMethodOption(
                    'creditCard',
                    'Credit Card',
                    'Default Payment Method',
                    Icons.credit_card,
                    Colors.orange,
                    [Colors.orange.shade400, Colors.pink.shade300],
                    cardNumber: '**** **** **** 8543',
                    expiryDate: '12/25',
                  ),

                  SizedBox(height: 15.h),

                  // Purple Branding
                  _buildPaymentMethodOption(
                    'purpleBranding',
                    'Purple Branding',
                    'UI Elements',
                    Icons.brush,
                    Colors.purple,
                    [Colors.purple.shade400, Colors.deepPurple.shade600],
                    amount: 74.55,
                  ),

                  SizedBox(height: 15.h),

                  // Illustrations
                  _buildPaymentMethodOption(
                    'illustrations',
                    'Illustrations',
                    'UI Components',
                    Icons.image,
                    Colors.blue,
                    [Colors.blue.shade400, Colors.lightBlue.shade600],
                    amount: 139.00,
                  ),

                  SizedBox(height: 15.h),

                  // Animation Features
                  _buildPaymentMethodOption(
                    'animationFeatures',
                    'Animation Features',
                    'UI Elements',
                    Icons.movie,
                    Colors.green,
                    [Colors.green.shade400, Colors.teal.shade600],
                    amount: 99.00,
                  ),
                ],
              ),
            ),
          ),

          // Total amount
          Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${widget.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Pay now button
          GestureDetector(
            onTap: _isProcessing ? null : () => _processPayment(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                gradient: LinearGradient(
                  colors: [lightOrangeColor, lightPinkColor],
                ),
              ),
              child: Center(
                child: _isProcessing
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.0,
                        ),
                      )
                    : Text(
                        'Pay now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _processPayment(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    try {
            debugPrint("Intent sssssa ");
  final userId = _auth.currentUser?.uid;
    final stripeId = await _databaseServices.getSellerStripeId(userId.toString());

      // Use the Stripe service to process the payment
      final result = await StripeService.purchaseCallMinutes(
        context,
        widget.totalAmount,
        widget.audioMinutes,
        widget.videoMinutes,
        widget.paymentMethod,
        stripeId.toString(),
      );
      debugPrint("Intent sssssa ");

      if (result.isSuccess) {
        // Refresh call minutes data
        final callMinutesProvider =
            Provider.of<CallMinutesProvider>(context, listen: false);
        await callMinutesProvider.refreshCallMinutes();

        // Navigate to success screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutSuccessScreen(),
          ),
          (route) => route.isFirst,
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${result.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset processing state
      setState(() {
        _isProcessing = false;
      });
    }
  }


// Future<void> _processPayments(
//   BuildContext context, {
//   required double totalAmount,
//   required int audioMinutes,
//   required int videoMinutes,
// }) async {
//   // Show dialog with card form
//   final cardDetails = await showDialog<CardFieldInputDetails>(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text('Enter Card Details'),
//       content: SingleChildScrollView(
//         child: CardForm(
//           onCardComplete: (details) {
//             // This will be called automatically when card is complete
//           },
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel'),
//         ),
//       ],
//     ),
//   );

//   if (cardDetails == null || !cardDetails.complete) {
//     // User cancelled or card is incomplete
//     return;
//   }

//   // Show loading
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => Center(child: CircularProgressIndicator()),
//   );

//   try {
//     final result = await StripeService.processPayment(
//  context,
//       totalAmount,
//       audioMinutes,
//       videoMinutes,
//       cardDetails,
//     );

//     Navigator.pop(context); // Dismiss loading

//     if (result.isSuccess) {
//       // Handle successful payment
//       final callMinutesProvider = Provider.of<CallMinutesProvider>(context, listen: false);
//       await callMinutesProvider.refreshCallMinutes();

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => CheckoutSuccessScreen()),
//         (route) => route.isFirst,
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Payment failed: ${result.errorMessage}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   } catch (e) {
//     Navigator.pop(context); // Dismiss loading
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Payment failed: ${e.toString()}'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }
 
 
  Widget _buildPaymentMethodOption(
    String id,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    List<Color> gradientColors, {
    String? cardNumber,
    String? expiryDate,
    double? amount,
  }) {
    final isSelected = selectedPaymentMethod == id;
    final isCard = cardNumber != null;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = id;
        });
      },
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSelected ? lightPinkColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon or gradient container
            isCard
                ? Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 25,
                    ),
                  )
                : Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 25,
                    ),
                  ),

            SizedBox(width: 15.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (isCard) ...[
                    SizedBox(height: 5.h),
                    Text(
                      cardNumber,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Price or date
            if (amount != null)
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (expiryDate != null)
              Text(
                expiryDate,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}