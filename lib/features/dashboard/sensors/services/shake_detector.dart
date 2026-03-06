import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Detects device shake gestures using accelerometer
///
/// Usage:
/// ```dart
/// final shakeDetector = ShakeDetector(
///   onShake: () => print('Shake detected!'),
/// );
/// shakeDetector.startListening();
///
/// // Later...
/// shakeDetector.stopListening();
/// ```
class ShakeDetector {
  /// Acceleration threshold to trigger shake (m/s²)
  /// Lower = more sensitive, Higher = less sensitive
  static const double SHAKE_THRESHOLD = 25.0;

  /// Number of consecutive shake events needed to trigger callback
  static const int SHAKE_COUNT_THRESHOLD = 2;

  /// Time window for detecting consecutive shakes (milliseconds)
  static const int SHAKE_TIME_WINDOW = 500;

  /// Callback when shake is detected
  final FutureOr<void> Function() onShake;

  /// Stream subscription to accelerometer events
  StreamSubscription<AccelerometerEvent>? _subscription;

  /// Counter for consecutive shake detections
  int _shakeCount = 0;

  /// Timestamp of last shake detection
  DateTime? _lastShakeTime;

  /// Whether the detector is currently listening
  bool _isListening = false;

  ShakeDetector({required this.onShake});

  /// Start listening to accelerometer events
  void startListening() {
    if (_isListening) return;

    _isListening = true;
    _shakeCount = 0;
    _lastShakeTime = null;

    try {
      _subscription = accelerometerEvents.listen(
        (AccelerometerEvent event) {
          // Calculate magnitude of acceleration vector
          // This represents the total acceleration in 3D space
          double acceleration = sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );

          // Subtract gravity constant (9.8 m/s²) to get actual motion acceleration
          // This prevents false positives from phone being held at an angle
          acceleration = acceleration - 9.8;

          // Check if acceleration exceeds shake threshold
          if (acceleration > SHAKE_THRESHOLD) {
            _processShakeDetection();
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (error is MissingPluginException) {
            debugPrint(
              'ShakeDetector disabled: sensors plugin is not available in this app build. '
              'Run a full rebuild (flutter clean; flutter pub get; flutter run).',
            );
            stopListening();
            return;
          }
          debugPrint('ShakeDetector stream error: $error');
        },
      );
    } on MissingPluginException {
      debugPrint(
        'ShakeDetector disabled: sensors plugin is not available in this app build. '
        'Run a full rebuild (flutter clean; flutter pub get; flutter run).',
      );
      stopListening();
    }
  }

  /// Process shake detection and trigger callback if threshold reached
  void _processShakeDetection() {
    final now = DateTime.now();

    // If last shake was too long ago, reset counter
    if (_lastShakeTime != null &&
        now.difference(_lastShakeTime!).inMilliseconds > SHAKE_TIME_WINDOW) {
      _shakeCount = 1;
    } else {
      _shakeCount++;
    }

    _lastShakeTime = now;

    // Trigger callback once shake count threshold is reached
    if (_shakeCount >= SHAKE_COUNT_THRESHOLD) {
      onShake();
      _shakeCount = 0; // Reset for next shake sequence
    }
  }

  /// Stop listening to accelerometer events
  void stopListening() {
    _subscription?.cancel();
    _isListening = false;
    _shakeCount = 0;
    _lastShakeTime = null;
  }

  /// Check if detector is currently listening
  bool get isListening => _isListening;

  /// Cleanup resources
  void dispose() {
    stopListening();
  }
}
