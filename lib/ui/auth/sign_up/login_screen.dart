import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/custom_widgets/a_buttons/social_button.dart';
import 'package:code_structure/ui/auth/sign_up/login_screen_view_model.dart';
import 'package:code_structure/ui/root_screen/root_screen.dart';
import 'package:code_structure/ui/screens/edit_profile/edit_profile_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LogInScreen extends StatefulWidget {
  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  init() async {
    await Future.delayed(const Duration(seconds: 2), () {
      // navigator and rout mean from one page to another
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RootScreen(),
      ));
    });
  }

  @override
  void initState() {
    // init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LogInViewModel(),
      child: Consumer<LogInViewModel>(
        builder: (context, viewModel, child) => Scaffold(
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 1,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    AppAssets().splashScreen,
                  ),
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
                  360.verticalSpace,
                  SocialLoginButton(
                    icon: AppAssets().fbIcon,
                    text: "Connect with Facebook",
                    color: Color(0xFF4267B2),
                    onPressed: () async {
                      final result = await viewModel.signInWithFacebook();
                      if (result != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              canPop: false,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  20.verticalSpace,
                  SocialLoginButton(
                    icon: AppAssets().googleIcon,
                    text: "Connect with Google",
                    color: Color(0xFFDB4437),
                    onPressed: () async {
                      final result = await viewModel.signInWithGoogle();
                      if (result != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              canPop: false,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  50.verticalSpace,
                  Text(
                    "By clicking start, you agree to our\nTerms and Conditions",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
