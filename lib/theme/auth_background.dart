import 'dart:math';

import 'package:flutter/material.dart';

class AuthBackground extends StatefulWidget {
  final Widget child;

  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // ==========================================================
            // BACKGROUND
            // ==========================================================

            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),

            // ==========================================================
            // FLOATING FOOD ICONS
            // ==========================================================

            _FloatingFoodIcon(
              icon: Icons.restaurant_rounded,
              size: 32,
              color: colorScheme.primary.withOpacity(0.10),
              left: 25,
              top: 80,
              animation: _controller.value,
              offset: 0.00,
              movement: 14,
            ),

            _FloatingFoodIcon(
              icon: Icons.local_pizza_rounded,
              size: 38,
              color: colorScheme.primary.withOpacity(0.08),
              right: 25,
              top: 130,
              animation: _controller.value,
              offset: 0.18,
              movement: 18,
            ),

            _FloatingFoodIcon(
              icon: Icons.ramen_dining_rounded,
              size: 34,
              color: colorScheme.secondary.withOpacity(0.09),
              left: 65,
              top: 220,
              animation: _controller.value,
              offset: 0.36,
              movement: 12,
            ),

            _FloatingFoodIcon(
              icon: Icons.cake_rounded,
              size: 30,
              color: colorScheme.primary.withOpacity(0.08),
              right: 60,
              top: 270,
              animation: _controller.value,
              offset: 0.54,
              movement: 16,
            ),

            _FloatingFoodIcon(
              icon: Icons.local_cafe_rounded,
              size: 30,
              color: colorScheme.secondary.withOpacity(0.09),
              left: 20,
              top: 390,
              animation: _controller.value,
              offset: 0.72,
              movement: 20,
            ),

            _FloatingFoodIcon(
              icon: Icons.icecream_rounded,
              size: 34,
              color: colorScheme.primary.withOpacity(0.08),
              right: 85,
              top: 410,
              animation: _controller.value,
              offset: 0.28,
              movement: 15,
            ),

            _FloatingFoodIcon(
              icon: Icons.fastfood_rounded,
              size: 32,
              color: colorScheme.primary.withOpacity(0.07),
              left: 90,
              bottom: 80,
              animation: _controller.value,
              offset: 0.45,
              movement: 17,
            ),

            _FloatingFoodIcon(
              icon: Icons.dinner_dining_rounded,
              size: 36,
              color: colorScheme.secondary.withOpacity(0.08),
              right: 30,
              bottom: 100,
              animation: _controller.value,
              offset: 0.63,
              movement: 13,
            ),

            _FloatingFoodIcon(
              icon: Icons.bakery_dining_rounded,
              size: 30,
              color: colorScheme.primary.withOpacity(0.09),
              left: 30,
              bottom: 230,
              animation: _controller.value,
              offset: 0.81,
              movement: 19,
            ),

            _FloatingFoodIcon(
              icon: Icons.lunch_dining_rounded,
              size: 34,
              color: colorScheme.secondary.withOpacity(0.07),
              right: 70,
              bottom: 260,
              animation: _controller.value,
              offset: 0.12,
              movement: 15,
            ),

            _FloatingFoodIcon(
              icon: Icons.emoji_food_beverage_rounded,
              size: 28,
              color: colorScheme.primary.withOpacity(0.08),
              left: 120,
              top: 120,
              animation: _controller.value,
              offset: 0.32,
              movement: 12,
            ),

            _FloatingFoodIcon(
              icon: Icons.set_meal_rounded,
              size: 32,
              color: colorScheme.secondary.withOpacity(0.08),
              right: 120,
              top: 360,
              animation: _controller.value,
              offset: 0.50,
              movement: 18,
            ),

            _FloatingFoodIcon(
              icon: Icons.kitchen_rounded,
              size: 30,
              color: colorScheme.primary.withOpacity(0.07),
              left: 45,
              bottom: 360,
              animation: _controller.value,
              offset: 0.68,
              movement: 14,
            ),

            _FloatingFoodIcon(
              icon: Icons.local_bar_rounded,
              size: 28,
              color: colorScheme.secondary.withOpacity(0.07),
              right: 40,
              bottom: 390,
              animation: _controller.value,
              offset: 0.90,
              movement: 16,
            ),

            // ==========================================================
            // CONTENT
            // ==========================================================

            widget.child,
          ],
        );
      },
    );
  }
}

// ==========================================================
// FLOATING FOOD ICON
// ==========================================================

class _FloatingFoodIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  final double animation;
  final double offset;
  final double movement;

  const _FloatingFoodIcon({
    required this.icon,
    required this.size,
    required this.color,
    required this.animation,
    required this.offset,
    required this.movement,
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (animation + offset) % 1.0;

    // Different movement for each icon.
    final verticalMovement =
        sin(progress * 2 * pi) * movement;

    final horizontalMovement =
        cos(progress * 2 * pi) * (movement * 0.6);

    final rotation =
        sin(progress * 2 * pi) * 0.12;

    return Positioned(
      left: left != null
          ? left! + horizontalMovement
          : null,
      right: right != null
          ? right! - horizontalMovement
          : null,
      top: top != null
          ? top! + verticalMovement
          : null,
      bottom: bottom != null
          ? bottom! - verticalMovement
          : null,
      child: Transform.rotate(
        angle: rotation,
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      ),
    );
  }
}
