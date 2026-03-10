import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:chess_park/theme/app_theme.dart';

/// Centralized icon system for the chess app
/// All icons use Lucide Icons for consistency
class AppIcons {
  AppIcons._();

  // ═══════════════════════════════════════════════════════════════════
  // ICON SIZES
  // ═══════════════════════════════════════════════════════════════════
  static const double sizeNavigation = 24.0;
  static const double sizeMenu = 22.0;
  static const double sizeButton = 20.0;
  static const double sizeStatus = 16.0;
  static const double sizeLarge = 32.0;
  static const double sizeXLarge = 48.0;

  // ═══════════════════════════════════════════════════════════════════
  // NAVIGATION ICONS
  // ═══════════════════════════════════════════════════════════════════
  static const IconData home = LucideIcons.home;
  static const IconData homeOutline = LucideIcons.home;
  static const IconData leaderboard = LucideIcons.trophy;
  static const IconData leaderboardOutline = LucideIcons.trophy;
  static const IconData games = LucideIcons.gamepad2;
  static const IconData gamesOutline = LucideIcons.gamepad2;
  static const IconData profile = LucideIcons.user;
  static const IconData profileOutline = LucideIcons.user;
  static const IconData settings = LucideIcons.settings;

  // ═══════════════════════════════════════════════════════════════════
  // MENU ICONS
  // ═══════════════════════════════════════════════════════════════════
  static const IconData onlineGame = LucideIcons.globe;
  static const IconData playBot = LucideIcons.bot;
  static const IconData dailyPuzzle = LucideIcons.calendar;
  static const IconData puzzles = LucideIcons.puzzle;
  static const IconData friends = LucideIcons.users;
  static const IconData play = LucideIcons.play;

  // ═══════════════════════════════════════════════════════════════════
  // GAME ACTION ICONS
  // ═══════════════════════════════════════════════════════════════════
  static const IconData resign = LucideIcons.flag;
  static const IconData draw = LucideIcons.handMetal;
  static const IconData hint = LucideIcons.lightbulb;
  static const IconData next = LucideIcons.arrowRight;
  static const IconData previous = LucideIcons.arrowLeft;
  static const IconData timer = LucideIcons.clock;
  static const IconData refresh = LucideIcons.refreshCw;
  static const IconData undo = LucideIcons.undo;
  static const IconData redo = LucideIcons.redo;
  static const IconData flip = LucideIcons.flipVertical2;
  static const IconData copy = LucideIcons.copy;
  static const IconData share = LucideIcons.share2;

  // ═══════════════════════════════════════════════════════════════════
  // PROFILE STATS ICONS
  // ═══════════════════════════════════════════════════════════════════
  static const IconData gamesPlayed = LucideIcons.swords;
  static const IconData wins = LucideIcons.trophy;
  static const IconData losses = LucideIcons.xCircle;
  static const IconData draws = LucideIcons.minus;
  static const IconData rating = LucideIcons.star;
  static const IconData streak = LucideIcons.flame;

  // ═══════════════════════════════════════════════════════════════════
  // SOCIAL ICONS
  // ═══════════════════════════════════════════════════════════════════
  static const IconData invite = LucideIcons.userPlus;
  static const IconData online = LucideIcons.circle;
  static const IconData offline = LucideIcons.circleOff;
  static const IconData message = LucideIcons.messageCircle;
  static const IconData addFriend = LucideIcons.userPlus;

  // ═══════════════════════════════════════════════════════════════════
  // SETTINGS ICONS
  // ═══════════════════════════════════════════════════════════════════
  static const IconData theme = LucideIcons.palette;
  static const IconData sound = LucideIcons.volume2;
  static const IconData soundOff = LucideIcons.volumeX;
  static const IconData language = LucideIcons.globe2;
  static const IconData notifications = LucideIcons.bell;
  static const IconData notificationsOff = LucideIcons.bellOff;
  static const IconData privacy = LucideIcons.shield;
  static const IconData about = LucideIcons.info;
  static const IconData help = LucideIcons.helpCircle;
  static const IconData logout = LucideIcons.logOut;

