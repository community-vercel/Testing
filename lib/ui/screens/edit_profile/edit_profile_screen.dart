// ignore_for_file: unused_element

import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/core/enums/view_state_model.dart';
import 'package:code_structure/core/model/user_profile.dart';
import 'package:code_structure/core/providers/user_provider.dart';
import 'package:code_structure/custom_widgets/buzz%20me/user_profile_interesting.dart';
import 'package:code_structure/ui/root_screen/root_screen.dart';
import 'package:code_structure/ui/screens/edit_profile/edit_profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:code_structure/core/services/image_cache_helper.dart';
import 'dart:io';

class EditProfileScreen extends StatelessWidget {
  final bool canPop;
  EditProfileScreen({
    Key? key,
    this.canPop = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditProfileViewModel(),
      child: Consumer2<EditProfileViewModel, UserProvider>(
          builder: (context, viewModel, userProvider, child) {
        return PopScope(
          canPop: canPop,
          child: ModalProgressHUD(
            inAsyncCall: viewModel.state == ViewState.busy,
            progressIndicator: CircularProgressIndicator(
              color: lightOrangeColor,
            ),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: canPop
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed:
                            canPop ? () => Navigator.of(context).pop() : null,
                      )
                    : null,
                title: const Text("Profile",
                    style: TextStyle(color: Colors.black)),
                actions: [
                  TextButton(
                    onPressed: () async {
                      if (viewModel.isProfileComplete) {
                        await viewModel.updateUser();
                        userProvider.getUser();
                        if (!canPop) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RootScreen()),
                              (route) => false);
                        } else {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: const Text("Done",
                        style: TextStyle(color: Colors.pink)),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.verticalSpace,
                    _buildPhotoGrid(viewModel, context),
                    20.verticalSpace,

                    // Profile Info
                    _buildInfoRow(
                      "Username",
                      viewModel.appUser.userName ?? "Not set",
                      onTap: () {
                        _displayUsernameDialog(context, viewModel);
                      },
                    ),
                    _buildInfoRow(
                      "Birthday",
                      viewModel.appUser.dob != null
                          ? DateFormat('MMM dd, yyyy')
                              .format(viewModel.appUser.dob!)
                          : 'Not set',
                      showArrow: true,
                      onTap: () {
                        _displayDatePicker(context, viewModel);
                      },
                    ),
                    _buildInfoRow(
                      "Gender",
                      viewModel.appUser.gender ?? "Not set",
                      showArrow: true,
                      onTap: () {
                        _displayGenderDialog(context, viewModel);
                      },
                    ),

                    36.verticalSpace,

                    // About you
                    GestureDetector(
                      onTap: () => _displayAboutDialog(context, viewModel),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "About you",
                            style: style25B,
                          ),
                          10.verticalSpace,
                          Text(
                            viewModel.appUser.about ?? "Tap to add description",
                            style: style17.copyWith(
                              fontWeight: FontWeight.w400,
                              color: viewModel.appUser.about != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    19.verticalSpace,
                    Divider(
                      height: 1,
                      color: Colors.grey[300],
                    ),

                    _buildInfoRow(
                      'Height',
                      '${viewModel.appUser.height ?? '??'} cm',
                      onTap: () {
                        _displayHeightDialog(context, viewModel);
                      },
                    ),
                    _buildInfoRow(
                      'Weight',
                      '${viewModel.appUser.weight ?? '??'} kg',
                      onTap: () {
                        _displayWeightDialog(context, viewModel);
                      },
                    ),

                    // Relationship status
                    _buildInfoRow(
                      "Relationship status",
                      viewModel.appUser.relationshipStatus ?? 'Not set',
                      showArrow: true,
                      onTap: () {
                        _displayRelationshipStatusDialog(context, viewModel);
                      },
                    ),
                    _buildInfoRow(
                      "Looking for",
                      viewModel.appUser.lookingFor?.join(', ') ?? 'Not set',
                      showArrow: true,
                      onTap: () => _displayLookingForDialog(context, viewModel),
                    ),

                    30.verticalSpace,

                    // Interesting
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Interesting",
                          style: style25B,
                        ),
                        20.verticalSpace,
                        Wrap(
                          runSpacing: 15.0,
                          spacing: 18.0,
                          children: List.generate(
                            viewModel.appUser.interests?.length ?? 0,
                            (index) {
                              return CustomInterestingWidget(
                                  userProfileModel:
                                      UserProfileInterestingItemModel(
                                          title: viewModel
                                              .appUser.interests![index]));
                            },
                          ),
                        ),
                        30.verticalSpace,
                        GestureDetector(
                          onTap: () {
                            _displayAddInterestDialog(context, viewModel);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 17.h),
                            decoration: BoxDecoration(
                                border: Border.all(color: lightPinkColor),
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Text(
                                "Add more interests",
                                style: TextStyle(
                                    fontSize: 14, color: lightPinkColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    30.verticalSpace,

                    // Location
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Location",
                          style: style25B,
                        ),
                        20.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: lightGreyColor,
                            ),
                            10.horizontalSpace,
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _showLocationOptions(context, viewModel),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Current location",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    if (viewModel.appUser.address != null)
                                      Text(
                                        "${viewModel.appUser.address}",
                                        style: style17.copyWith(
                                          color: lightGreyColor3,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: lightGreyColor,
                            ),
                          ],
                        ),
                        20.verticalSpace,
                        Divider(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // Add this common dialog theme
  ThemeData _getDialogTheme() {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: lightPinkColor,
        secondary: lightOrangeColor,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightPinkColor,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightPinkColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  // Enhanced username dialog
  Future<void> _displayUsernameDialog(
      BuildContext context, EditProfileViewModel viewModel) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _userNameController =
        TextEditingController(text: viewModel.appUser.userName);

    return showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: _getDialogTheme(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Choose your username',
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This is how you\'ll appear to others',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  12.verticalSpace,
                  TextFormField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: viewModel.validateUsername,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('SAVE'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    viewModel.updateField('userName', _userNameController.text);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _displayDatePicker(
      BuildContext context, EditProfileViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.appUser.dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != viewModel.appUser.dob) {
      viewModel.updateField('dob', picked);
    }
  }

  Future<void> _displayGenderDialog(
      BuildContext context, EditProfileViewModel viewModel) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: _getDialogTheme(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Select Gender',
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose how you identify',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  12.verticalSpace,
                  ...viewModel.predefinedGenders.map((gender) {
                    bool isSelected = viewModel.appUser.gender == gender;
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isSelected ? lightPinkColor : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color:
                            isSelected ? lightPinkColor.withOpacity(0.1) : null,
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          gender,
                          style: TextStyle(
                            color: isSelected ? lightPinkColor : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: lightPinkColor)
                            : null,
                        onTap: () {
                          viewModel.updateField('gender', gender);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _displayRelationshipStatusDialog(
      BuildContext context, EditProfileViewModel viewModel) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: _getDialogTheme(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Relationship Status',
              style: style17.copyWith(fontWeight: FontWeight.bold),
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select your current status',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  12.verticalSpace,
                  ...viewModel.predefinedRelationshipStatus.map((status) {
                    bool isSelected =
                        viewModel.appUser.relationshipStatus == status;
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isSelected ? lightPinkColor : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color:
                            isSelected ? lightPinkColor.withOpacity(0.1) : null,
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          status,
                          style: TextStyle(
                            color: isSelected ? lightPinkColor : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: lightPinkColor)
                            : null,
                        onTap: () {
                          viewModel.updateField('relationshipStatus', status);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // Enhanced height dialog
  Future<void> _displayHeightDialog(
      BuildContext context, EditProfileViewModel viewModel) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _heightController =
        TextEditingController(text: viewModel.appUser.height?.toString());

    return showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: _getDialogTheme(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Your Height',
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter height in cm',
                      suffixText: 'cm',
                      prefixIcon: Icon(Icons.height),
                    ),
                    validator: viewModel.validateHeight,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('SAVE'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    viewModel.updateField(
                        'height', int.parse(_heightController.text));
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _displayWeightDialog(BuildContext context, EditProfileViewModel viewModel) {
    TextEditingController _weightController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: _getDialogTheme(),
          child: AlertDialog(
            title: Text('Enter Weight'),
            content: TextField(
              controller: _weightController,
              decoration: InputDecoration(hintText: 'Weight'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  viewModel.updateField(
                      'weight', int.parse(_weightController.text));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _displayAddInterestDialog(
      BuildContext context, EditProfileViewModel viewModel) {
    TextEditingController _interestController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: _getDialogTheme(),
          child: AlertDialog(
            title: Text('Add Interest'),
            content: TextField(
              controller: _interestController,
              decoration: InputDecoration(hintText: 'Interest'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  viewModel.addInterest(_interestController.text);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Enhanced about dialog
  Future<void> _displayAboutDialog(
      BuildContext context, EditProfileViewModel viewModel) async {
    final TextEditingController _aboutController =
        TextEditingController(text: viewModel.appUser.about);
    final _formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: _getDialogTheme(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Tell us about yourself',
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share your interests, hobbies, or anything you\'d like others to know',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  12.verticalSpace,
                  TextFormField(
                    controller: _aboutController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Write something about yourself...',
                      alignLabelWithHint: true,
                    ),
                    validator: viewModel.validateAbout,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('SAVE'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    viewModel.updateField('about', _aboutController.text);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Enhanced looking for dialog
  Future<void> _displayLookingForDialog(
      BuildContext context, EditProfileViewModel viewModel) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: _getDialogTheme(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'What are you looking for?',
            ),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select all that apply',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      12.verticalSpace,
                      ...viewModel.predefinedLookingFor.map((item) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: viewModel.appUser.lookingFor
                                          ?.contains(item) ??
                                      false
                                  ? lightPinkColor
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(item),
                            trailing: Icon(
                              viewModel.appUser.lookingFor?.contains(item) ??
                                      false
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: viewModel.appUser.lookingFor
                                          ?.contains(item) ??
                                      false
                                  ? lightPinkColor
                                  : Colors.grey[400],
                            ),
                            onTap: () {
                              viewModel.toggleLookingFor(item);
                              setState(() {});
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text('DONE'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool showDivider = true, bool showArrow = false, onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 17.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 16),
                ),
                Spacer(),
                Text(
                  value,
                  style: style17.copyWith(
                    color: lightGreyColor3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                10.horizontalSpace,
                if (showArrow)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: lightGreyColor,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.grey[300],
          ),
      ],
    );
  }

  Widget _buildInterestChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildPhotoGrid(EditProfileViewModel viewModel, context) {
    return Column(
      spacing: 13.h,
      children: [
        SizedBox(
          height: 225.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: _buildPhotoItem(viewModel, 1, context, isLarge: true),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 13.h,
                  children: [
                    _buildPhotoItem(viewModel, 2, context),
                    _buildPhotoItem(viewModel, 3, context),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPhotoItem(viewModel, 4, context),
            _buildPhotoItem(viewModel, 5, context),
            _buildPhotoItem(viewModel, 6, context),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoItem(EditProfileViewModel viewModel, int index, context,
      {bool isLarge = false}) {
    // Adjust index to match the array (array is 0-based, but UI shows 1-based)
    final arrayIndex = index - 1;

    // Check if this position has an image (either from network or newly selected)
    final hasImage = viewModel.selectedImages[arrayIndex] != null ||
        (viewModel.appUser.images?[arrayIndex] != null);

    return GestureDetector(
      onTap: () async {
        await viewModel.selectfromGallery(arrayIndex);
      },
      child: Stack(
        children: [
          Container(
            height: isLarge ? 225.h : 106.h,
            width: isLarge ? double.infinity : 106.w,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: (viewModel.selectedImages[arrayIndex] != null)
                ? Image.file(
                    viewModel.selectedImages[arrayIndex]!,
                    fit: BoxFit.cover,
                  )
                : (viewModel.appUser.images?[arrayIndex] != null)
                    ? CachedProfileImage(
                        imageUrl: viewModel.appUser.images![arrayIndex]!,
                        width: isLarge ? double.infinity : 106.w,
                        height: isLarge ? 225.h : 106.h,
                      )
                    : Container(
                        color: lightGreyColor,
                        child: Icon(
                          Icons.add,
                          size: 30,
                          color: lightGreyColor4,
                        ),
                      ),
          ),

          // Position indicator
          Positioned(
            right: 5,
            bottom: 5,
            child: Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.r),
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  index.toString(),
                ),
              ),
            ),
          ),

          // Delete button - only show if there's an actual image
          if (hasImage)
            Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                onTap: () {
                  _showDeleteConfirmation(context, viewModel, arrayIndex);
                },
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.5),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 18.r,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Confirmation dialog before deleting an image
  void _showDeleteConfirmation(
      BuildContext context, EditProfileViewModel viewModel, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Image'),
          content: Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('DELETE'),
              onPressed: () async {
                Navigator.pop(context);
                await viewModel.deleteImage(index);
              },
            ),
          ],
        );
      },
    );
  }

  // Add this method to show location options
  void _showLocationOptions(
      BuildContext context, EditProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.my_location),
                title: Text('Use current location'),
                onTap: () async {
                  Navigator.pop(context);
                  await viewModel.updateLocation();
                },
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: Text('Search location'),
                onTap: () {
                  Navigator.pop(context);
                  _showSearchLocationDialog(context, viewModel);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Add this method to show search location dialog
  void _showSearchLocationDialog(
      BuildContext context, EditProfileViewModel viewModel) {
    final TextEditingController _searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: _getDialogTheme(),
          child: AlertDialog(
            title: Text('Search Location'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Enter location',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('SEARCH'),
                onPressed: () async {
                  if (_searchController.text.isNotEmpty) {
                    Navigator.pop(context);
                    await viewModel
                        .updateCustomLocation(_searchController.text);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CachedProfileImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;

  const CachedProfileImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<CachedProfileImage> createState() => _CachedProfileImageState();
}

class _CachedProfileImageState extends State<CachedProfileImage> {
  bool _isLoading = true;
  String? _cachedImagePath;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      // Check if the image is already cached or download it
      final cachedFile =
          await ImageCacheHelper.getOrDownloadImage(widget.imageUrl);

      if (cachedFile != null) {
        setState(() {
          _cachedImagePath = cachedFile.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(lightPinkColor),
          ),
        ),
      );
    } else if (_hasError) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: Center(
          child: Icon(Icons.error_outline, color: Colors.red),
        ),
      );
    } else if (_cachedImagePath != null) {
      return Image.file(
        File(_cachedImagePath!),
        fit: BoxFit.cover,
        width: widget.width,
        height: widget.height,
      );
    } else {
      // Fallback to network image
      return Image.network(
        widget.imageUrl,
        fit: BoxFit.cover,
        width: widget.width,
        height: widget.height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(lightPinkColor),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: Center(
              child: Icon(Icons.error_outline, color: Colors.red),
            ),
          );
        },
      );
    }
  }
}

class CachedCircleAvatar extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final Widget? fallbackWidget;

  const CachedCircleAvatar({
    Key? key,
    this.imageUrl,
    required this.radius,
    this.fallbackWidget,
  }) : super(key: key);

  @override
  State<CachedCircleAvatar> createState() => _CachedCircleAvatarState();
}

class _CachedCircleAvatarState extends State<CachedCircleAvatar> {
  bool _isLoading = true;
  String? _cachedImagePath;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrl != null) {
      _loadImage();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(CachedCircleAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      if (widget.imageUrl != null) {
        _loadImage();
      } else {
        setState(() {
          _isLoading = false;
          _cachedImagePath = null;
        });
      }
    }
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl == null) return;

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Check if the image is already cached or download it
      final cachedFile =
          await ImageCacheHelper.getOrDownloadImage(widget.imageUrl!);

      if (cachedFile != null) {
        setState(() {
          _cachedImagePath = cachedFile.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading circle avatar image: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl == null) {
      return widget.fallbackWidget ??
          CircleAvatar(
            radius: widget.radius,
            backgroundImage: AssetImage(AppAssets().pic),
          );
    }

    if (_isLoading) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.grey[300],
        child: SizedBox(
          width: widget.radius,
          height: widget.radius,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(lightPinkColor),
            strokeWidth: 2,
          ),
        ),
      );
    } else if (_hasError) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.grey[300],
        child:
            Icon(Icons.error_outline, color: Colors.red, size: widget.radius),
      );
    } else if (_cachedImagePath != null) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundImage: FileImage(File(_cachedImagePath!)),
      );
    } else {
      // Fallback to network image
      return CircleAvatar(
        radius: widget.radius,
        backgroundImage: NetworkImage(widget.imageUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Handle error silently
        },
      );
    }
  }
}
