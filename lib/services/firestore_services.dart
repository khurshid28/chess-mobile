import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chess_park/models/user_model.dart';
import 'package:chess_park/models/game_model.dart';
import 'package:flutter/foundation.dart'; 

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createUser(String uid, String email, String displayName, String? countryCode) async {
    final user = UserModel(id: uid, email: email, displayName: displayName, countryCode: countryCode);
    await _db.collection('users').doc(uid).set({
      ...user.toMap(),
      'profileImage': null,
    });
  }
   Future<void> updateUserCountryCode(String uid, String? countryCode) async {
    await _db.collection('users').doc(uid).update({
      'countryCode': countryCode,
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
  
  Future<Map<String, dynamic>?> getUserPreferences(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data()!.containsKey('preferences')) {
      return doc.data()!['preferences'] as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> updateUserPreferences(String uid, Map<String, dynamic> preferences) async {
    await _db.collection('users').doc(uid).set(
      {'preferences': preferences},
      SetOptions(merge: true),
    );
  }

  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }
    
  Future<String> uploadProfileImage(String uid, File image) async {
    final storageRef = _storage.ref().child('user_profiles').child('$uid.jpg');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> updateUserProfileImage(String uid, String imageUrl) async {
    
    await _db.collection('users').doc(uid).update({
      'profileImage': imageUrl,
    });
  }

  

  Stream<DocumentSnapshot> getMatchmakingQueueStream(String uid) {
    return _db.collection('matchmaking_queue').doc(uid).snapshots();
  }

  
  Future<void> deleteMatchmakingQueueEntry(String uid) async {
    
    try {
      await _db.collection('matchmaking_queue').doc(uid).delete();
    } catch (e) {
      debugPrint("Error deleting matchmaking entry for $uid: $e");
      
      rethrow; 
    }
  }

  

  
  

  Stream<DocumentSnapshot<Map<String, dynamic>>> getGameStream(String gameId) {
    return _db.collection('games').doc(gameId).snapshots();
  }

  
  Stream<List<GameModel>> streamLiveHighEloGames({int limit = 10}) {
    
    
    Query query = _db
        .collection('games')
        .where('status', isEqualTo: 'inprogress')
        .orderBy('maxElo', descending: true)
        .limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return GameModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
            } catch (e) {
              
              debugPrint("Error parsing GameModel in live stream: ${doc.id}, Error: $e");
              return null;
            }
          })
          .whereType<GameModel>() 
          
          .where((game) => game.playerWhiteId != null && game.playerBlackId != null)
          .toList();
    });
  }

  Future<List<UserModel>> getTopPlayers() async {
    final snapshot = await _db
        .collection('users')
        .orderBy('elo', descending: true)
        .limit(100)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }
  

  

  Future<List<GameModel>> getUserGames(String userId, {int? limit}) async {

    Query query = _db
        .collection('games')
        .where('participants', arrayContains: userId)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();

    final List<GameModel> games = [];
    for (var doc in snapshot.docs) {
      games.add(GameModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>));
    }

    return games;
  }
}