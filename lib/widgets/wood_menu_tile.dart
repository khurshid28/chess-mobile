import 'package:flutter/material.dart';
import 'package:chess_park/theme/wood_borders.dart';
import 'package:chess_park/theme/wood_colors.dart';
import 'package:chess_park/theme/wood_text_styles.dart';

/// Classic wooden chess design system — menu list tile.
///
/// Used on the home screen for entries such as:
///   • Online Game
///   • Play vs Bot
///   • Daily Puzzle
///   • 100 Puzzles
///   • Play with Friends
///
/// Layout: [goldIcon]  [label]  [→]
///
/// ```dart
/// WoodMenuTile(
///   icon: AppIcons.onlineGame,
///   label: 'Online Game',
///   onTap: () {},
/// )
/// ```
class WoodMenuTile extends StatefulWidget {
  const WoodMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  /// Optional custom trailing widget. Defaults to a gold chevron arrow.
  final Widget? trailing;

  final bool showDivider;

  @override
  State<WoodMenuTile> createState() => _WoodMenuTileState();
}

class _WoodMenuTileState extends State<WoodMenuTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _hovered = true),
          onTapUp: (_)   => setState(() => _hovered = false),
          onTapCancel: ()=> setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: _hovered
                ? WoodColors.rowHover
                : Colors.transparent,
            child: Row(
              children: [
                // Gold icon with a subtle shadow
                _GoldIcon(icon: widget.icon),
                const SizedBox(width: 14),

                // Label + optional subtitle
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label, style: WoodTextStyles.menuLabel),
                      if (widget.subtitle != null)
                        Text(widget.subtitle!, style: WoodTextStyles.caption),
                    ],
                  ),
                ),

                // Trailing — default chevron arrow
                widget.trailing ??
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: WoodColors.gold,
                      size: 22,
                    ),
              ],
            ),
          ),
        ),

        // Carved hairline divider
        if (widget.showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 52),
            color: WoodColors.divider,
          ),
      ],
    );
  }
}

/// A list of [WoodMenuTile]s wrapped in a [WoodMenuList] with a carved border.
class WoodMenuList extends StatelessWidget {
  const WoodMenuList({
    super.key,
    required this.children,
    this.margin,
  });

  final List<WoodMenuTile> children;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: WoodColors.woodMedium.withOpacity(0.6),
        borderRadius: WoodBorders.normalRadius,
        border: WoodBorders.panel,
      ),
      child: ClipRRect(
        borderRadius: WoodBorders.normalRadius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < children.length; i++)
              WoodMenuTile(
                key: children[i].key,
                icon: children[i].icon,
                label: children[i].label,
                subtitle: children[i].subtitle,
                onTap: children[i].onTap,
                trailing: children[i].trailing,
                // no divider after last item
                showDivider: i < children.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Private helpers ─────────────────────────────────────────────────────────

class _GoldIcon extends StatelessWidget {
  const _GoldIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: WoodColors.woodDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WoodColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(1, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(icon, color: WoodColors.gold, size: 20),
    );
  }
}
