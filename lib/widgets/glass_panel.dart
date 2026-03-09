/*
import 'dart:ui';
import 'package:chess_park/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16.0),
      this.backgroundColor,

      this.borderRadius = AppTheme.kBorderRadius});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(borderRadius);

    final Color baseTint = backgroundColor ?? Colors.white;

    return Container(

      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 30.0,
            spreadRadius: -5.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(

          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,

              border: Border.all(
                color: Colors.white.withAlpha(230),
                width: 1.0,
              ),

              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseTint.withAlpha(230),
                  baseTint.withAlpha(230),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}*/
import 'dart:ui';
import 'package:chess_park/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16.0),
      this.backgroundColor,

      this.borderRadius = AppTheme.kBorderRadius});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(borderRadius);
    final bool isLight = AppTheme.isLight;

    // Use theme-based color
    final Color baseTint = backgroundColor ?? AppTheme.kBgColor1;
    
    if (isLight) {
      // Premium light theme style with elegant shadow and gradient
      return Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppTheme.kColorAccent.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.95),
                ],
              ),
            ),
            child: child,
          ),
        ),
      );
    }

    // Dark theme style with glass effect
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        color: baseTint.withOpacity(0.6),
        border: Border.all(
          color: AppTheme.kColorAccent.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseTint.withOpacity(0.4),
                  baseTint.withOpacity(0.2),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}