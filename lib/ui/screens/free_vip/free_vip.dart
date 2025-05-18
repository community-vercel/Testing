// import 'package:code_structure/core/constants/app_assest.dart';
// import 'package:code_structure/core/constants/colors.dart';
// import 'package:code_structure/core/constants/text_style.dart';
// import 'package:code_structure/core/services/subscription_service.dart';
// import 'package:code_structure/ui/screens/vip_center/vip_center.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class FreeVIPScreen extends StatelessWidget {
//   const FreeVIPScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: transparentColor,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: Colors.white,
//           ),
//         ),
//         title: Text(
//           'Free VIP Upgrade',
//           style: style25.copyWith(color: Colors.white),
//         ),
//         centerTitle: true,
//       ),
//       extendBodyBehindAppBar: true,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: MediaQuery.of(context).size.height / 2.2,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage(AppAssets().freeVip),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             Text(
//               'Enjoy 7 days of free VIP',
//               style: style25.copyWith(color: headingColor),
//             ),
//             30.verticalSpace,
//             CustomListTile(
//               imagUrl: AppAssets().crown,
//               title: 'See who liked you',
//               subtitle: 'You\'ll see everyone who liked you',
//             ),
//             CustomListTile(
//               imagUrl: AppAssets().crown,
//               title: 'See who visited you',
//               subtitle: 'You\'ll see everyone who visited you',
//             ),
//             CustomListTile(
//               imagUrl: AppAssets().crown,
//               title: 'Unlimited rewinds',
//               subtitle: 'You\'ll can rewind and reswipe the last persons',
//             ),
//             CustomListTile(
//               imagUrl: AppAssets().crown,
//               title: 'Incognito mode',
//               subtitle: 'You can browse others anonymously',
//             ),
//             CustomListTile(
//               imagUrl: AppAssets().crown,
//               title: 'Extra superlikes',
//               subtitle: 'You can superlike up to 5 times a day',
//             ),
//             CustomListTile(
//               imagUrl: AppAssets().crown,
//               title: 'Spotlight',
//               subtitle: 'You will be on spotlight and be seen by thousands ',
//             ),
//             GestureDetector(
//               onTap: () async {
//                 final userId = FirebaseAuth.instance.currentUser?.uid;
//                 if (userId != null) {
//                   try {
//                     final subscriptionService = SubscriptionService();
//                     await subscriptionService.startFreeTrial(userId);
//                     _PurchaseSuccesfullyDialogBox(context);
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Failed to start free trial: $e'),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
//                 }
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(36),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     vertical: 13.h,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(30),
//                     gradient: LinearGradient(
//                       colors: [lightOrangeColor, lightPinkColor],
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       'Start Free Trial',
//                       style: style17B,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 30.0),
//               child: Text(
//                   'After the 7-day free trial, your subscription will auto-renew for \$39.99 every 2 months.',
//                   style: style17.copyWith(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w400,
//                       color: lightGreyColor)),
//             ),
//             60.verticalSpace,
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _PurchaseSuccesfullyDialogBox(BuildContext context) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) => StatefulBuilder(
//         builder: (BuildContext context, StateSetter setState) {
//           return Dialog(
//             child: Container(
//               height: 400.h,
//               width: 305.w,
//               decoration: BoxDecoration(color: lightGreyColor),
//               child: Stack(
//                 children: [
//                   Container(
//                     height: 140.h,
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                           image: AssetImage(
//                             AppAssets().Oval,
//                           ),
//                           fit: BoxFit.cover),
//                     ),
//                   ),
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Image.asset(AppAssets().stars),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 32.0),
//                         child: CircleAvatar(
//                           radius: 40.r,
//                           backgroundImage: AssetImage(AppAssets().pic),
//                         ),
//                       )
//                     ],
//                   ),
//                   Positioned(
//                     bottom: 20,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const VipCenter(),
//                             ),
//                           );
//                         },
//                         child: Text('Continue to VIP Center'),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// /*  child: Stack(
//             children: [
//               // Circular Avatar (or Container with rounded image)
//               Container(
//                 width: 150, // Adjust size as needed
//                 height: 150, // Adjust size as needed
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   image: DecorationImage(
//                     image: NetworkImage(
//                         'YOUR_IMAGE_URL'), // Replace with your image URL
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),

//               // Crown Image at the bottom right
//               Positioned(
//                 bottom: 0,
//                 right: 0,
//                 child: Container(
//                   width: 50, // Adjust size as needed
//                   height: 50, // Adjust size as needed
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white, // Background color for the crown
//                   ),
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.all(8.0), // Adjust padding as needed
//                     child: Image.asset(
//                         'assets/crown.png'), // Replace with your crown image asset
//                   ),
//                 ),
//               ),
//             ],
//           ),*/