  // ═══════════════════════════════════════════════════════════════════
  // UI ICONS
  // ═══════════════════════════════════════════════════════════════════
  static const IconData back = LucideIcons.arrowLeft;
  static const IconData forward = LucideIcons.arrowRight;
  static const IconData close = LucideIcons.x;
  static const IconData menu = LucideIcons.menu;
  static const IconData more = LucideIcons.moreVertical;
  static const IconData check = LucideIcons.check;
  static const IconData checkCircle = LucideIcons.checkCircle;
  static const IconData error = LucideIcons.alertCircle;
  static const IconData warning = LucideIcons.alertTriangle;
  static const IconData search = LucideIcons.search;
  static const IconData filter = LucideIcons.filter;
  static const IconData sort = LucideIcons.arrowUpDown;
  static const IconData expand = LucideIcons.chevronDown;
  static const IconData collapse = LucideIcons.chevronUp;
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData chevronLeft = LucideIcons.chevronLeft;
  static const IconData edit = LucideIcons.pencil;
  static const IconData delete = LucideIcons.trash2;
  static const IconData save = LucideIcons.save;
  static const IconData download = LucideIcons.download;
  static const IconData upload = LucideIcons.upload;
  static const IconData camera = LucideIcons.camera;
  static const IconData image = LucideIcons.image;
  static const IconData email = LucideIcons.mail;
  static const IconData lock = LucideIcons.lock;
  static const IconData unlock = LucideIcons.unlock;
  static const IconData eye = LucideIcons.eye;
  static const IconData eyeOff = LucideIcons.eyeOff;

  // ═══════════════════════════════════════════════════════════════════
  // CHESS SPECIFIC ICONS
  // ═══════════════════════════════════════════════════════════════════
  static const IconData chessBoard = LucideIcons.layoutGrid;
  static const IconData history = LucideIcons.history;
  static const IconData analysis = LucideIcons.barChart2;
  static const IconData time = LucideIcons.clock;
  static const IconData blitz = LucideIcons.zap;
  static const IconData rapid = LucideIcons.clock3;
  static const IconData bullet = LucideIcons.target;
  static const IconData classical = LucideIcons.hourglass;

  // ═══════════════════════════════════════════════════════════════════
  // RANK & MEDAL ICONS
  // ═══════════════════════════════════════════════════════════════════
  static const IconData crown = LucideIcons.crown;
  static const IconData medal = LucideIcons.medal;
  static const IconData award = LucideIcons.award;
  static const IconData tournament = LucideIcons.swords;
  static const IconData live = LucideIcons.radio;
}

/// Icon widget with consistent styling
class AppIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final AppIconStyle style;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.style = AppIconStyle.primary,
  });

  /// Navigation icon
  const AppIcon.navigation(
    this.icon, {
    super.key,
    this.color,
  })  : size = AppIcons.sizeNavigation,
        style = AppIconStyle.primary;

  /// Menu icon
  const AppIcon.menu(
    this.icon, {
    super.key,
    this.color,
  })  : size = AppIcons.sizeMenu,
        style = AppIconStyle.primary;

  /// Button icon
  const AppIcon.button(
    this.icon, {
    super.key,
    this.color,
  })  : size = AppIcons.sizeButton,
        style = AppIconStyle.primary;

  /// Status icon
  const AppIcon.status(
    this.icon, {
    super.key,
    this.color,
  })  : size = AppIcons.sizeStatus,
        style = AppIconStyle.secondary;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? _getColorForStyle(style);
    return Icon(
      icon,
      size: size ?? AppIcons.sizeMenu,
      color: iconColor,
    );
  }

  Color _getColorForStyle(AppIconStyle style) {
    switch (style) {
      case AppIconStyle.primary:
        return AppTheme.kPrimaryColor;
      case AppIconStyle.secondary:
        return AppTheme.kColorTextSecondary;
      case AppIconStyle.accent:
        return AppTheme.kColorAccent;
      case AppIconStyle.disabled:
        return AppTheme.kBorderColor;
      case AppIconStyle.success:
        return AppTheme.kColorSuccess;
      case AppIconStyle.error:
        return AppTheme.kColorError;
      case AppIconStyle.warning:
        return AppTheme.kColorWarning;
    }
  }
}

/// Icon styles following theme colors
enum AppIconStyle {
  primary,   // theme.colors.primary
  secondary, // theme.text.secondary
  accent,    // theme.colors.accent
  disabled,  // theme.border.default
  success,
  error,
  warning,
}
