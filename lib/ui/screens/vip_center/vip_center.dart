// import 'package:code_structure/core/constants/app_assest.dart';
// import 'package:code_structure/core/constants/colors.dart';
// import 'package:code_structure/core/constants/text_style.dart';
// import 'package:code_structure/core/others/base_view_model.dart';
// import 'package:code_structure/core/services/vip_service.dart';
// import 'package:code_structure/custom_widgets/buzz%20me/pop_up_screens_button.dart';
// import 'package:code_structure/custom_widgets/vip_feature_wrapper.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class VipCenter extends StatefulWidget {
//   const VipCenter({super.key});

//   @override
//   State<VipCenter> createState() => _VipCenterState();
// }

// class _VipCenterState extends State<VipCenter> {
//   final VipService _vipService = VipService();
//   Map<String, dynamic>? _vipStatus;
//   int? _remainingTrialDays;

//   @override
//   void initState() {
//     super.initState();
//     _loadVipStatus();
//   }

//   Future<void> _loadVipStatus() async {
//     try {
//       final vipStatus = await _vipService.getVipStatus();
//       final remainingDays = await _vipService.getRemainingTrialDays();
//       setState(() {
//         _vipStatus = vipStatus;
//         _remainingTrialDays = remainingDays;
//       });
//     } catch (e) {
//       print('Error loading VIP status: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => BaseViewModel(),
//       child: Consumer<BaseViewModel>(
//         builder: (context, value, child) => Scaffold(
//           appBar: AppBar(
//             leading: IconButton(
//               icon: Icon(
//                 Icons.arrow_back_ios_sharp,
//                 size: 25,
//                 color: blackColor,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//             title: Text(
//               'VIP Center',
//               style: style17.copyWith(
//                   color: Color(0xff262628), fontWeight: FontWeight.w600),
//             ),
//             centerTitle: true,
//             actions: [
//               Text(
//                 'History',
//                 style: style17.copyWith(
//                     color: lightPinkColor, fontWeight: FontWeight.w600),
//               )
//             ],
//           ),
//           body: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Container(
//                   height: 300.h,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [lightOrangeColor, lightPinkColor],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                   ),
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         top: 200.h,
//                         left: 48.w,
//                         child: Container(
//                           height: 60.h,
//                           width: 230.w,
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                               image: AssetImage(AppAssets().category),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             _vipStatus?['isVip'] == true
//                                 ? 'VIP Member'
//                                 : 'Free User',
//                             style: style25.copyWith(
//                                 color: whiteColor, fontWeight: FontWeight.w600),
//                           ),
//                           20.verticalSpace,
//                           if (_vipStatus?['isVip'] == true) ...[
//                             Text(
//                               'Expiration Date: ${_vipStatus?['vipEndDate'] != null ? DateFormat('MMMM dd, yyyy').format(_vipStatus!['vipEndDate']) : 'N/A'}',
//                               style: style14.copyWith(
//                                   color: whiteColor,
//                                   fontWeight: FontWeight.w400),
//                             ),
//                             if (_remainingTrialDays != null &&
//                                 _remainingTrialDays! > 0) ...[
//                               10.verticalSpace,
//                               Text(
//                                 'Trial: $_remainingTrialDays days remaining',
//                                 style: style14.copyWith(
//                                     color: whiteColor,
//                                     fontWeight: FontWeight.w400),
//                               ),
//                             ],
//                           ],
//                           20.verticalSpace,
//                           CustomButtonPopup(
//                             title: _vipStatus?['isVip'] == true
//                                 ? 'Renew Subscription'
//                                 : 'Upgrade to VIP',
//                             onTap: () {
//                               // Handle renewal/upgrade
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 10.verticalSpace,
//                 Center(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ShaderMask(
//                         shaderCallback: (bounds) => LinearGradient(
//                           colors: [lightOrangeColor, lightPinkColor],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ).createShader(bounds),
//                         blendMode: BlendMode.srcIn,
//                         child: Container(
//                           height: 26.h,
//                           width: 26.w,
//                           child: Image(
//                             image: AssetImage(AppAssets().crown),
//                           ),
//                         ),
//                       ),
//                       10.horizontalSpace,
//                       Text(
//                         'VIP PRIVILEGES',
//                         style: style17.copyWith(color: Color(0xffC1C0C9)),
//                       ),
//                     ],
//                   ),
//                 ),
//                 20.verticalSpace,
//                 _buildVipFeature(
//                   AppAssets().crown,
//                   'See who liked you',
//                   'You will see everyone who liked you',
//                   'see_likes',
//                 ),
//                 _buildVipFeature(
//                   AppAssets().crown,
//                   'See who visited you',
//                   'You will see everyone who visited you',
//                   'see_visits',
//                 ),
//                 _buildVipFeature(
//                   AppAssets().crown,
//                   'Unlimited rewinds',
//                   'You can rewind and reswipe the last persons',
//                   'unlimited_rewinds',
//                 ),
//                 _buildVipFeature(
//                   AppAssets().crown,
//                   'Incognito mode',
//                   'You can browse others anonymously',
//                   'incognito_mode',
//                 ),
//                 _buildVipFeature(
//                   AppAssets().crown,
//                   'Extra superlikes',
//                   'You can superlike up to 5 times a day',
//                   'extra_superlikes',
//                 ),
//                 _buildVipFeature(
//                   AppAssets().crown,
//                   'Spotlight',
//                   'You will be on spotlight and be seen by thousands',
//                   'spotlight',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVipFeature(
//       String icon, String title, String subtitle, String feature) {
//     return VipFeatureWrapper(
//       feature: feature,
//       child: CustomListTile(
//         imagUrl: icon,
//         title: title,
//         subtitle: subtitle,
//       ),
//     );
//   }
// }

// class CustomListTile extends StatelessWidget {
//   final String? imagUrl;
//   final String? title;
//   final String? subtitle;

//   const CustomListTile({
//     this.imagUrl,
//     this.title,
//     this.subtitle,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: CircleAvatar(
//         radius: 25,
//         child: Padding(
//           padding: EdgeInsets.all(10),
//           child: Image.asset(imagUrl!),
//         ),
//       ),
//       title: Text(
//         title!,
//         style: style17.copyWith(color: headingColor),
//       ),
//       subtitle: Text(
//         subtitle!,
//         style: style17.copyWith(
//             color: lightGreyColor,
//             fontSize: 15.sp,
//             fontWeight: FontWeight.w400),
//       ),
//     );
//   }
// }
