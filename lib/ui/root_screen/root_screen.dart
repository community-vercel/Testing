import 'package:code_structure/core/constants/app_assest.dart';

import 'package:code_structure/custom_widgets/bottom_navigator_bar.dart';
import 'package:code_structure/ui/root_screen/root_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';

class RootScreen extends StatelessWidget {
  final int? selectedScreen;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  RootScreen({super.key, this.selectedScreen = 0});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RootViewModel(selectedScreen),
      child: Consumer<RootViewModel>(
        builder: (context, model, child) => Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,

          ///
          /// Start Body
          ///
          body: model.allScreen[model.selectedScreen],

          ///
          /// BottomBar
          ///
          bottomNavigationBar: Container(
            height: 78.h,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, 1),
                    blurRadius: 7.r,
                    spreadRadius: 0),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ///
                ///
                ///
                GestureDetector(
                  onTap: () {
                    model.updatedScreen(0);
                  },
                  child: Container(
                    // alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: model.selectedScreen == 0
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(13.r)),
                    child: Image.asset(
                      model.selectedScreen == 0
                          ? AppAssets().discover2
                          : AppAssets().discover1,

                      // // 0 mean index 0
                      // color:
                      //     model.selectedScreen == 0 ? Colors.grey : Colors.grey,
                      scale: 4,
                    ),
                  ),
                ),

                CustomBottomNavigatorBar(
                  image: model.selectedScreen == 1
                      ? AppAssets().nearby2
                      : AppAssets().nearby1,
                  onTap: () {
                    model.updatedScreen(1);
                  },
                  boxColor: model.selectedScreen == 1
                      ? Colors.transparent
                      : Colors.transparent,
                ),

                CustomBottomNavigatorBar(
                  image: model.selectedScreen == 2
                      ? AppAssets().Favorite2
                      : AppAssets().Favorite1,
                  onTap: () {
                    model.updatedScreen(2);
                  },
                  boxColor: model.selectedScreen == 2
                      ? Colors.transparent
                      : Colors.transparent,
                ),
                CustomBottomNavigatorBar(
                  image: model.selectedScreen == 3
                      ? AppAssets().Message2
                      : AppAssets().Message1,
                  onTap: () {
                    model.updatedScreen(3);
                  },
                  boxColor: model.selectedScreen == 3
                      ? Colors.transparent
                      : Colors.transparent,
                ),
                CustomBottomNavigatorBar(
                  image: model.selectedScreen == 4
                      ? AppAssets().Profile2
                      : AppAssets().Profile1,
                  onTap: () {
                    model.updatedScreen(4);
                  },
                  boxColor: model.selectedScreen == 4
                      ? Colors.transparent
                      : Colors.transparent,
                ),
              ],
            ),
          ),

          ///
          /// Right Drawer
          ///
          // endDrawer: buildDrawer(context),
        ),
      ),
    );
  }
}

//   Widget bottomBar(RootViewModel model) {
//     return BottomAppBar(
//       color: Colors.green,
//       elevation: 0.0,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           CustomBottomNavigator(
//             currentIndex: model.selectedScreen,
//             indexNumber: 1,
//             text: 'Shop',
//             image: model.selectedScreen == 0 ? "" : "AppAssets.shop",
//             onPressed: () {
//               model.updatedScreen(0);
//             },
//           ),
//           CustomBottomNavigator(
//             currentIndex: model.selectedScreen,
//             indexNumber: 1,
//             text: 'Shop',
//             image: model.selectedScreen == 1 ? "" : "AppAssets.shop",
//             onPressed: () {
//               model.updatedScreen(1);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
