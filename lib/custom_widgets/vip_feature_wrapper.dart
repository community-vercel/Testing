// import 'package:flutter/material.dart';
// import 'package:code_structure/core/services/vip_service.dart';
// import 'package:code_structure/ui/screens/free_vip/free_vip.dart';

// class VipFeatureWrapper extends StatelessWidget {
//   final Widget child;
//   final String feature;
//   final Widget? nonVipWidget;
//   final VoidCallback? onVipRequired;

//   const VipFeatureWrapper({
//     Key? key,
//     required this.child,
//     required this.feature,
//     this.nonVipWidget,
//     this.onVipRequired,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: VipService().isFeatureAvailable(feature),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final isAvailable = snapshot.data ?? false;

//         if (isAvailable) {
//           return child;
//         }

//         if (nonVipWidget != null) {
//           return nonVipWidget!;
//         }

//         return FreeVIPScreen();
//       },
//     );
//   }
// }
