import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/ui/screens/wallet/wallet_transaction_amount/wallet_transaction_amount_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletSendScreen extends StatelessWidget {
  const WalletSendScreen({super.key});

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
          'Send to',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Send methods grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '|  ',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Where to send?',
                      style: style14.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  children: [
                    _SendMethodItem(
                      icon: Icons.qr_code,
                      smallLabel: 'Send to',
                      label: 'an Account',
                      color: Colors.blue,
                      isSelected: false,
                      onTap: () {},
                    ),
                    _SendMethodItem(
                      icon: Icons.account_circle,
                      smallLabel: 'Send to',
                      label: 'Bank Account',
                      color: Colors.red,
                      isSelected: true,
                      onTap: () {},
                    ),
                    _SendMethodItem(
                      icon: Icons.qr_code,
                      smallLabel: 'Create',
                      label: 'Invoice',
                      color: Colors.blue,
                      isSelected: false,
                      onTap: () {},
                    ),
                    _SendMethodItem(
                      icon: Icons.account_circle,
                      smallLabel: 'Withdraw',
                      label: 'Cash',
                      color: Colors.red,
                      isSelected: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Next button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletTransactionAmountScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 20.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [lightOrangeColor, lightPinkColor],
                  ),
                ),
                child: Center(
                  child: Text(
                    'Next',
                    style: style17B,
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

class _SendMethodItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String smallLabel;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _SendMethodItem({
    required this.icon,
    required this.label,
    required this.smallLabel,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          border: isSelected
              ? Border.all(
                  color: lightBlueColor,
                )
              : null,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 6),
              blurRadius: 12,
              spreadRadius: 0,
              color: Color(0xFF12122F08).withOpacity(0.03),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52.h,
              height: 52.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 27,
              ),
            ),
            14.verticalSpace,
            Text(
              smallLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
