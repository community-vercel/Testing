import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/custom_widgets/buzz%20me/nearby_all_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FindSomeoneByTagScreen extends StatelessWidget {
  const FindSomeoneByTagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: Icon(
          Icons.arrow_back_ios_rounded,
          size: 25,
          color: blackColor,
        ),
        title: Text(
          'Find someone by Tags',
          style: style17.copyWith(color: subHeadingColor),
        ),
        centerTitle: true,
        actions: [
          Text(
            'Done',
            style: style17.copyWith(
                color: lightPinkColor, fontWeight: FontWeight.w600),
          ),
          10.horizontalSpace,
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 100.h,
            width: double.infinity,
            decoration: BoxDecoration(color: appBarColor),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                // Use Align to control the ListTile's position
                alignment:
                    Alignment.centerLeft, // Align to the left (or center)
                child: IntrinsicHeight(
                  // Use IntrinsicHeight to size the container based on the ListTile's height
                  child: Container(
                    decoration: BoxDecoration(
                        color: fillColor2,
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Container(
                        height: 22.h,
                        width: 35.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [lightPinkColor, lightOrangeColor],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '23',
                            style: style17.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      title: Text(
                        'Tags',
                        style: style17.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: subHeadingColor),
                      ),
                      trailing: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 24.h,
                          width: 24.w,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: lightGreyColor3),
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Image.asset(
                              AppAssets().cancel,
                              color: whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          20.verticalSpace,
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: Container(
                    height: 70.h,
                    width: 70.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightGreyColor,
                      image: DecorationImage(
                          image: AssetImage(AppAssets().pic),
                          fit: BoxFit.cover),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        'shyan zahid ',
                        style: style17.copyWith(color: headingColor),
                      ),
                      Container(
                        height: 20.h,
                        // width: 38,
                        decoration: BoxDecoration(
                          gradient: AppAssets == AppAssets().genderMan
                              ? LinearGradient(
                                  colors: [darkBlueColor, skyBlueColor])
                              : LinearGradient(
                                  colors: [lightPinkColor, lightOrangeColor]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 20.h,
                              width:
                                  38.w, // Increased width for better visibility
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(1.8),
                                child: Image.asset(AppAssets().genderWoman),
                              ),
                            ),
                            Text(
                              '23',
                              style: style14.copyWith(
                                  color: whiteColor, fontSize: 10.sp),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  subtitle: Column(
                    children: [
                      5.verticalSpace,
                      Row(
                        children: [
                          CustomTagsBySomeoneCategory(
                            title: 'guitar',
                          ),
                          10.horizontalSpace,
                          CustomTagsBySomeoneCategory(
                            title: 'Dance',
                          ),
                          10.horizontalSpace,
                          CustomTagsBySomeoneCategory(
                            title: 'Music',
                          ),
                          10.horizontalSpace,
                          CustomTagsBySomeoneCategory(
                            title: 'R & B',
                          )
                        ],
                      ),
                      5.verticalSpace,
                      Divider(
                        color: tabBarColor,
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTagsBySomeoneCategory extends StatelessWidget {
  final String? title;
  const CustomTagsBySomeoneCategory({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(6)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            title!,
            style: style14.copyWith(color: headingColor, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
