import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletTransactionDetailsScreen extends StatelessWidget {
  const WalletTransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 6),
                    blurRadius: 12,
                    spreadRadius: 0,
                    color: Color(0xFF12122F08).withOpacity(0.03),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'from:',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 11.sp,
                        ),
                      ),
                      Text(
                        'Payme Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        'USD \$140.00',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            16.verticalSpace,

            // Bank Account section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 6),
                    blurRadius: 12,
                    spreadRadius: 0,
                    color: Color(0xFF12122F08).withOpacity(0.03),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bank Account',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          'Bank Mandiri - ******5879',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            35.verticalSpace,

            // Transfer details
            _TransferDetailItem(
              label: 'Transfer amount',
              value: 'USD \$140.00',
            ),
            8.verticalSpace,
            _TransferDetailItem(
              label: 'Fee',
              value: 'USD \$1',
            ),
            8.verticalSpace,
            _TransferDetailItem(
              label: 'Exchange rate',
              value: 'USD \$1 = Rp.153.553',
            ),

            12.verticalSpace,
            const Divider(),
            12.verticalSpace,

            // Net Amount
            const _TransferDetailItem(
              label: 'Net Amount',
              value: 'Rp.153.553.453.00',
            ),

            const Spacer(),

            // Send button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 20.h,
                ),
                margin: EdgeInsets.symmetric(horizontal: 36.w, vertical: 20.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [lightOrangeColor, lightPinkColor],
                  ),
                ),
                child: Center(
                  child: Text(
                    'Send',
                    style: style17B,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferDetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _TransferDetailItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style14B.copyWith(
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: style14.copyWith(
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
