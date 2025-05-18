import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/providers/user_provider.dart';
import 'package:code_structure/core/services/database_services.dart';
import 'package:code_structure/core/services/stripe_service.dart';
import 'package:code_structure/main.dart';
import 'package:code_structure/ui/screens/checkout/custom/custom.dart';
import 'package:code_structure/ui/screens/edit_profile/edit_profile_screen.dart';
import 'package:code_structure/ui/screens/free_vip/free_vip.dart';
import 'package:code_structure/ui/screens/wallet/wallet_home/wallet_home_screen.dart';
import 'package:code_structure/ui/screens/likes_visits/likes_screen.dart';
import 'package:code_structure/ui/screens/likes_visits/visits_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:code_structure/custom_widgets/vip_feature_wrapper.dart';

class MyProfileScreen extends StatefulWidget {
  MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _auth = FirebaseAuth.instance;
  bool _hasStripeAccount = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkStripeAccount();
  }

  Future<void> _checkStripeAccount() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final hasAccount = await DatabaseServices().hasStripeAccount(userId);
        setState(() {
          _hasStripeAccount = hasAccount;
        });
      }
    } catch (e) {
      debugPrint('Error checking Stripe account: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _connectStripeAccount() async {
  if (!mounted) return;

  setState(() {
    _isLoading = true;
  });

  try {
    final stripeService = StripeService();
    final databaseServices = DatabaseServices();
    final userId = _auth.currentUser?.uid;
    final email = _auth.currentUser?.email ?? '';

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
      return;
    }

    // Create Stripe Connect account
    final connectAccount = await stripeService.createConnectAccount(email);
    final sellerStripeId = connectAccount['id'];

    // Validate sellerStripeId
    if (sellerStripeId == null || sellerStripeId.isEmpty) {
      throw Exception('Failed to retrieve Stripe account ID');
    }

    // Update Firestore with sellerStripeId
    await  databaseServices.updateSellerStripeIds( userId, sellerStripeId);
      setState(() {
        _hasStripeAccount = true;
      });
  if (mounted== true) {
      await _checkStripeAccount();
      setState(() {
        _hasStripeAccount = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment account connected successfully!')),
      );
    }
    // Create onboarding link
    final onboardingUrl = await stripeService.createAccountLink(
      accountId: sellerStripeId,
    );

    // Open onboarding flow
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWebView(
          url: onboardingUrl,
          onTopUpSuccess: (response) {
            // No need to update Firestore again; already done above
            return true;
          },
          onTopUpFailure: (response) => false,
        ),
      ),
    );

    debugPrint("Onboarding success: $success");

    if (mounted && success == true) {
      await _checkStripeAccount();
      setState(() {
        _hasStripeAccount = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment account connected successfully!')),
      );
    }
  } catch (e) {
    debugPrint('Error connecting Stripe account: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect payment account: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

//   Future<void> _connectStripeAccount() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final stripeService = StripeService();
//       final databaseServices = DatabaseServices();
//       final userId = _auth.currentUser?.uid;
//       final email = _auth.currentUser?.email ?? '';

//       if (userId == null) return;

//       // Create Stripe Connect account
//       final connectAccount = await stripeService.createConnectAccount(email);
//       final sellerStripeId = connectAccount['id'];
      

//       // Create onboarding link
//       final onboardingUrl = await stripeService.createAccountLink(
//         accountId: sellerStripeId,
//       );
//                             databaseServices.updateSellerStripeIds(userId, sellerStripeId);



//                 await _checkStripeAccount();
//                  setState(() {
//         _hasStripeAccount = true;
//       });
//  if ( mounted) {
//       setState(() {
//         _hasStripeAccount = true;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Payment account connected successfully!')),
//       );
//     }
//           debugPrint("Sucess url $onboardingUrl");

//       // Open onboarding flow
//       final success = await Navigator.push<bool>(
//         context,
//         MaterialPageRoute(
//           builder: (context) => CustomWebView(
//             url: onboardingUrl,
//             onTopUpSuccess: (response) {
//               databaseServices.updateSellerStripeIds(userId, sellerStripeId);
//               return true;
//             },
//             onTopUpFailure: (response) => false,
//           ),
//         ),
//       );
//       debugPrint("Suesssss $success");

//      if ( mounted) {
//       setState(() {
//         _hasStripeAccount = true;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Payment account connected successfully!')),
//       );
//     }
//   } catch (e) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to connect payment account: $e')),
//       );
//     }
//   } finally {
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }
    
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile Card
                        Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 70,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFF6B8B),
                                      Color(0xFFFF8E53),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: 40.h,
                                left: 16.w,
                                right: 16.w,
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 0),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    color: Color(
                                      0xFF000000,
                                    ).withOpacity(0.0796),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // Profile Picture
                                        Stack(
                                          children: [
                                            Container(
                                              width: 94.w,
                                              height: 94.h,
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                image: DecorationImage(
                                                  image: userProvider.user
                                                              .images?[0] !=
                                                          null
                                                      ? NetworkImage(
                                                          userProvider
                                                              .user.images![0]!,
                                                        )
                                                      : AssetImage(
                                                          AppAssets().pic,
                                                        ),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(50.r),
                                              ),
                                            ),
                                            // if (userProvider.user.isVip ?? false)
                                            //   Positioned(
                                            //     right: 0,
                                            //     bottom: 0,
                                            //     child: Container(
                                            //       width: 25.w,
                                            //       height: 25.h,
                                            //       padding: EdgeInsets.all(3),
                                            //       decoration: BoxDecoration(
                                            //         gradient: LinearGradient(
                                            //           colors: [
                                            //             lightOrangeColor,
                                            //             lightPinkColor,
                                            //           ],
                                            //         ),
                                            //         borderRadius:
                                            //             BorderRadius.circular(
                                            //                 50.r),
                                            //         border: Border.all(
                                            //           color: Colors.white,
                                            //           width: 2.w,
                                            //         ),
                                            //       ),
                                            //       child: Image.asset(
                                            //         AppAssets().crown,
                                            //         scale: 4,
                                            //       ),
                                            //     ),
                                            //   ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        // Name and Location
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    userProvider
                                                            .user.userName ??
                                                        '',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  10.horizontalSpace,
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditProfileScreen(),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.mode_edit_outlined,
                                                      color: lightOrangeColor,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                userProvider.user.address ??
                                                    'No Address',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    _buildDivider(),
                                    // Stats Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
             
          
                                        _buildStatColumn(
                                          'VISITORS',
                                          userProvider.user.visits!.length
                                              .toString(),
                                        ),
                                        _buildStatColumn(
                                          'LIKES',
                                          userProvider.user.likes!.length
                                              .toString(),
                                        ),
                                        _buildStatColumn(
                                          'MATCHES',
                                          userProvider.user.matches!.length
                                              .toString(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
          
                        const SizedBox(height: 16),
                        // Payment Account Section
                        _buildPaymentAccountSection(),

                        const SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 5),
                                blurRadius: 10,
                                spreadRadius: 0,
                                color: Color(0xFF000000).withOpacity(0.0796),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                                            
                              
                              _buildMenuItem(
                                Icons.favorite,
                                'Likes',
                                Colors.red,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          // VipFeatureWrapper(
                                          //   feature: 'see_likes',
                                          //   child:
                                          LikesScreen(),
                                      // ),
                                    ),
                                  );
                                },
                              ),
                              
                              _buildDivider(),
                              _buildMenuItem(
                                Icons.location_on,
                                'Visits',
                                Colors.green,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          // VipFeatureWrapper(
                                          //   feature: 'see_visits',
                                          //   child:
                                          VisitsScreen(),
                                      // ),
                                    ),
                                  );
                                },
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                Icons.group,
                                'Groups',
                                Colors.purple,
                              ),
                            ],
                          ),
                        ), // Menu Items
                        20.verticalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 5),
                                blurRadius: 10,
                                spreadRadius: 0,
                                color: Color(0xFF000000).withOpacity(0.0796),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // _buildMenuItem(
                              //   Icons.account_balance_wallet,
                              //   'My wallet',
                              //   Colors.orange,
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => WalletHomeScreen(),
                              //       ),
                              //     );
                              //   },
                              // ),
                              // _buildDivider(),
                              // _buildMenuItem(
                              //   Icons.verified_user,
                              //   'VIP center',
                              //   Colors.blue,
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => FreeVIPScreen(),
                              //       ),
                              //     );
                              //   },
                              // ),
                              // _buildDivider(),
                              _buildMenuItem(
                                Icons.person_add,
                                'Find friends',
                                Colors.lightGreen,
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                Icons.block,
                                'Blacklist',
                                Colors.grey,
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                Icons.settings,
                                'Settings',
                                Colors.grey,
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                Icons.logout,
                                'Logout',
                                Colors.red,
                                onTap: () {
                                  // Handle logout action
                                  _auth.signOut();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => MyApp(),
                                    ),
                                    (_) => false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        20.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
   Widget _buildPaymentSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _hasStripeAccount
                  ? 'Your payment account is connected'
                  : 'Connect your payment account to receive payments',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            if (!_hasStripeAccount)
              ElevatedButton(
                onPressed: _connectStripeAccount,
                child: Text('Connect Payment Account'),
                style: ElevatedButton.styleFrom(
                ),
              ),
            if (_hasStripeAccount)
              TextButton(
                onPressed: () {
                  // Optionally add "View Account" functionality
                },
                child: Text('View Payment Account'),
              ),
          ],
        ),
      ),
    ); 
   }

  Widget _buildStatColumn(String title, String count) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(color: lightDividerColor);
  }

Widget _buildPaymentAccountSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            blurRadius: 10,
            spreadRadius: 0,
            color: const Color(0xFF000000).withOpacity(0.0796),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            Icons.payment,
            _hasStripeAccount ? 'Payment Account Connected' : 'Connect Payment Account',
            _hasStripeAccount ? Colors.green : Colors.blueAccent,
            onTap: _hasStripeAccount ? null : _connectStripeAccount,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
 Widget _buildMenuItem(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
          leading: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: isLoading
              ? const SizedBox(width: 24, height: 24)
              : const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }
}


