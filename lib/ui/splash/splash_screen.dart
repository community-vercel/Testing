import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/ui/auth/sign_up/login_screen.dart';
import 'package:code_structure/ui/root_screen/root_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (_auth.currentUser != null) {
      // User is logged in, navigate to root screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => RootScreen()),
      );
    } else {
      // User is not logged in, navigate to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LogInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets().splashScreen),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            95.verticalSpace,
            Image.asset(
              AppAssets().appLogo,
              height: 100.h,
              width: 110.w,
            ),
            10.verticalSpace,
            Image.asset(
              AppAssets().talksyText,
              scale: 4,
              height: 50.h,
              width: 140.w,
            ),
          ],
        ),
      ),
    );
  }
}
