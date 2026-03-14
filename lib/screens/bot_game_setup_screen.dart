import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dartchess/dartchess.dart';
import '../models/bot_personality_model.dart';
import '../providers/bot_game_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_panel.dart';
import '../theme/app_theme.dart';
import '../services/logger_service.dart';
import 'game_screen.dart';

class BotGameSetupScreen extends StatefulWidget {
  final BotPersonality bot;

  const BotGameSetupScreen({super.key, required this.bot});

  @override
  State<BotGameSetupScreen> createState() => _BotGameSetupScreenState();
}

class _BotGameSetupScreenState extends State<BotGameSetupScreen> {
  int _selectedTimeMinutes = 10;
  Side? _selectedSide;

  Color _getRatingColor(int rating) {
    return AppTheme.getRatingColor(rating);
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
                      'Game Setup',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Bot info card
                      GlassPanel(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Bot avatar
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: _getRatingColor(widget.bot.rating).withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getRatingColor(widget.bot.rating),
                                    width: 3,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.bot.avatar,
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Bot name
                              Text(
                                widget.bot.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Rating badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getRatingColor(widget.bot.rating).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getRatingColor(widget.bot.rating).withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 18,
                                      color: _getRatingColor(widget.bot.rating),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${widget.bot.rating}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _getRatingColor(widget.bot.rating),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.bot.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.kColorTextSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Color selection
                      Text(
                        'Play as:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.kColorTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildSideButton(Side.white, 'White')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSideButton(null, 'Random')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSideButton(Side.black, 'Black')),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Time control
                      Text(
                        'Time Control:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.kColorTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildTimeButton(1),
                          _buildTimeButton(3),
                          _buildTimeButton(5),
                          _buildTimeButton(10),
                          _buildTimeButton(15),
                          _buildTimeButton(30),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Start game button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _startGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.kColorAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow_rounded, size: 28),
                              const SizedBox(width: 8),
                              const Text(
                                'START GAME',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideButton(Side? side, String label) {
    final isSelected = _selectedSide == side;

    return GestureDetector(
      onTap: () => setState(() => _selectedSide = side),
      child: GlassPanel(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.kColorAccent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: side == Side.white 
                      ? Colors.white 
                      : (side == Side.black ? AppTheme.kBgColor1 : null),
                  border: Border.all(color: AppTheme.kBorderColor, width: 2),
                ),
                child: side == null 
                    ? Icon(Icons.shuffle, color: AppTheme.kColorTextSecondary, size: 20) 
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.kColorAccent : AppTheme.kColorTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(int minutes) {
    final isSelected = _selectedTimeMinutes == minutes;

    return GestureDetector(
      onTap: () => setState(() => _selectedTimeMinutes = minutes),
      child: Container(
        width: 70,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.kColorAccent.withOpacity(0.2)
              : AppTheme.kColorAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.kColorAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$minutes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.kColorAccent : AppTheme.kColorTextPrimary,
              ),
            ),
            Text(
              'min',
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.kColorAccent : AppTheme.kColorTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startGame() async {
    final provider = context.read<BotGameProvider>();
    final authProvider = context.read<AuthProvider>();
    
    AppLogger().info('🎮 Starting bot game from setup screen');
    
    // Check if user is logged in
    if (authProvider.userModel == null) {
      AppLogger().warning('⚠️ User not logged in');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in first')),
        );
      }
      return;
    }
    
    AppLogger().debug('Creating bot game: ${widget.bot.name}, rating: ${widget.bot.rating}');
    
    await provider.createBotGame(
      bot: widget.bot,
      timeControl: _selectedTimeMinutes * 60,
      userSide: _selectedSide,
      userId: authProvider.userModel!.id,
    );

    AppLogger().info('✅ Bot game created, navigating to GameScreen');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen(isBotGame: true)),
      );
      
      AppLogger().debug('Navigation completed to GameScreen');
    }
  }
}
