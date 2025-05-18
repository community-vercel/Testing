import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/ui/screens/checkout/payment_details_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double totalAmount;
  final int audioMinutes;
  final int videoMinutes;
  final String paymentMethod;

  const PaymentMethodScreen({
    super.key,
    required this.totalAmount,
    required this.audioMinutes,
    required this.videoMinutes,
    required this.paymentMethod,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String selectedMethod = 'stripe';

  @override
  void initState() {
    super.initState();
    selectedMethod = widget.paymentMethod;
  }

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
          'Payment',
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
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
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
                  children: [
                    Icon(Icons.call, size: 16, color: Colors.green),
                    SizedBox(width: 8.w),
                    Text(
                      'Audio Call: ${widget.audioMinutes} minutes',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Icon(Icons.videocam, size: 16, color: Colors.red),
                    SizedBox(width: 8.w),
                    Text(
                      'Video Call: ${widget.videoMinutes} minutes',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Divider(),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
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
                        color: lightPinkColor,
                      ),
                    ),
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
                  // Payment method selection
                  _buildPaymentMethod(
                    'stripe',
                    'Credit Card',
                    'Pay with your credit card via Stripe',
                    Icons.credit_card,
                    Colors.blue,
                  ),

                  _buildPaymentMethod(
                    'paypal',
                    'PayPal',
                    'Pay with your PayPal account',
                    Icons.paypal,
                    Colors.indigo,
                  ),

                  _buildPaymentMethod(
                    'applepay',
                    'Apple Pay',
                    'Pay with Apple Pay',
                    Icons.apple,
                    Colors.black,
                  ),

                  _buildPaymentMethod(
                    'googlepay',
                    'Google Pay',
                    'Pay with Google Pay',
                    Icons.g_mobiledata,
                    Colors.green,
                  ),

                  _buildPaymentMethod(
                    'bank',
                    'Bank Transfer',
                    'Pay directly from your bank account',
                    Icons.account_balance,
                    Colors.amber,
                  ),
                ],
              ),
            ),
          ),

          // Payment card preview for selected method
          Container(
            margin: EdgeInsets.all(20.w),
            height: 180.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade400,
                  Colors.pink.shade300,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 20.w,
                  top: 20.h,
                  child: Icon(
                    Icons.credit_card,
                    color: Colors.white.withOpacity(0.8),
                    size: 30,
                  ),
                ),
                Positioned(
                  right: 20.w,
                  top: 20.h,
                  child: Text(
                    'Visa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  left: 20.w,
                  bottom: 60.h,
                  child: Text(
                    '•••• •••• •••• 0123',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Positioned(
                  left: 20.w,
                  bottom: 20.h,
                  child: Text(
                    'John Smith',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                Positioned(
                  right: 20.w,
                  bottom: 20.h,
                  child: Text(
                    '12/25',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pay now button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentDetailsScreen(
                    totalAmount: widget.totalAmount,
                    paymentMethod: selectedMethod,
                    audioMinutes: widget.audioMinutes,
                    videoMinutes: widget.videoMinutes,
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                gradient: LinearGradient(
                  colors: [lightOrangeColor, lightPinkColor],
                ),
              ),
              child: Center(
                child: Text(
                  'Continue to Payment',
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

  Widget _buildPaymentMethod(
    String id,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = selectedMethod == id;

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isSelected ? lightPinkColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedMethod = id;
          });
        },
        borderRadius: BorderRadius.circular(15.r),
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              SizedBox(width: 15.w),
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
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Radio(
                value: id,
                groupValue: selectedMethod,
                onChanged: (value) {
                  setState(() {
                    selectedMethod = value as String;
                  });
                },
                activeColor: lightPinkColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
