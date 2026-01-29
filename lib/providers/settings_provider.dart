import 'package:flutter/material.dart';
import 'package:chess_park/services/firestore_services.dart';
import 'package:chess_park/chess/export.dart';

class SettingsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String _boardThemeName = 'brown';
  String _pieceSetName = 'cburnett';
  bool _enablePremove = true;

  String get boardThemeName => _boardThemeName;
  String get pieceSetName => _pieceSetName;
  bool get enablePremove => _enablePremove;


  static final Map<String, ChessboardColorScheme> boardThemeMap = {
    'metal': ChessboardColorScheme.metal,
    'olive': ChessboardColorScheme.olive,
    'wood': ChessboardColorScheme.wood,

  };


  static final Map<String, PieceSet> pieceSetMap = {
    'cburnett': PieceSet.cburnett,
    'merida': PieceSet.merida,
    'fantasy': PieceSet.fantasy,


  };

  ChessboardColorScheme get currentBoardTheme => boardThemeMap[_boardThemeName] ?? ChessboardColorScheme.brown;
  PieceAssets get currentPieceAssets => (pieceSetMap[_pieceSetName] ?? PieceSet.cburnett).assets;

  bool _isLoading = false;
  bool _isLoaded = false;

  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  Future<void> loadSettings(String userId) async {
    if (_isLoaded || _isLoading) return;

    _isLoading = true;

    try {
      final prefs = await _firestoreService.getUserPreferences(userId);
      if (prefs != null) {
        _boardThemeName = prefs['boardTheme'] ?? 'brown';
        _pieceSetName = prefs['pieceSet'] ?? 'cburnett';

        if (prefs['enablePremove'] is bool) {
          _enablePremove = prefs['enablePremove'];
        } else {

          _enablePremove = true;
        }
      } else {

        _boardThemeName = 'brown';
        _pieceSetName = 'cburnett';
        _enablePremove = true;
      }
      _isLoaded = true;
    } catch (e) {
      debugPrint("Error loading settings: $e");
      _isLoaded = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void unloadSettings() {
    _isLoaded = false;
    _isLoading = false;
    _boardThemeName = 'brown';
    _pieceSetName = 'cburnett';
    _enablePremove = true;
  }


  Future<void> updateSetting(String userId, String key, dynamic value) async {
    if (key == 'boardTheme' && value is String) {
      _boardThemeName = value;
    } else if (key == 'pieceSet' && value is String) {
      _pieceSetName = value;
    } else if (key == 'enablePremove' && value is bool) {
      _enablePremove = value;
    }

    notifyListeners();


    await _firestoreService.updateUserPreferences(userId, {key: value});
  }
}