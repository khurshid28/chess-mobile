import 'package:flutter/material.dart';
import 'package:chess_park/theme/wood_borders.dart';
import 'package:chess_park/theme/wood_colors.dart';
import 'package:chess_park/theme/wood_text_styles.dart';

/// Classic wooden chess design system — leaderboard row tile.
///
/// Displays rank medal, player avatar/name and ELO rating.
///
/// ```dart
/// WoodLeaderboardTile(
///   rank: 1,
///   name: 'Magnus',
///   rating: 2850,
///   avatarUrl: '...',
/// )
/// ```
class WoodLeaderboardTile extends StatelessWidget {
  const WoodLeaderboardTile({
    super.key,
    required this.rank,
    required this.name,
    required this.rating,
    this.avatarUrl,
    this.avatarPlaceholder,
    this.isCurrentUser = false,
    this.onTap,
  });

  final int rank;
  final String name;
  final int rating;
  final String? avatarUrl;

  /// Fallback widget shown when no avatar URL is provided
  final Widget? avatarPlaceholder;

  /// Highlight this row differently when it belongs to the signed-in user
  final bool isCurrentUser;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? WoodColors.woodLight.withOpacity(0.25)
              : WoodColors.leaderboardRow,
          borderRadius: WoodBorders.smallRadius,
          border: isCurrentUser ? WoodBorders.goldAccent : null,
        ),
        child: Row(
          children: [
            // ── Rank medal ──────────────────────────────────────────────
            SizedBox(
              width: 36,
              child: _RankBadge(rank: rank),
            ),
            const SizedBox(width: 10),

            // ── Avatar ──────────────────────────────────────────────────
            _Avatar(
              url: avatarUrl,
              placeholder: avatarPlaceholder,
              size: 38,
            ),
            const SizedBox(width: 10),

            // ── Name ────────────────────────────────────────────────────
            Expanded(
              child: Text(
                name,
                style: WoodTextStyles.menuLabel.copyWith(fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── ELO Rating ──────────────────────────────────────────────
            Text(rating.toString(), style: WoodTextStyles.rating),
          ],
        ),
      ),
    );
  }
}

// ─── Top-3 podium variant ────────────────────────────────────────────────────

/// Larger highlighted tile for ranks 1-3 at the top.
class WoodLeaderboardPodiumTile extends StatelessWidget {
  const WoodLeaderboardPodiumTile({
    super.key,
    required this.rank,
    required this.name,
    required this.rating,
    this.avatarUrl,
    this.onTap,
  });

  final int rank;
  final String name;
  final int rating;
  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final medalColor = _medalColor(rank);
    final podiumHeight = rank == 1 ? 110.0 : 90.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with medal ring
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              _Avatar(url: avatarUrl, size: rank == 1 ? 60 : 50),
              _MedalDot(color: medalColor, rank: rank),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: WoodTextStyles.caption.copyWith(
              color: WoodColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(rating.toString(), style: WoodTextStyles.rating),

          // Podium block
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: podiumHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [medalColor.withOpacity(0.7), medalColor.withOpacity(0.3)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              border: Border.all(color: medalColor.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: WoodTextStyles.sectionHeading.copyWith(
                  color: medalColor,
                  fontSize: rank == 1 ? 22 : 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _medalColor(int r) {
    switch (r) {
      case 1: return WoodColors.medalGold;
      case 2: return WoodColors.medalSilver;
      default: return WoodColors.medalBronze;
    }
  }
}

// ─── Private helpers ─────────────────────────────────────────────────────────

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    if (rank <= 3) {
      return Icon(
        Icons.workspace_premium_rounded,
        color: _medalColor(rank),
        size: 26,
        shadows: const [Shadow(color: Color(0x80000000), offset: Offset(1, 1), blurRadius: 3)],
      );
    }
    return Text(
      '#$rank',
      style: WoodTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
      textAlign: TextAlign.center,
    );
  }

  Color _medalColor(int r) {
    switch (r) {
      case 1: return WoodColors.medalGold;
      case 2: return WoodColors.medalSilver;
      default: return WoodColors.medalBronze;
    }
  }
}

class _MedalDot extends StatelessWidget {
  const _MedalDot({required this.color, required this.rank});
  final Color color;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: WoodColors.background, width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)],
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, this.placeholder, required this.size});
  final String? url;
  final Widget? placeholder;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget image = url != null && url!.isNotEmpty
        ? CircleAvatar(
            radius: size / 2,
            backgroundImage: NetworkImage(url!),
            backgroundColor: WoodColors.woodDark,
          )
        : CircleAvatar(
            radius: size / 2,
            backgroundColor: WoodColors.woodDark,
            child: placeholder ??
                Icon(Icons.person_rounded, color: WoodColors.gold, size: size * 0.5),
          );

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: WoodColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(1, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: image,
    );
  }
}
