import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/ui/screens/wallet/wallet_money/wallet_money_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletSettingsScreen extends StatelessWidget {
  const WalletSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          // Profile section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Shin Ryujin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '@yuibu',
                  style: TextStyle(
                    fontSize: 12,
                    color: lightPinkColor,
                  ),
                ),
              ],
            ),
          ),

          20.verticalSpace,

          // Account settings
          _SettingsItem(
            icon: Icons.person,
            title: 'Personal information',
            onTap: () {},
          ),

          16.verticalSpace,

          _SettingsItem(
            icon: Icons.credit_card,
            title: 'Bank account and credit card',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletMoneyScreen(),
                ),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.payment,
            title: 'Payment prefences',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.security,
            title: 'Login and security',
            onTap: () {},
          ),
          16.verticalSpace,
          _SettingsItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {},
          ),
          16.verticalSpace,
          _SettingsItem(
            icon: Icons.help,
            title: 'Help',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.note,
            title: 'Legal',
            onTap: () {},
          ),
          20.verticalSpace,
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSwitch;
  final bool isLogout;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSwitch = false,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        vertical: 10.h,
        horizontal: 20.w,
      ),
      leading: Icon(
        icon,
        color: lightPinkColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}
