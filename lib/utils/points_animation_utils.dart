import 'package:flutter/material.dart';
import 'package:fyp_application/widgets/points_animation.dart';

void showPointsAnimation(
  BuildContext context,
  int points,
) {
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: 120,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: PointsAnimation(
              points: points,
            ),
          ),
        ),
      );
    },
  );

  Overlay.of(context).insert(entry);

  Future.delayed(
    const Duration(milliseconds: 1300),
    () {
      if (entry.mounted) {
        entry.remove();
      }
    },
  );
}