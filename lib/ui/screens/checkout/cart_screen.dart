import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/ui/screens/checkout/cart_summary_screen.dart';
import 'package:provider/provider.dart';
import 'package:code_structure/core/providers/call_minutes_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartItem {
  final String name;
  final String duration;
  final double price;
  int quantity;
  final String type; // 'audio' or 'video'

  CartItem({
    required this.name,
    required this.duration,
    required this.price,
    this.quantity = 1,
    required this.type,
  });

  // Get total minutes based on quantity
  int get totalMinutes => int.parse(duration.split(' ')[0]) * quantity;
}

class CartScreen extends StatefulWidget {
  final bool fromInsufficientMinutes;

  const CartScreen({
    super.key,
    this.fromInsufficientMinutes = false,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> items;
  String promoCode = '';
  bool isPromoApplied = false;
  double discountAmount = 0.0;

  @override
  void initState() {
    super.initState();

    // Initialize cart items
    items = [
      CartItem(
          name: 'Audio Call', duration: '10 min', price: 10.00, type: 'audio'),
      CartItem(
          name: 'Video Call', duration: '10 min', price: 15.00, type: 'video'),
      CartItem(
          name: 'Chat', duration: '', price: 0.00, quantity: 1, type: 'chat'),
    ];

    // Load call minutes to show available balance
    _loadCallMinutes();
  }

  Future<void> _loadCallMinutes() async {
    if (FirebaseAuth.instance.currentUser != null) {
      final callMinutesProvider =
          Provider.of<CallMinutesProvider>(context, listen: false);
      await callMinutesProvider.refreshCallMinutes();
    }
  }

  double get subtotal =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get total => subtotal - discountAmount;

  void updateQuantity(int index, int change) {
    setState(() {
      items[index].quantity = (items[index].quantity + change).clamp(0, 10);
      if (items[index].quantity == 0) {
        items.removeAt(index);
      }
    });
  }

  void applyPromoCode() {
    // Example promo code "BUZZ25" for 25% off
    if (promoCode.toUpperCase() == "BUZZ25" && !isPromoApplied) {
      setState(() {
        discountAmount = subtotal * 0.25; // 25% off
        isPromoApplied = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Promo code applied: 25% off!')),
      );
    } else if (isPromoApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Promo code already applied')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid promo code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access call minutes provider to display available minutes
    final callMinutesProvider = Provider.of<CallMinutesProvider>(context);
    final callMinutes = callMinutesProvider.callMinutes;

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
          'Buy Call Minutes',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Available minutes section
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Available Minutes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(Icons.call, size: 16, color: Colors.green),
                          SizedBox(width: 5.w),
                          Text(
                            'Audio: ${callMinutes.audioAvailable} minutes',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.videocam, size: 16, color: Colors.red),
                          SizedBox(width: 5.w),
                          Text(
                            'Video: ${callMinutes.videoAvailable} minutes',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isFree = item.price == 0.00;

                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  child: Row(
                    children: [
                      // Icon for the item type
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: item.type == 'audio'
                              ? Colors.green.withOpacity(0.2)
                              : item.type == 'video'
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          item.type == 'audio'
                              ? Icons.call
                              : item.type == 'video'
                                  ? Icons.videocam
                                  : Icons.chat_bubble,
                          color: item.type == 'audio'
                              ? Colors.green
                              : item.type == 'video'
                                  ? Colors.red
                                  : Colors.blue,
                        ),
                      ),
                      SizedBox(width: 15.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.name} ${item.duration.isNotEmpty ? '(${item.duration})' : ''}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (!isFree)
                              Text(
                                'Total: ${item.totalMinutes} minutes',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!isFree)
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () => updateQuantity(index, -1),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () => updateQuantity(index, 1),
                            ),
                          ],
                        ),
                      SizedBox(width: 10.w),
                      Text(
                        isFree
                            ? 'Free'
                            : '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isFree ? Colors.green : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Promo code section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Add a promo code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                    ),
                    onChanged: (value) {
                      promoCode = value;
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                ElevatedButton(
                  onPressed: applyPromoCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightPinkColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text('Apply'),
                ),
              ],
            ),
          ),

          // Order summary
          Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal'),
                    Text('\$${subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Discount'),
                    Text('\$${discountAmount.toStringAsFixed(2)}'),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('\$${total.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          // Checkout button
          GestureDetector(
            onTap: () {
              if (items.any((item) => item.price > 0 && item.quantity > 0)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartSummaryScreen(
                      items: items,
                      discountAmount: discountAmount,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Please add call minutes to continue')),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              margin: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                gradient: LinearGradient(
                  colors: [lightOrangeColor, lightPinkColor],
                ),
              ),
              child: Center(
                child: Text(
                  'Checkout',
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
}
