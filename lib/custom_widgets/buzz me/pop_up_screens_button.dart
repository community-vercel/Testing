import 'package:flutter/material.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButtonPopup extends StatelessWidget {
  const CustomButtonPopup({
    super.key,
    this.ratingValue,
    required this.title,
    required this.onTap,
  });

  final double? ratingValue;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55.h,
        width: 230.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: LinearGradient(
            colors: [lightPinkColor, lightOrangeColor],
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: style17.copyWith(color: whiteColor),
          ),
        ),
      ),
    );
  }
}
