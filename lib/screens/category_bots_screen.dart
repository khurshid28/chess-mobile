import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/bot_category_model.dart';
import '../models/bot_personality_model.dart';
import '../widgets/glass_panel.dart';
import '../theme/app_theme.dart';
import 'bot_difficulty_screen.dart';

class CategoryBotsScreen extends StatelessWidget {
  final BotCategory category;

  const CategoryBotsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate category rating range
    int minRating = 9999;
    int maxRating = 0;
    for (final bot in category.bots) {
      final easy = bot.difficulties['easy'];
      final max = bot.difficulties['maximum'];
      if (easy != null && easy.minRating < minRating) {
        minRating = easy.minRating;
      }
      if (max != null && max.maxRating > maxRating) {
        maxRating = max.maxRating;
      }
    }

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Expanded(
                      child: Text(
                        category.nameUz,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Category info card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: category.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                            fadeOutDuration: const Duration(milliseconds: 100),
                            placeholder: (context, url) => Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.kColorAccent),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey.withOpacity(0.3),
                              child: const Icon(Icons.sports_esports),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.kColorTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.kColorAccent.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${category.botCount} ta bot',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.kColorAccent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$minRating - $maxRating',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bots list header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Botni tanlang:',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.kColorTextSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Bots list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: category.bots.length,
                  itemBuilder: (context, index) {
                    final bot = category.bots[index];
                    return _buildBotListItem(context, bot, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotListItem(BuildContext context, BotPersonality bot, int index) {
    final theme = Theme.of(context);
    final easyRating = bot.difficulties['easy']?.minRating ?? 0;
    final maxRating = bot.difficulties['maximum']?.maxRating ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BotDifficultyScreen(bot: bot),
            ),
          );
        },
        child: GlassPanel(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Bot avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      bot.avatar,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Bot info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bot.nameUz,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bot.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.kColorTextSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Rating range
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '$easyRating - $maxRating',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: AppTheme.kColorTextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
