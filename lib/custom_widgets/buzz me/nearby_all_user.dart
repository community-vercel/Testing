import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/core/model/app_user.dart';
import 'package:code_structure/ui/screens/user_profile/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///
///   custom widget of nearby screen first tab --->  all users
///

class CustomNearbyAllUserWidget extends StatelessWidget {
  final AppUser appUser;
  const CustomNearbyAllUserWidget({
    required this.appUser,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(
              appUser: appUser,
            ),
          ),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(
            image: appUser.images?[0] != null
                ? NetworkImage('${appUser.images?[0]}')
                : AssetImage(AppAssets().pic),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${appUser.userName ?? ""}',
                    style: style14B.copyWith(color: whiteColor),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: appUser.gender == 'Female'
                          ? femaleColors
                          : maleColors,
                      borderRadius: BorderRadius.circular(60.r),
                      //  color: Colors.orange,
                    ),
                    height: 22.h,
                    width: 50.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          appUser.gender == "Male" ? Icons.male : Icons.female,
                          color: whiteColor,
                          size: 12,
                        ),
                        Text(
                          '${DateTime.now().year - appUser.dob!.year}',
                          style:
                              style14.copyWith(color: whiteColor, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            5.verticalSpace,
          ],
        ),
      ),
    );
  }
}
