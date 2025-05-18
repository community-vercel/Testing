import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/model/user_profile.dart';
import 'package:flutter/material.dart';

class CustomLookkingForWidget extends StatelessWidget {
  final UserProfileLookingForMOdel userProfileLookingForModel;
  CustomLookkingForWidget({
    required this.userProfileLookingForModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: transparentColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: Text('${userProfileLookingForModel.title}'),
      ),
    );
  }
}
