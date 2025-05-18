// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class hmmm extends StatefulWidget {
//   const hmmm({super.key});

//   @override
//   State<hmmm> createState() => _hmmmState();
// }

// class _hmmmState extends State<hmmm> {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => HomeViewModel(),
//       child: Consumer<RootViewModel>(
//           builder: (context, model, child) => const Scaffold(
//                 body: Column(
//                   children: [],
//                 ),
//               )),
//     );
//   }
// }
//****************************************************************/
// import 'package:card_swiper/card_swiper.dart';
// import 'package:flutter/material.dart';

// class OverlappingCardSwiper extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Overlapping Card Swiper'),
//       ),
//       body: Swiper(
//         itemHeight: 400,
//         itemWidth: 300,
//         itemBuilder: (BuildContext context, int index) {
//           return Card(
//             margin: EdgeInsets.all(10),
//             elevation: 4.0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15.0),
//             ),
//             child: Center(
//               child: Text('Card $index'),
//             ),
//           );
//         },
//         itemCount: 5,
//         viewportFraction: 0.8,
//         scale: 0.9,
//         scrollDirection: Axis.horizontal,
//         layout: SwiperLayout.TINDER,
//       ),
//     );
//   }
// }
//********************************************************************/
// _about() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 15.0),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'About',
//           style: style25B.copyWith(color: headingColor),
//         ),
//         10.verticalSpace,
//         Text(
//           'I am a very simple person with a very simple life. I love to travel and explore new places. I am a very simple person with a very simple life. I love to travel and explore new places.',
//           style: style16.copyWith(color: subHeadingColor, fontSize: 15),
//         ),
//         10.verticalSpace,
//       ],
//     ),
//   );
// }

// ///
// /// friends Section
// ///
// _friends(UserProfileViewModel model, BuildContext context) {
//   return Column(
//     children: [
//       Text(
//         'Friends',
//         style: style25B.copyWith(color: headingColor),
//       )
//     ],
//   );
// }
