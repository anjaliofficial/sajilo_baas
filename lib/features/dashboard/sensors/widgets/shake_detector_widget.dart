import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sajilo_baas/features/dashboard/sensors/services/shake_detector.dart';

/// Widget that detects shake gestures and provides visual feedback
///
/// Wrap your content with this widget to enable shake detection
///
/// Example:
/// ```dart
/// ShakeDetectorWidget(
///   onShake: () => print('Shaked!'),
///   child: YourContent(),
/// )
/// ```
class ShakeDetectorWidget extends StatefulWidget {
  /// Content to display
  final Widget child;

  /// Callback when shake is detected
  final FutureOr<void> Function() onShake;

  /// Optional: Show toast/snackbar feedback when shaking
  final bool showFeedback;

  /// Optional: Custom feedback message
  final String feedbackMessage;

  const ShakeDetectorWidget({
    super.key,
    required this.child,
    required this.onShake,
    this.showFeedback = true,
    this.feedbackMessage = '🤝 Refreshing...',
  });

  @override
  State<ShakeDetectorWidget> createState() => _ShakeDetectorWidgetState();
}

class _ShakeDetectorWidgetState extends State<ShakeDetectorWidget> {
  late ShakeDetector _shakeDetector;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    // Initialize shake detector
    _shakeDetector = ShakeDetector(onShake: _handleShake);

    // Start listening for shake events
    _shakeDetector.startListening();
  }

  /// Handle shake gesture
  Future<void> _handleShake() async {
    // Prevent multiple simultaneous detections
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Show feedback if enabled
      if (widget.showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.feedbackMessage),
            duration: const Duration(milliseconds: 800),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Execute callback
      await Future.sync(widget.onShake);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    // Clean up shake detector
    _shakeDetector.stopListening();
    _shakeDetector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Also detect as a gesture fallback (optional)
      child: Stack(
        children: [
          // Main content
          widget.child,

          // Optional: Show loading indicator while processing
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
