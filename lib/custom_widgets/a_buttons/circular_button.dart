import 'package:code_structure/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircularButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String icon;
  final Color backgroundColor;
  final double radius;

  const CircularButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = darkGreyColor,
    this.radius = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25.w,
      height: 25.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero, // ensures no extra padding
        ),
        child: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Image.asset(
            icon,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
