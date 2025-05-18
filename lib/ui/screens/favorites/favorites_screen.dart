import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/providers/all_users_provider.dart';
import 'package:code_structure/core/providers/user_provider.dart';
import 'package:code_structure/custom_widgets/buzz%20me/nearby_all_user.dart';
import 'package:code_structure/ui/screens/favorites/favorites_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isDropdownOpen = false;

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesViewModel(),
      child: Consumer3<FavoritesViewModel, AllUsersProvider, UserProvider>(
          builder: (context, favoritesViewModel, allUsersProvider, userProvider,
              child) {
        var likes = allUsersProvider.users
            .where(
              (element) => userProvider.user.liked!.contains(element.uid),
            )
            .toList();
        var visits = allUsersProvider.users
            .where(
              (element) => userProvider.user.visited!.contains(element.uid),
            )
            .toList();

        var superLikes = allUsersProvider.users
            .where(
              (element) => userProvider.user.superLiked!.contains(element.uid),
            )
            .toList();

        var matches = allUsersProvider.users
            .where(
              (element) => userProvider.user.matched!.contains(element.uid),
            )
            .toList();

        var allConnection = [];
        allConnection.addAll(likes);
        allConnection.addAll(superLikes);
        allConnection.addAll(visits);
        allConnection.addAll(matches);

        // to remove duplications
        allConnection = allConnection.toSet().toList();

        List<dynamic> selectedList =
            (favoritesViewModel.selectedCategory == 'All connections')
                ? allConnection
                : (favoritesViewModel.selectedCategory == 'Likes')
                    ? likes
                    : (favoritesViewModel.selectedCategory == 'Visits')
                        ? visits
                        : (favoritesViewModel.selectedCategory == 'Matches')
                            ? matches
                            : superLikes;

        return Scaffold(
          appBar: AppBar(
            title: Text('Favorites'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                      color: fillColor2,
                      borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 20.h,
                              width: 34,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [lightPinkColor, lightOrangeColor],
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(selectedList.length.toString()),
                              ),
                            ),
                            10.w.horizontalSpace,
                            Text(
                              favoritesViewModel.selectedCategory,
                              style: TextStyle(fontSize: 17, color: blackColor),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(_isDropdownOpen
                              ? Icons.keyboard_arrow_up_sharp
                              : Icons.keyboard_arrow_down_sharp),
                          onPressed: _toggleDropdown,
                        ),
                      ],
                    ),
                  ),
                ),
                _buildDropdownContent(favoritesViewModel),
                Divider(),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: selectedList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CustomNearbyAllUserWidget(
                        appUser: selectedList[index],
                      );
                    },
                  ),
                ),
                // ... (rest of your content)
              ],
            ),
          ),
        );
      }),
    );
  }

  ///
  ///
  ///
  Widget _buildDropdownContent(FavoritesViewModel viewModel) {
    if (!_isDropdownOpen) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        20.verticalSpace,
        Container(
          height: 50.h,
          decoration: BoxDecoration(color: fillColor2),
          child: ListTile(
            leading: Container(
              height: 24.h,
              width: 24.w,
              child: Image.asset(
                AppAssets().appLogo,
                fit: BoxFit.cover,
              ),
            ),
            title: Text('Matches'),
            onTap: () {
              viewModel.toggleCategory('Matches');
              _toggleDropdown();
            },
          ),
        ),
        10.verticalSpace,
        Container(
          height: 50.h,
          decoration: BoxDecoration(color: fillColor2),
          child: ListTile(
            leading: Container(
              height: 24.h,
              width: 24.w,
              child: Image.asset(
                AppAssets().appLogo,
                fit: BoxFit.cover,
              ),
            ),
            title: Text('Visits'),
            onTap: () {
              viewModel.toggleCategory('Visits');

              _toggleDropdown();
            },
          ),
        ),
        10.verticalSpace,
        Container(
          height: 50.h,
          decoration: BoxDecoration(color: fillColor2),
          child: ListTile(
            leading: Container(
              height: 24.h,
              width: 24.w,
              child: Image.asset(
                AppAssets().appLogo,
                fit: BoxFit.cover,
              ),
            ),
            title: Text('Likes'),
            onTap: () {
              viewModel.toggleCategory('Likes');

              _toggleDropdown();
            },
          ),
        ),
        10.verticalSpace,
        Container(
          height: 50.h,
          decoration: BoxDecoration(color: fillColor2),
          child: ListTile(
            leading: Container(
              height: 24.h,
              width: 24.w,
              child: Image.asset(
                AppAssets().appLogo,
                fit: BoxFit.cover,
              ),
            ),
            title: Text('SuperLikes'),
            onTap: () {
              viewModel.toggleCategory('SuperLikes');

              _toggleDropdown();
            },
          ),
        ),
      ],
    );
  }
}
