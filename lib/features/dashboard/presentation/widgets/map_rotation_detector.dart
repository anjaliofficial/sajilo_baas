import 'package:flutter/material.dart';
import 'dart:math';

/// Detects two-finger rotation gestures and reports rotation changes
class MapRotationDetector extends StatefulWidget {
  final Widget child;
  final Function(double rotation) onRotationUpdate;
  final double initialRotation;

  const MapRotationDetector({
    super.key,
    required this.child,
    required this.onRotationUpdate,
    this.initialRotation = 0.0,
  });

  @override
  State<MapRotationDetector> createState() => _MapRotationDetectorState();
}

class _MapRotationDetectorState extends State<MapRotationDetector> {
  final Map<int, Offset> _activePointers = {};
  double? _previousAngle;
  double _currentRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _currentRotation = widget.initialRotation;
  }

  void _handlePointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.localPosition;
    print('🖐️ Finger down - Total fingers: ${_activePointers.length}');
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _activePointers[event.pointer] = event.localPosition;

    // Only calculate rotation when exactly 2 fingers are active
    if (_activePointers.length == 2) {
      final pointers = _activePointers.values.toList();
      final finger1 = pointers[0];
      final finger2 = pointers[1];

      // Calculate angle between two fingers using atan2
      final dx = finger2.dx - finger1.dx;
      final dy = finger2.dy - finger1.dy;
      final currentAngle = atan2(dy, dx) * 180 / pi;

      if (_previousAngle != null) {
        var delta = currentAngle - _previousAngle!;

        // Handle angle wraparound (prevent jumping from 180° to -180°)
        if (delta > 180) {
          delta -= 360;
        } else if (delta < -180) {
          delta += 360;
        }

        // Apply rotation threshold to prevent jitter from tiny finger movements
        const rotationThreshold = 0.5; // degrees
        if (delta.abs() > rotationThreshold) {
          _currentRotation = (_currentRotation + delta) % 360;

          // Normalize to -180 to 180 range
          if (_currentRotation > 180) {
            _currentRotation -= 360;
          } else if (_currentRotation < -180) {
            _currentRotation += 360;
          }

          print(
            '🔄 Rotation: ${_currentRotation.toStringAsFixed(1)}° (delta: ${delta.toStringAsFixed(1)}°)',
          );
          widget.onRotationUpdate(_currentRotation);
        }
      } else {
        print('🎯 Two fingers detected - Starting rotation tracking');
      }

      _previousAngle = currentAngle;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    _activePointers.remove(event.pointer);

    // Reset previous angle when fewer than 2 fingers
    if (_activePointers.length < 2) {
      _previousAngle = null;
      print(
        '☝️ Finger up - Rotation tracking stopped (${_activePointers.length} fingers remaining)',
      );
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _activePointers.remove(event.pointer);
    if (_activePointers.length < 2) {
      _previousAngle = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: widget.child,
    );
  }
}
