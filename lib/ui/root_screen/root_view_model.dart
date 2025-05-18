import 'package:code_structure/core/enums/view_state_model.dart';
import 'package:code_structure/core/others/base_view_model.dart';
import 'package:code_structure/ui/screens/Inbox/inbox_screen.dart';
import 'package:code_structure/ui/screens/discover/discover_screen.dart';
import 'package:code_structure/ui/screens/favorites/favorites_screen.dart';
import 'package:code_structure/ui/screens/my_profile/my_profile_screen.dart';
import 'package:code_structure/ui/screens/nearby_all_user/all_user_.dart';

import 'package:flutter/material.dart';

class RootViewModel extends BaseViewModel {
  // final PageController pageController = PageController(initialPage: 0);

  int selectedScreen = 0;

  List<Widget> allScreen = [
    // call screen here according to index
    DiscoverScreen(),
    NearbyAllUserScreen(),

    FavoritesScreen(),
    InboxScreen(),
    MyProfileScreen()
  ];

  ///
  /// Constructor
  ///
  RootViewModel(val) {
    updatedScreen(val);
    notifyListeners();
  }

  // int selectIndex = 0;

  updatedScreen(int index) {
    setState(ViewState.busy);
    selectedScreen = index;
    setState(ViewState.idle);
    notifyListeners();
  }

  // pushScreen(int index) {
  //   pageController.animateToPage(index,
  //       duration: Duration(milliseconds: 2000), curve: Curves.bounceIn);
  //   selectedScreen = index;
  //   notifyListeners();
  // }
}
