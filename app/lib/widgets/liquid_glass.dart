import 'dart:ui';

import 'package:flutter/material.dart';

/// A reusable "liquid glass" surface: real backdrop blur, a translucent
/// gradient tint, a bright specular top-edge, and a soft inner highlight —
/// approximating Apple's Liquid Glass material with pure Flutter.
///
/// Use [circle] for round buttons or provide [borderRadius] for rounded rects.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = 28,
    this.circle = false,
    this.blur = 18,
    this.tint = Colors.white,
    this.tintOpacity = 0.22,
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
  });

  final Widget child;
  final double borderRadius;
  final bool circle;
  final double blur;
  final Color tint;
  final double tintOpacity;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final shape = circle
        ? const CircleBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius));
    final radius = circle
        ? BorderRadius.circular(height ?? width ?? 999)
        : BorderRadius.circular(borderRadius);

    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: circle ? null : radius,
            shape: circle ? BoxShape.circle : BoxShape.rectangle,
            // Translucent tint, brighter at the top-left (specular).
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withValues(alpha: tintOpacity + 0.18),
                tint.withValues(alpha: tintOpacity),
                tint.withValues(alpha: tintOpacity * 0.6),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.2,
            ),
            boxShadow: [
              // Outer soft shadow for lift.
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
