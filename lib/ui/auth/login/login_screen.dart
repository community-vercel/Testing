// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _auth = FirebaseAuth.instance;

//   Future<void> register() async {
//     try {
//       await _auth.createUserWithEmailAndPassword(
//           email: emailController.text, password: passwordController.text);
//     } catch (e) {
//       print("SignIn failed: $e");
//     }
//   }

//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   final _fromKey = GlobalKey<FormState>();
//   final RegExp _emailRegex = RegExp(
//     r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
//   );
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(),
//       ),
//     );
//   }
// }
