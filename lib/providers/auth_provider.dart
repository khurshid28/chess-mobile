import 'dart:async';
import 'dart:io';
import 'package:chess_park/providers/settings_provider.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chess_park/models/user_model.dart';
import 'package:image_picker/image_picker.dart';

enum AuthState { loading, unauthenticated, emailNotVerified, authenticated }

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();
  final SettingsProvider _settingsProvider;

  User? _firebaseUser;
  UserModel? _userModel;
  StreamSubscription? _userSubscription;
  StreamSubscription<User?>? _authSubscription;

  AuthState _authState = AuthState.loading;

  bool _isDisposed = false;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  AuthState get authState => _authState;

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  AuthProvider({required SettingsProvider settingsProvider})
    : _settingsProvider = settingsProvider {
    _authSubscription = _auth.authStateChanges().listen(
      (user) async {
        if (_isDisposed) return;
        await _onAuthStateChanged(user);
      },
      onError: (error) {
        if (_isDisposed) return;
        debugPrint("Auth State Stream Error: $error");
        _handleSignOutCleanup();
        _authState = AuthState.unauthenticated;
        _safeNotifyListeners();
      },
    );
  }
  Future<String?> updateCountry(String? countryCode) async {
    if (_firebaseUser == null) return "User not logged in.";
    try {
      await _firestoreService.updateUserCountryCode(
        _firebaseUser!.uid,
        countryCode,
      );

      return null;
    } catch (e) {
      debugPrint("Failed to update country: $e");
      return "Failed to update country. Please try again.";
    }
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (_isDisposed) return;

    if (_firebaseUser?.uid != user?.uid) {
      _handleSignOutCleanup();
    }

    _firebaseUser = user;

    if (user != null) {
      try {
        await user.reload();
        if (_isDisposed) return;
        _firebaseUser = _auth.currentUser;
      } catch (e) {
        debugPrint("Error reloading user: $e. Signing out.");
        await _auth.signOut();
        return;
      }

      if (_isDisposed) return;

      if (_firebaseUser == null) return;

      if (_firebaseUser!.emailVerified) {
        await _setAuthenticatedState(user.uid);
      } else {
        _userModel = null;
        _authState = AuthState.emailNotVerified;
        _safeNotifyListeners();
      }
    } else {
      _handleSignOutCleanup();
      _authState = AuthState.unauthenticated;
      _safeNotifyListeners();
    }
  }

  void _handleSignOutCleanup() {
    if (_userSubscription != null ||
        _userModel != null ||
        _settingsProvider.isLoaded) {
      _userSubscription?.cancel();
      _userSubscription = null;
      _userModel = null;
      _settingsProvider.unloadSettings();
    }
  }

  Future<void> _setAuthenticatedState(String uid) async {
    if (_isDisposed) return;

    if (_authState == AuthState.authenticated && _userModel?.id == uid) {
      return;
    }

    if (_authState != AuthState.loading) {
      _authState = AuthState.loading;
      _safeNotifyListeners();
    }

    await _settingsProvider.loadSettings(uid);
    if (_isDisposed) return;

    final Completer<void> userDataLoaded = Completer();

    _userSubscription?.cancel();

    _userSubscription = _firestoreService
        .getUserStream(uid)
        .listen(
          (snapshot) {
            if (_isDisposed) return;

            if (snapshot.exists && snapshot.data() != null) {
              _userModel = UserModel.fromMap(
                snapshot.data() as Map<String, dynamic>,
                snapshot.id,
              );

              if (!userDataLoaded.isCompleted) {
                userDataLoaded.complete();
              }

              if (_settingsProvider.isLoaded) {
                _authState = AuthState.authenticated;
              }

              if (_authState == AuthState.authenticated) {
                _safeNotifyListeners();
              }
            } else {
              debugPrint(
                "CRITICAL ERROR: Authenticated user but user document missing ($uid).",
              );
              _userModel = null;
              if (!userDataLoaded.isCompleted) {
                userDataLoaded.completeError("User document not found.");
              }
              _auth.signOut();
            }
          },
          onError: (error) {
            if (_isDisposed) return;
            debugPrint("Error in user stream: $error");
            if (!userDataLoaded.isCompleted) {
              userDataLoaded.completeError(error);
            }
            _auth.signOut();
          },
        );

    try {
      await userDataLoaded.future.timeout(const Duration(seconds: 15));
      if (_isDisposed) return;

      if (_settingsProvider.isLoaded &&
          _userModel != null &&
          _authState != AuthState.authenticated) {
        _authState = AuthState.authenticated;
        _safeNotifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to set authenticated state during initial load: $e");
      await _auth.signOut();
    }
  }

  Future<void> refreshUser() async {
    if (_isDisposed) return;
    await _firebaseUser?.reload();
    _firebaseUser = _auth.currentUser;
    await _onAuthStateChanged(_firebaseUser);
  }

  Future<String?> signUp(
    String email,
    String password,
    String displayName,
    String? countryCode,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.sendEmailVerification();

      await userCredential.user?.updateDisplayName(displayName);

      try {
        await _firestoreService.createUser(
          userCredential.user!.uid,
          email,
          displayName,
          countryCode,
        );
      } catch (e) {
        debugPrint(
          "Failed to create user document: $e. Rolling back auth creation.",
        );
        await userCredential.user?.delete();
        return "Failed to create profile. Please try again.";
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred during sign-in.";
    }
  }

  Future<void> signOut() async {
    _handleSignOutCleanup();
    _authState = AuthState.unauthenticated;
    _safeNotifyListeners();

    await _auth.signOut();
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> updateUserProfileImage() async {
    if (_firebaseUser == null) return "User not logged in.";

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (image == null) return null;

      final File imageFile = File(image.path);

      final imageUrl = await _firestoreService.uploadProfileImage(
        _firebaseUser!.uid,
        imageFile,
      );

      await _firestoreService.updateUserProfileImage(
        _firebaseUser!.uid,
        imageUrl,
      );
      return null;
    } catch (e) {
      return "Failed to upload image. Please try again.";
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
