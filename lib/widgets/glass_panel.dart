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
            color: Colors.black.withAlpha(230),
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

    final Color baseTint = backgroundColor ?? Colors.white;

    return Container(

      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(64),
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
                color: Colors.white.withAlpha(38),
                width: 1.0,
              ),

              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                baseTint.withAlpha(38),
               baseTint.withAlpha(13),
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