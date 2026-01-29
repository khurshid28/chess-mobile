import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class ServerTimeProvider with ChangeNotifier {
  Duration _offset = Duration.zero;
  bool _isInitialized = false;

  Duration get offset => _offset;
  bool get isInitialized => _isInitialized;
  DateTime get serverNow => DateTime.now().add(_offset);
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final docRef = FirebaseFirestore.instance.collection('timeSync').doc('syncCheck');

      final DateTime clientStartTime = DateTime.now();
      await docRef.set({'timestamp': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      final snapshot = await docRef.get();
      final DateTime clientEndTime = DateTime.now();

      if (snapshot.exists && snapshot.data() != null) {
        final Timestamp? serverTimestamp = snapshot.data()!['timestamp'];
        if (serverTimestamp == null) {
           debugPrint("Server timestamp is null after write. Using local time.");
           _isInitialized = true;
           notifyListeners();
           return;
        }

        final DateTime serverTime = serverTimestamp.toDate();
        final Duration latency = clientEndTime.difference(clientStartTime) ~/ 2;
        final DateTime estimatedServerNow = serverTime.add(latency);
        _offset = estimatedServerNow.difference(DateTime.now());
        _isInitialized = true;
        notifyListeners();
        debugPrint("Server time offset calculated: ${_offset.inMilliseconds}ms");
      }
    } catch (e) {
      debugPrint("Error calculating server time offset: $e. Falling back to local time.");
      _isInitialized = true;
      notifyListeners();
    }
  }
}