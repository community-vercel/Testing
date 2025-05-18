import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:flutter/material.dart';

class customHeader extends StatelessWidget {
  final String? heading;
  final Color? headingColor;
  final VoidCallback? onTap; // Added onTap parameter
  final String? image;
  const customHeader({
    required this.heading,
    required this.headingColor,
    required this.image,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            heading!,
            style: style25B.copyWith(
                fontSize: 34, fontWeight: FontWeight.w700, color: headingColor),
          ),
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              backgroundColor: headingColor == whiteColor
                  ? Color(0xffFFA180)
                  : greyColor.shade300,
              //  backgroundColor: Color(0xffFFA180),
              radius: 22,
              // child: Image(image: AssetImage(image!)),
              child: Icon(
                Icons.filter_list_rounded,
                color: Colors.white,
                size: 30,
              ),

              // backgroundImage: AssetImage(AppAssets().fbIcon),
            ),
          ),
        ],
      ),
    );
  }
}
