import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = true;
  bool _isInitialized = false;

  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      final initialResult = await Connectivity().checkConnectivity();
      _updateConnectionStatus(initialResult, notify: false);
    } catch (e) {
      debugPrint("Error checking initial connectivity: $e");
      _isOnline = false;
    }

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result, notify: true);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> result, {bool notify = true}) {
    final hasConnection = result.contains(ConnectivityResult.mobile) ||
                            result.contains(ConnectivityResult.wifi) ||
                            result.contains(ConnectivityResult.ethernet); 

    if (hasConnection != _isOnline) {
      _isOnline = hasConnection;
      if (notify) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
