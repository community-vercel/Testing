import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/enums/view_state_model.dart';
import 'package:code_structure/core/providers/all_users_provider.dart';
import 'package:code_structure/core/services/database_services.dart';
import 'package:code_structure/core/services/stripe_service.dart';
import 'package:code_structure/custom_widgets/buzz%20me/discover_screen.dart';
import 'package:code_structure/custom_widgets/buzz%20me/header.dart';
import 'package:code_structure/ui/screens/checkout/custom/custom.dart';
import 'package:code_structure/ui/screens/discover/discover_screen_view_model.dart';
import 'package:code_structure/ui/screens/filter/filter_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:lottie/lottie.dart';
import 'package:code_structure/core/providers/call_minutes_provider.dart';
import 'package:code_structure/core/providers/call_provider.dart';
import 'package:code_structure/ui/screens/call/audio_call_screen.dart';
import 'package:code_structure/ui/screens/call/video_call_screen.dart';
import 'package:code_structure/ui/screens/checkout/cart_screen.dart';
import 'package:code_structure/core/model/app_user.dart';

class DiscoverScreen extends StatelessWidget {
  // final VipService _vipService = VipService();
  final DatabaseServices _databaseServices = DatabaseServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AllUsersProvider>(builder: (context, usersProvider, child) {
      // Show loading indicator if users are being fetched
      // if (usersProvider.state == ViewState.busy) {
      //   return Center(child: CircularProgressIndicator());
      // }

      // if (usersProvider.users.isEmpty) {
      //   return Center(child: CircularProgressIndicator());
      // }

      print(usersProvider.users.length);

      print('buildddd');
      return ChangeNotifierProvider(
        create: (context) => DiscoverSCreenViewModel(usersProvider.users),
        child: Consumer<DiscoverSCreenViewModel>(
          builder: (context, model, child) => Scaffold(
            body: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAssets().discoverBack),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    20.h.verticalSpace,
                    customHeader(
                      heading: 'Discover',
                      headingColor: whiteColor,
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
                      _allUsers(context, model, usersProvider),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, DiscoverSCreenViewModel model) {
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
              'No matches found',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: whiteColor,
              ),
            ),
            10.verticalSpace,
            Text(
              'Try adjusting your filters to see more people',
              style: TextStyle(
                fontSize: 16.sp,
                color: whiteColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            30.verticalSpace,
            ElevatedButton(
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
              child: Text(
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

  _allUsers(BuildContext context, DiscoverSCreenViewModel model,
      AllUsersProvider usersProvider) {
        bool isStripeConnected;
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height * 0.73,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 10,
          left: 10,
          right: 10,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.70,
            width: double.infinity,
            child: model.matchEngine != null
                ? SwipeCards(
                    matchEngine: model.matchEngine!,
                    itemBuilder: (BuildContext context, int index) {
                      return ColorFiltered(
                        colorFilter: index == 0
                            ? ColorFilter.mode(Colors.grey.withOpacity(0.1),
                                BlendMode.multiply)
                            : index == 1
                                ? ColorFilter.mode(
                                    Colors.transparent, BlendMode.multiply)
                                : ColorFilter.mode(
                                    Colors.grey.withOpacity(0.14),
                                    BlendMode.multiply),
                        child: CustomDiscoverWIdget(
                          appUser: model.filteredUsers[index],
                          onRewindTap: () async {
                            // final canRewind = await _vipService.canRewind();
                            // if (canRewind) {
                            model.matchEngine?.rewindMatch();
                            //   await _vipService.incrementRewindCount();
                            // } else {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(
                            //       content: Text(
                            //           'Upgrade to VIP for unlimited rewinds!'),
                            //       action: SnackBarAction(
                            //         label: 'Upgrade',
                            //         onPressed: () {
                            //           Navigator.push(
                            //             context,
                            //             MaterialPageRoute(
                            //               builder: (context) =>
                            //                   const FreeVIPScreen(),
                            //             ),
                            //           );
                            //         },
                            //       ),
                            //     ),
                            //   );
                            // }
                          },
                          onAudioCallTap: () async {
                            _checkAndStartCall(
                                context, 'audio', model.filteredUsers[index]);
                          },
                          onVideoCallTap: () async {
                            _checkAndStartCall(
                                context, 'video', model.filteredUsers[index]);
                          },
                          onSuperLikeTap: () async {
                            // final canSuperlike =
                            //     await _vipService.canSuperlike();
                            // if (canSuperlike) {
                            model.matchEngine?.currentItem?.superLike();
                            _databaseServices.giveSuperLike(
                              _auth.currentUser!.uid,
                              model.filteredUsers[index].uid!,
                            );
                            //   await _vipService.incrementSuperlikeCount();
                            // } else {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(
                            //       content: Text(
                            //           'Upgrade to VIP for more superlikes!'),
                            //       action: SnackBarAction(
                            //         label: 'Upgrade',
                            //         onPressed: () {
                            //           Navigator.push(
                            //             context,
                            //             MaterialPageRoute(
                            //               builder: (context) =>
                            //                   const FreeVIPScreen(),
                            //             ),
                            //           );
                            //         },
                            //       ),
                            //     ),
                            //   );
                            // }
                          },
                        ),
                      );
                    },
                    onStackFinished: () {
                      model.resetCards(usersProvider.users);
                    },
                    itemChanged: (SwipeItem item, int index) {
                      // Handle item change if needed
                    },
                    upSwipeAllowed: true,
                    leftSwipeAllowed: true,
                    rightSwipeAllowed: true,
                    fillSpace: false,
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
   
      ],
    );
  }

  Future<void> _checkAndStartCall(
      BuildContext context, String callType, AppUser otherUser) async {
    final callMinutesProvider =
        Provider.of<CallMinutesProvider>(context, listen: false);

    // Check if user has enough minutes (minimum 1 minute required)
    final hasEnoughMinutes =
        await callMinutesProvider.hasEnoughMinutes(callType, 1);
  final hasStripe = await callMinutesProvider.hasStripeAccount(otherUser.uid.toString());
  
  if (!hasStripe) {
    // Receiver doesn't have Stripe connected - show dialog
     
    // Send notification to receiver to setup Stripe
  
 
    await _showReceiverStripeRequiredDialog(context, otherUser);
    return;
  }
    if (hasEnoughMinutes) {
      // User has enough minutes, proceed with the call
      final callProvider = context.read<CallProvider>();
      await callProvider.startCall(
        callerId: _auth.currentUser!.uid,
        callerName: _auth.currentUser!.displayName ?? 'Unknown',
        receiverId: otherUser.uid!,
        receiverName: otherUser.userName ?? 'Unknown',
        receiverFcmToken: otherUser.fcmToken ?? '',
        callType: callType,
      );

      // Get the current call from the provider
      final call = callProvider.currentCall;
      if (call != null) {
        // Navigate to the appropriate call screen based on call type
        if (callType == 'video') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCallScreen(
                call: call,
                onCallEnd: (duration) async {
                  // Record the actual minutes used when call ends
                  final minutesUsed = (duration.inSeconds / 60).ceil();
                  await callMinutesProvider.recordUsedMinutes(
                    callType,
                    minutesUsed,
                  );
                },
              ),
            ),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioCallScreen(
                call: call,
                onCallEnd: (duration) async {
                  // Record the actual minutes used when call ends
                  final minutesUsed = (duration.inSeconds / 60).ceil();
                  await callMinutesProvider.recordUsedMinutes(
                    callType,
                    minutesUsed,
                  );
                },
              ),
            ),
          );
        }
      }
    } else {
      // User doesn't have enough minutes, show purchase dialog
      _showPurchaseDialog(context, callType);
    }
  }
Future<void> _showReceiverStripeRequiredDialog(BuildContext context, AppUser otherUser) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: ListTile(
  contentPadding: EdgeInsets.zero,
  leading: Icon(Icons.warning_amber_rounded, color: Colors.amber[800]),
  title: Text(
    'Payment Setup Required',
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  ),
),
      content: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: '${otherUser.userName} ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: 'needs to set up a Stripe payment account before you can call them.\n\n'
                  'To receive calls, users must connect to Stripe from their profile.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
  // Show dialog to inform user they need to purchase more minutes
  void _showPurchaseDialog(BuildContext context, String callType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Insufficient Minutes'),
        content: Text(
            'You don\'t have enough ${callType.toLowerCase()} call minutes. Would you like to purchase more?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to cart/purchase screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(),
                ),
              );
            },
            child: Text('Buy Minutes'),
          ),
        ],
      ),
    );
  }
}
