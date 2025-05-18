import 'package:code_structure/core/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:code_structure/core/model/call_minutes.dart';
import 'package:code_structure/core/model/transaction.dart';
import 'package:code_structure/core/services/call_minutes_service.dart';

class CallMinutesProvider extends ChangeNotifier {
  final CallMinutesService _callMinutesService = CallMinutesService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CallMinutes _callMinutes = CallMinutes();
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  CallMinutes get callMinutes => _callMinutes;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  String? get userId => _auth.currentUser?.uid;
  final DatabaseServices _databaseServices = DatabaseServices();

  // Initialize and load user data
  Future<void> initialize() async {
    if (userId == null) return;

    _setLoading(true);
    await _loadCallMinutes();
    _setLoading(false);

    // Set up transaction listener
    _listenToTransactions();
  }

  // Load call minutes data
  Future<void> _loadCallMinutes() async {
    try {
      if (userId == null) return;

      final minutes = await _callMinutesService.getCallMinutes(userId!);
      _callMinutes = minutes;
      notifyListeners();
    } catch (e) {
      print('Error loading call minutes: $e');
    }
  }

  // Set up transaction history listener
  void _listenToTransactions() {
    if (userId == null) return;

    _callMinutesService.getUserTransactions(userId!).listen((transactions) {
      _transactions = transactions;
      notifyListeners();
    });
  }

  // Check if user has enough minutes for a call
  Future<bool> hasEnoughMinutes(String callType, int minutes) async {
    if (userId == null) return false;

    return await _callMinutesService.hasEnoughMinutes(
        userId!, callType, minutes);
  }
   Future<bool> hasStripeAccount(String userId) async {
  final stripeId = await _databaseServices.getSellerStripeId(userId);
  return stripeId != null && stripeId.isNotEmpty;
}

  // Record used minutes after a call
  Future<void> recordUsedMinutes(String callType, int minutes) async {
    if (userId == null) return;

    await _callMinutesService.recordUsedMinutes(userId!, callType, minutes);
    await _loadCallMinutes(); // Reload minutes after update
  }

  // Reload call minutes (useful after purchases)
  Future<void> refreshCallMinutes() async {
    await _loadCallMinutes();
  }

  // Helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
