import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../providers/auth_provider.dart';
import 'game_screen.dart';

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  int _selectedTimeMinutes = 5;
  bool _isCreatingChallenge = false;
  String? _challengeCode;
  String? _challengeId;
  final _joinCodeController = TextEditingController();
  bool _isJoining = false;

  final List<int> _timeOptions = [3, 5, 10, 15];

  @override
  void dispose() {
    _joinCodeController.dispose();
    // Cancel challenge if leaving without match
    if (_challengeId != null && _challengeCode != null) {
      _cancelChallenge();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Do\'stni taklif qilish',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: _challengeCode != null 
                      ? _buildWaitingView()
                      : _buildCreateOrJoinView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateOrJoinView() {
    return Column(
      children: [
        // Illustration
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.kColorAccent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.people,
            size: 50,
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 20),
        
        const Text(
          'Do\'stingiz bilan 1v1 o\'ynang',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Create challenge section
        GlassPanel(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.green, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Yangi o\'yin yaratish',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Time control
                Text(
                  'Vaqt nazorati',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.kColorTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _timeOptions.map((minutes) => 
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: _buildTimeOption(minutes),
                      ),
                    ),
                  ).toList(),
                ),
                const SizedBox(height: 20),
                
                // Create button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isCreatingChallenge ? null : _createChallenge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isCreatingChallenge
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'O\'yin yaratish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // OR divider
        Row(
          children: [
            Expanded(child: Divider(color: AppTheme.kColorTextSecondary)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'yoki',
                style: TextStyle(color: AppTheme.kColorTextSecondary),
              ),
            ),
            Expanded(child: Divider(color: AppTheme.kColorTextSecondary)),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Join challenge section
        GlassPanel(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.login, color: Colors.blue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Kodga qo\'shilish',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Code input
                TextField(
                  controller: _joinCodeController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'ABCD12',
                    hintStyle: TextStyle(
                      color: AppTheme.kColorTextSecondary.withOpacity(0.5),
                      letterSpacing: 4,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    UpperCaseTextFormatter(),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Join button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isJoining ? null : _joinChallenge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isJoining
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Qo\'shilish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        
        // Waiting animation
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.kColorAccent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
              strokeWidth: 3,
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        const Text(
          'Do\'stingizni kutmoqda...',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        
        Text(
          '$_selectedTimeMinutes daqiqa o\'yin',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.kColorTextSecondary,
          ),
        ),
        const SizedBox(height: 40),
        
        // Challenge code
        GlassPanel(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  'O\'yin kodi',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.kColorTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _challengeCode!,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Copy and Share buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _copyCode,
                        icon: const Icon(Icons.copy),
                        label: const Text('Nusxalash'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _shareCode,
                        icon: const Icon(Icons.share),
                        label: const Text('Ulashish'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Cancel button
        TextButton(
          onPressed: _cancelAndGoBack,
          child: Text(
            'Bekor qilish',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.kColorTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeOption(int minutes) {
    final isSelected = _selectedTimeMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeMinutes = minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.kColorAccent.withOpacity(0.2) 
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.kColorAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '$minutes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppTheme.kColorAccent : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var code = '';
    for (var i = 0; i < 6; i++) {
      code += chars[(random ~/ (i + 1)) % chars.length];
    }
    return code;
  }

  Future<void> _createChallenge() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isCreatingChallenge = true);
    HapticFeedback.lightImpact();

    try {
      final code = _generateCode();
      final authProvider = context.read<AuthProvider>();
      
      final docRef = await FirebaseFirestore.instance.collection('challenges').add({
        'code': code,
        'creatorId': user.uid,
        'creatorName': authProvider.userModel?.displayName ?? 'Unknown',
        'timeControl': _selectedTimeMinutes * 60,
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
      });

      setState(() {
        _challengeCode = code;
        _challengeId = docRef.id;
        _isCreatingChallenge = false;
      });

      // Listen for opponent joining
      _listenForOpponent(docRef.id);
    } catch (e) {
      setState(() => _isCreatingChallenge = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _listenForOpponent(String challengeId) {
    FirebaseFirestore.instance
        .collection('challenges')
        .doc(challengeId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      
      final data = snapshot.data();
      if (data != null && data['status'] == 'matched' && data['gameId'] != null) {
        // Game created! Navigate to game screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => GameScreen(gameId: data['gameId']),
          ),
        );
      }
    });
  }

  Future<void> _joinChallenge() async {
    final code = _joinCodeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('6 xonali kod kiriting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isJoining = true);
    HapticFeedback.lightImpact();

    try {
      // Find challenge by code
      final querySnapshot = await FirebaseFirestore.instance
          .collection('challenges')
          .where('code', isEqualTo: code)
          .where('status', isEqualTo: 'waiting')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() => _isJoining = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('O\'yin topilmadi yoki muddati tugagan'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final challengeDoc = querySnapshot.docs.first;
      final challengeData = challengeDoc.data();
      
      // Can't join your own challenge
      if (challengeData['creatorId'] == user.uid) {
        setState(() => _isJoining = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('O\'zingizning o\'yiningizga qo\'shila olmaysiz'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final authProvider = context.read<AuthProvider>();

      // Create game
      final gameRef = await FirebaseFirestore.instance.collection('games').add({
        'whiteId': challengeData['creatorId'],
        'blackId': user.uid,
        'whiteName': challengeData['creatorName'],
        'blackName': authProvider.userModel?.displayName ?? 'Unknown',
        'timeControl': challengeData['timeControl'],
        'whiteTime': challengeData['timeControl'],
        'blackTime': challengeData['timeControl'],
        'status': 'active',
        'currentFen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'moves': [],
        'turn': 'white',
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'challenge',
      });

      // Update challenge
      await challengeDoc.reference.update({
        'status': 'matched',
        'opponentId': user.uid,
        'gameId': gameRef.id,
        'matchedAt': FieldValue.serverTimestamp(),
      });

      // Navigate to game
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => GameScreen(gameId: gameRef.id),
          ),
        );
      }
    } catch (e) {
      setState(() => _isJoining = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelChallenge() async {
    if (_challengeId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(_challengeId)
          .delete();
    } catch (e) {
      debugPrint('Error canceling challenge: $e');
    }
  }

  void _cancelAndGoBack() {
    _cancelChallenge();
    setState(() {
      _challengeCode = null;
      _challengeId = null;
    });
  }

  void _copyCode() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: _challengeCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Kod nusxalandi!'),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareCode() {
    HapticFeedback.lightImpact();
    Share.share(
      'Chess Park da meni yengishga urinib ko\'ring! 🎯\n\nO\'yin kodi: $_challengeCode\n$_selectedTimeMinutes daqiqa o\'yin',
      subject: 'Chess Park - 1v1 O\'yin',
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
