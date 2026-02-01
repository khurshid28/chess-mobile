import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dartchess/dartchess.dart';
import '../models/bot_personality_model.dart';
import '../providers/bot_game_provider.dart';
import '../widgets/glass_panel.dart';
import 'game_screen.dart';

class BotDifficultyScreen extends StatefulWidget {
  final BotPersonality bot;

  const BotDifficultyScreen({super.key, required this.bot});

  @override
  State<BotDifficultyScreen> createState() => _BotDifficultyScreenState();
}

class _BotDifficultyScreenState extends State<BotDifficultyScreen> {
  String? _selectedDifficulty;
  int _selectedTimeMinutes = 3;
  Side? _selectedSide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.bot.avatar),
            const SizedBox(width: 8),
            Text(widget.bot.nameUz),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bot description
              GlassPanel(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.bot.description,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Difficulty selection
              const Text(
                'Qiyinlik darajasi:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _buildDifficultyButton('easy', widget.bot.easy, '😊', 'OSON'),
              _buildDifficultyButton(
                'medium',
                widget.bot.medium,
                '😐',
                'O\'RTACHA',
              ),
              _buildDifficultyButton('hard', widget.bot.hard, '😠', 'QIYIN'),
              _buildDifficultyButton(
                'maximum',
                widget.bot.maximum,
                '😈',
                'MAKSIMAL',
              ),

              const SizedBox(height: 24),

              // Side selection
              const Text(
                'Rangni tanlang:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSideButton(
                      Side.white,
                      'Oq',
                      Icons.circle_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSideButton(null, 'Tasodifiy', Icons.shuffle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSideButton(Side.black, 'Qora', Icons.circle),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Time control
              const Text(
                'Vaqt kontroli:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeButton(1),
                  _buildTimeButton(3),
                  _buildTimeButton(5),
                  _buildTimeButton(10),
                ],
              ),

              const SizedBox(height: 24),

              // Start game button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedDifficulty != null ? _startGame : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'O\'YINNI BOSHLASH',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    String level,
    BotDifficulty difficulty,
    String emoji,
    String label,
  ) {
    final isSelected = _selectedDifficulty == level;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => setState(() => _selectedDifficulty = level),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.2)
                : theme.colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rating: ${difficulty.minRating}-${difficulty.maxRating}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideButton(Side? side, String label, IconData icon) {
    final isSelected = _selectedSide == side;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _selectedSide = side),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : null,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(int minutes) {
    final isSelected = _selectedTimeMinutes == minutes;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _selectedTimeMinutes = minutes),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$minutes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
            Text(
              'min',
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startGame() async {
    if (_selectedDifficulty == null) return;

    final provider = context.read<BotGameProvider>();
    await provider.createBotGame(
      bot: widget.bot,
      difficulty: _selectedDifficulty!,
      timeControl: _selectedTimeMinutes * 60,
      userSide: _selectedSide,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GameScreen(isBotGame: true)),
      );
    }
  }
}
