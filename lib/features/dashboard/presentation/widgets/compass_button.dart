import 'package:flutter/material.dart';
import 'dart:math';

/// Compass button that shows current map rotation and resets to north when tapped
class CompassButton extends StatelessWidget {
  final double rotation;
  final VoidCallback onResetRotation;

  const CompassButton({
    super.key,
    required this.rotation,
    required this.onResetRotation,
  });

  @override
  Widget build(BuildContext context) {
    // Only show compass when map is rotated
    if (rotation.abs() < 0.1) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onResetRotation,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Red circle background for the compass
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              // Rotating north arrow - rotates opposite to map to always point north
              Transform.rotate(
                angle: -rotation * pi / 180,
                child: const Icon(
                  Icons.navigation,
                  color: Colors.red,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
