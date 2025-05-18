import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/core/models/call.dart';
import 'package:code_structure/core/services/call_service.dart';
import 'package:code_structure/core/services/database_services.dart';
import 'package:code_structure/core/services/stripe_service.dart';
import 'package:code_structure/ui/screens/checkout/custom/custom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class IncomingCallScreen extends StatefulWidget {
  final Call call;

  const IncomingCallScreen({
    super.key,
    required this.call,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  bool _isCheckingStripe = true;
  bool _hasStripeAccount = false;
  bool _isOnboardingInProgress = false;

  @override
  void initState() {
    super.initState();
    _checkStripeAccount();
  }

  Future<void> _checkStripeAccount() async {
    try {
      final databaseServices = DatabaseServices();
      final userDoc = await databaseServices.getUserData(FirebaseAuth.instance.currentUser!.uid);
      final stripeId = userDoc['sellerStripeId'] as String?;
      
      if (mounted) {
        setState(() {
          _hasStripeAccount = stripeId != null && stripeId.isNotEmpty;
          _isCheckingStripe = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking receiver Stripe account: $e');
      if (mounted) {
        setState(() {
          _isCheckingStripe = false;
        });
      }
    }
  }

  Future<void> _startStripeOnboarding() async {
    if (_isOnboardingInProgress) return;
    
    setState(() {
      _isOnboardingInProgress = true;
    });

    try {
      final stripeService = StripeService();
      final databaseServices = DatabaseServices();
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final email = FirebaseAuth.instance.currentUser!.email ?? '';

      // Create Stripe Connect account
      final connectAccount = await stripeService.createConnectAccount(email);
      final sellerStripeId = connectAccount['id'];

      // Create onboarding link
      final onboardingUrl = await stripeService.createAccountLink(accountId: sellerStripeId);

      // Navigate to custom web view for onboarding
      final onboardingResult = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => CustomWebView(
            url: onboardingUrl,
            onTopUpSuccess: (response) {
              // Save Stripe ID to Firestore
              databaseServices.updateSellerStripeIds(userId, sellerStripeId);
              return true;
            },
            onTopUpFailure: (response) {
              return false;
            },
          ),
        ),
      );

      if (onboardingResult == true) {
        // Re-check Stripe account status after onboarding
        await _checkStripeAccount();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment account setup complete!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment setup not completed')),
        );
      }
    } catch (e) {
      debugPrint('Stripe connect error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to setup payments: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOnboardingInProgress = false;
        });
      }
    }
  }

  void _handleAcceptCall() {
    if (!_hasStripeAccount) {
      _showStripeRequiredDialog();
      return;
    }

    // Proceed with call acceptance
    context.read<CallService>().handleAnswerCall(CallEvent(
          uuid: widget.call.callId,
          callerName: widget.call.callerName,
          handle: widget.call.callerId,
          hasVideo: widget.call.callType == 'video',
          extra: <String, dynamic>{
            'callerId': widget.call.callerId,
            'callType': widget.call.callType,
          },
        ));
  }

  Future<void> _showStripeRequiredDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Setup Required'),
        content: const Text(
            'You need to connect a payment account to receive payments for calls.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Reject Call'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Setup Now'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _startStripeOnboarding();
      // After onboarding, check if we can now accept the call
      if (_hasStripeAccount) {
        _handleAcceptCall();
      }
    } else {
      _handleRejectCall();
    }
  }

  void _handleRejectCall() {
    context.read<CallService>().rejectCurrentCall();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingStripe) {
      return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 20.h),
              Text(
                'Verifying payment account...',
                style: style14.copyWith(color: subheadingColor2),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasStripeAccount) {
      return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80.r,
                backgroundImage: AssetImage(AppAssets().pic),
              ),
              SizedBox(height: 24.h),
              Text(
                widget.call.callerName,
                style: style17.copyWith(
                  color: headingColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Incoming ${widget.call.callType} call...',
                style: style14.copyWith(
                  color: subheadingColor2,
                ),
              ),
              SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'You need to setup a payment account to receive calls and get paid',
                  style: style14.copyWith(color: subheadingColor2),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30.h),
              if (_isOnboardingInProgress)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _startStripeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrimarybuttonColor,
                    padding: EdgeInsets.symmetric(
                        horizontal: 30.w, vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Setup Payment Account',
                    style: style14.copyWith(color: whiteColor),
                  ),
                ),
              SizedBox(height: 15.h),
              TextButton(
                onPressed: _handleRejectCall,
                child: Text(
                  'Reject Call',
                  style: style14.copyWith(color: SecondarybuttonColor),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 100.r,
                    backgroundImage: AssetImage(AppAssets().pic),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    widget.call.callerName,
                    style: style17.copyWith(
                      color: headingColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Incoming ${widget.call.callType} call...',
                    style: style14.copyWith(
                      color: subheadingColor2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 30.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallButton(
                    icon: Icons.call_end,
                    color: SecondarybuttonColor,
                    onPressed: _handleRejectCall,
                  ),
                  _buildCallButton(
                    icon: Icons.call,
                    color: PrimarybuttonColor,
                    onPressed: _handleAcceptCall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: whiteColor,
          size: 30.sp,
        ),
      ),
    );
  }
}