import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/core/providers/all_users_provider.dart';
import 'package:code_structure/custom_widgets/buzz%20me/nearby_all_user.dart';
import 'package:code_structure/ui/screens/filter/filter_screen.dart';
import 'package:code_structure/ui/screens/nearby_all_user/all_user_view_model.dart';
import 'package:code_structure/ui/screens/free_vip/free_vip.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../../custom_widgets/buzz me/header.dart';

class NearbyAllUserScreen extends StatelessWidget {
  const NearbyAllUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final model = NearbyAllUsersViewModel();
        // Initialize with users from provider
        final usersProvider =
            Provider.of<AllUsersProvider>(context, listen: false);
        model.updateUsers(usersProvider.users);
        return model;
      },
      child: Consumer2<NearbyAllUsersViewModel, AllUsersProvider>(
        builder: (context, model, usersProvider, child) {
          // Update users when provider changes
          if (usersProvider.users != model.allUsers) {
            model.updateUsers(usersProvider.users);
          }

          return DefaultTabController(
            length: 4,
            child: Scaffold(
              body: Column(
                children: [
                  40.verticalSpace,
                  customHeader(
                    heading: 'Nearby',
                    headingColor: blackColor,
                    image: AppAssets().fbIcon,
                    onTap: () async {
                      // Show filter screen and get results
                      final filters = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilterScreen(),
                        ),
                      );

                      // Apply filters if returned
                      if (filters != null) {
                        model.applyFilters(
                          filters['minAge'] as int,
                          filters['maxAge'] as int,
                          filters['distance'] as int,
                          filters['gender'] as String,
                          filters['latitude'] as double?,
                          filters['longitude'] as double?,
                        );
                      }
                    },
                  ),
                  20.verticalSpace,
                  TabBar(
                    tabAlignment: TabAlignment.center,
                    isScrollable: false,
                    indicatorColor: indicatorColor,
                    unselectedLabelColor: greyColor,
                    labelColor: indicatorColor,
                    indicatorWeight: 2,
                    indicatorSize: TabBarIndicatorSize.tab,
                    //  labelStyle: style16.copyWith(color: indicatorColor),
                    tabs: [
                      Text(
                        'All Users',
                        style: style16.copyWith(
                            // fontSize: 17.sp,
                            ),
                      ),
                      Text(
                        'Spotlight',
                        style: style16.copyWith(
                            //  fontSize: 17.sp,
                            ),
                      ),
                      Text(
                        'New',
                        style: style16.copyWith(
                            //fontSize: 17.sp,
                            ),
                      ),
                      Text(
                        'Nearby',
                        style: style16.copyWith(
                            //fontSize: 17.sp,
                            ),
                      ),
                    ],
                  ),
                  if (model.isLoading)
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: lightPinkColor,
                        ),
                      ),
                    )
                  else if (model.filteredUsers.isEmpty)
                    _buildEmptyState(context, model)
                  else
                    Expanded(
                      child: TabBarView(
                        children: [
                          _allUsers(context, model, usersProvider),
                          _spotlightUsers(context, model, usersProvider),
                          _allUsers(context, model, usersProvider),
                          _allUsers(context, model, usersProvider),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, NearbyAllUsersViewModel model) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/empty_search.json',
              width: 200,
              height: 200,
              repeat: true,
            ),
            20.verticalSpace,
            Text(
              'No users found nearby',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            10.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Try adjusting your filters or expanding your search radius to find more people',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: greyColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            30.verticalSpace,
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: lightPinkColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () async {
                final filters = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FilterScreen(),
                  ),
                );

                if (filters != null) {
                  model.applyFilters(
                    filters['minAge'] as int,
                    filters['maxAge'] as int,
                    filters['distance'] as int,
                    filters['gender'] as String,
                    filters['latitude'] as double?,
                    filters['longitude'] as double?,
                  );
                }
              },
              icon: Icon(Icons.tune, color: whiteColor),
              label: Text(
                'Adjust Filters',
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _allUsers(
    BuildContext context,
    NearbyAllUsersViewModel model,
    AllUsersProvider usersProvider,
  ) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.99,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
        ),
        itemCount: model.filteredUsers.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: CustomNearbyAllUserWidget(
              appUser: model.filteredUsers[index],
            ),
          );
        },
      ),
    );
  }

  Widget _spotlightUsers(
    BuildContext context,
    NearbyAllUsersViewModel model,
    AllUsersProvider usersProvider,
  ) {
    // Filter users who are in spotlight
    final spotlightUsers =
        model.filteredUsers.where((user) => user.inSpotlight ?? false).toList();

    if (spotlightUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/empty_search.json',
              width: 200,
              height: 200,
              repeat: true,
            ),
            20.verticalSpace,
            Text(
              'No spotlight users found',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            // 10.verticalSpace,
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 40),
            //   child: Text(
            //     'Upgrade to VIP to appear in spotlight and get more visibility!',
            //     style: TextStyle(
            //       fontSize: 16.sp,
            //       color: greyColor,
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            // 30.verticalSpace,
            // ElevatedButton.icon(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: lightPinkColor,
            //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(25),
            //     ),
            //   ),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const FreeVIPScreen(),
            //       ),
            //     );
            //   },
            //   icon: Icon(Icons.star, color: whiteColor),
            //   label: Text(
            //     'Upgrade to VIP',
            //     style: TextStyle(
            //       color: whiteColor,
            //       fontSize: 16.sp,
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.99,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
        ),
        itemCount: spotlightUsers.length,
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: CustomNearbyAllUserWidget(
                  appUser: spotlightUsers[index],
                ),
              ),
              Positioned(
                top: 10,
                right: 15,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [lightPinkColor, lightOrangeColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: whiteColor, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Spotlight',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
