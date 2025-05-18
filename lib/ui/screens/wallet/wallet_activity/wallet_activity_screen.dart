import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletActivityScreen extends StatelessWidget {
  const WalletActivityScreen({super.key});

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
          'Transaction activity',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Filter tabs
            Container(
              child: Row(
                children: [
                  _FilterTab(
                    label: 'All',
                    isSelected: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  _FilterTab(
                    label: 'Income',
                    isSelected: false,
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  _FilterTab(
                    label: 'Expense',
                    isSelected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            16.verticalSpace,

            // Transaction list
            Expanded(
              child: ListView(
                children: [
                  _TransactionItem(
                    iconBackgroundColor: lightPinkColor,
                    icon: Icons.account_balance,
                    title: 'Bank Account',
                    subtitle: 'Today, 10:00',
                    amount: '\$500.00',
                    status: 'Money Sent',
                    onTap: () {},
                  ),
                  _TransactionItem(
                    iconBackgroundColor: lightPinkColor,
                    icon: Icons.account_balance,
                    title: 'Bank Account',
                    subtitle: 'Today, 14:30',
                    amount: '\$120.00',
                    status: 'Money Sent',
                    onTap: () {},
                  ),
                  _TransactionItem(
                    iconBackgroundColor: lightPinkColor,
                    icon: Icons.account_balance,
                    title: 'Bank Account',
                    subtitle: 'Yesterday, 09:15',
                    amount: '\$250.00',
                    status: 'Money Recieved',
                    onTap: () {},
                  ),
                  _TransactionItem(
                    iconBackgroundColor: lightPinkColor,
                    icon: Icons.account_balance,
                    title: 'Bank Account',
                    subtitle: '24 Jun, 16:45',
                    amount: '\$180.00',
                    status: 'Money Recieved',
                    onTap: () {},
                  ),
                  _TransactionItem(
                    iconBackgroundColor: lightPinkColor,
                    icon: Icons.account_balance,
                    title: 'Bank Account',
                    subtitle: '23 Jun, 11:30',
                    amount: '\$75.00',
                    status: 'Money Sent',
                    onTap: () {},
                  ),
                  _TransactionItem(
                    iconBackgroundColor: lightPinkColor,
                    icon: Icons.account_balance,
                    title: 'Bank Account',
                    subtitle: '20 Jun, 13:20',
                    amount: '\$320.00',
                    status: 'Money Sent',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(23.r),
          ),
          border: isSelected ? null : Border.all(color: Colors.black26),
          color: isSelected ? lightPinkColor.withOpacity(0.15) : null,
        ),
        child: Text(
          'Recieved',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? lightPinkColor : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final onTap;
  final String amount;
  final Color iconBackgroundColor;
  final bool isPositive;

  const _TransactionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
    required this.amount,
    required this.iconBackgroundColor,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBackgroundColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconBackgroundColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: style14.copyWith(
                    fontWeight: FontWeight.w500,
                    color: blackColor,
                  ),
                ),
                6.verticalSpace,
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(23.r),
                  ),
                  color: lightBlueColor.withOpacity(0.15),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    color: lightPinkColor,
                  ),
                ),
              ),
              5.verticalSpace,
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
