import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:code_structure/core/services/database_services.dart';

class OnlineStatusService with WidgetsBindingObserver {
  final DatabaseServices _databaseServices = DatabaseServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    // Set user as online when service initializes
    _updateOnlineStatus(true);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Set user as offline when service disposes
    _updateOnlineStatus(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_auth.currentUser == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _updateOnlineStatus(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _updateOnlineStatus(false);
        break;
      default:
        break;
    }
  }

  void _updateOnlineStatus(bool isOnline) {
    if (_auth.currentUser != null) {
      _databaseServices.updateUserOnlineStatus(
          _auth.currentUser!.uid, isOnline);
    }
  }
}
