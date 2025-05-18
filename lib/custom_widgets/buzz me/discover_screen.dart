// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/core/model/app_user.dart';
import 'package:code_structure/ui/screens/user_profile/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDiscoverWIdget extends StatelessWidget {
  final AppUser appUser;
  final onRewindTap;
  final onAudioCallTap;
  final onVideoCallTap;
  final onSuperLikeTap;

  const CustomDiscoverWIdget({
    required this.appUser,
    required this.onRewindTap,
    required this.onAudioCallTap,
    required this.onVideoCallTap,
    required this.onSuperLikeTap,
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
      child: Stack(
        children: [
          Container(
            // height: MediaQuery.of(context).size.height * 0.87,
            // width: MediaQuery.of(context).size.width * 1,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    //   borderRadius: BorderRadius.circular(20),

                    child: Image(
                      height: MediaQuery.of(context).size.height * 0.55,
                      width: double.infinity,
                      image: appUser.images?[0] != null
                          ? NetworkImage('${appUser.images?[0]}')
                          : AssetImage(AppAssets().pic),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            '${error.toString()}',
                            style: style16,
                          ),
                        );
                      },
                    )),
                const Spacer(), // Use Spacer to push rows to the bottom
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center horizontally
                  children: [
                    Text(
                      '${appUser.userName ?? ''}',
                      style: style25.copyWith(fontSize: 25),
                    ),
                    8.horizontalSpace,
                    Container(
                      decoration: BoxDecoration(
                        gradient: appUser.gender == 'Female'
                            ? femaleColors
                            : maleColors,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            appUser.gender == "Male"
                                ? Icons.male
                                : Icons.female,
                            color: whiteColor,
                          ),
                          Text(
                            '${DateTime.now().year - appUser.dob!.year}',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          10.horizontalSpace,
                        ],
                      ),
                    ),
                  ],
                ),
                //  const SizedBox(height: 8), // Add some spacing
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center horizontally
                  children: [
                    Text(
                      '${appUser.address ?? 'No Address'}',
                      style: style16.copyWith(color: Color(0xffC1C0C9)),
                    ),
                  ],
                ),
                const SizedBox(height: 15), // Add spacing before avatars
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            right: 0,
            left: 0,
            // center the row of circle avatars
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onRewindTap,
                  child: const CircleAvatar(
                    backgroundColor: whiteColor,
                    radius: 25,
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onVideoCallTap,
                  child: Container(
                    height: 73.h,
                    width: 73.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffDB2719),
                      ),
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.video_camera_back,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onAudioCallTap,
                  child: Container(
                    height: 73.h,
                    width: 73.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffDB2719),
                      ),
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.call,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                // CircleAvatar(
                //   radius: 35,
                //   child: Icon(Icons.call),
                // ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onSuperLikeTap,
                  child: const CircleAvatar(
                    backgroundColor: whiteColor,
                    radius: 25,
                    child: Icon(Icons.star),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
