import 'package:code_structure/core/providers/all_users_provider.dart';
import 'package:code_structure/core/providers/call_minutes_provider.dart';
import 'package:code_structure/core/providers/call_provider.dart';
import 'package:code_structure/core/providers/user_provider.dart';
import 'package:code_structure/firebase_options.dart';
import 'package:code_structure/ui/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:code_structure/core/services/online_status_service.dart';
import 'package:code_structure/core/services/call_service.dart';
import 'package:code_structure/core/services/stripe_service.dart';

// class RouteGenerator {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case '/':
//         return MaterialPageRoute(builder: (_) => DiscoverScreen());
//       default:
//         return MaterialPageRoute(builder: (_) => DiscoverScreen());
//     }
//   }
// }

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Stripe.publishableKey =
      'pk_test_51AfCnUJe629jCerG7NnU9oPBuXIx5L3HSN4frG4Zr0rwZY1NSVoKsIATdwzabHOESGHJX8xjXi3YeECrbUwsfIUQ00ct31yWNx';
  Stripe.merchantIdentifier = 'merchant.com.your.app';

  await Stripe.instance.applySettings();

  // Initialize Stripe
  await StripeService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final OnlineStatusService _onlineStatusService = OnlineStatusService();
  late CallService _callService;

  @override
  void initState() {
    super.initState();
    _onlineStatusService.initialize();
    _callService = CallService(navigatorKey: navigatorKey);
    _callService.initialize();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _onlineStatusService.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check for active calls when app is resumed from background
      _callService.checkAndNavigateToCallScreen();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(394, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AllUsersProvider(),
            lazy: true,
          ),
          ChangeNotifierProvider(
            create: (context) => UserProvider(),
            lazy: true,
          ),
          ChangeNotifierProvider(
            create: (context) => CallProvider(_callService),
            lazy: false,
          ),
          ChangeNotifierProvider(
            create: (context) => CallMinutesProvider()..initialize(),
            lazy: false,
          ),
        ],
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Talksy',
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xffFAF8F6),
          ),
          navigatorKey: navigatorKey,
          // initialRoute: '/',
          // onGenerateRoute: RouteGenerator.generateRoute,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
