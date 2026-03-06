import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Page to display and manage all sensor features
///
/// Features:
/// - Shake to Refresh: Shake phone to reload properties
/// - Accelerometer readings in real-time
/// - Sensor sensitivity settings
class SensorsPage extends StatefulWidget {
  const SensorsPage({super.key});

  @override
  State<SensorsPage> createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage> {
  // Accelerometer values
  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 0.0;

  // Shake detection
  bool _shakeEnabled = true;
  double _shakeSensitivity = 25.0; // Default threshold

  // Stream subscriptions
  late final StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  /// Start listening to accelerometer events
  void _startListening() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      setState(() {
        _accelX = event.x;
        _accelY = event.y;
        _accelZ = event.z;
      });
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Features'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🤝 Shake to Refresh Section
              _buildShakeSection(),
              const SizedBox(height: 24),

              // 📊 Real-time Accelerometer Data
              _buildAccelerometerDisplay(),
              const SizedBox(height: 24),

              // ⚙️ Sensor Settings
              _buildSensorSettings(),
              const SizedBox(height: 24),

              // ℹ️ Info Section
              _buildInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build shake to refresh section
  Widget _buildShakeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.vibration, size: 28, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shake to Refresh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _shakeEnabled ? 'Enabled ✅' : 'Disabled ❌',
                        style: TextStyle(
                          fontSize: 12,
                          color: _shakeEnabled ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _shakeEnabled,
                  onChanged: (value) {
                    setState(() => _shakeEnabled = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Shake your phone to instantly reload nearby properties',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Shake detection works on all devices with an accelerometer',
                      style: TextStyle(fontSize: 11, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build real-time accelerometer display
  Widget _buildAccelerometerDisplay() {
    final totalAccel =
        (_accelX * _accelX + _accelY * _accelY + _accelZ * _accelZ)
            .toStringAsFixed(2);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Real-time Sensor Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // X-axis
            _buildAccelAxis('X-Axis', _accelX, Colors.red),
            const SizedBox(height: 12),

            // Y-axis
            _buildAccelAxis('Y-Axis', _accelY, Colors.green),
            const SizedBox(height: 12),

            // Z-axis
            _buildAccelAxis('Z-Axis', _accelZ, Colors.blue),
            const SizedBox(height: 16),

            // Total acceleration
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Acceleration:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$totalAccel m/s²',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build single axis display
  Widget _buildAccelAxis(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              value.toStringAsFixed(2),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ((value + 20) / 40).clamp(0.0, 1.0), // Scale from -20 to +20
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// Build sensor settings
  Widget _buildSensorSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚙️ Sensor Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Shake Sensitivity Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Shake Sensitivity'),
                    Text(
                      '${_shakeSensitivity.toStringAsFixed(1)} m/s²',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _shakeSensitivity,
                  min: 15.0,
                  max: 35.0,
                  divisions: 20,
                  onChanged: (value) {
                    setState(() => _shakeSensitivity = value);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('More Sensitive', style: TextStyle(fontSize: 11)),
                    Text('Less Sensitive', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reset to default
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _shakeSensitivity = 25.0);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset to Default'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build information section
  Widget _buildInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ℹ️ How it Works',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              '1️⃣',
              'Enable Shake Detection',
              'Toggle shake detection on to start using this feature',
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              '2️⃣',
              'Adjust Sensitivity',
              'Change the threshold to make it more or less sensitive to motion',
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              '3️⃣',
              'Shake Your Phone',
              'When enabled, shaking will instantly reload nearby properties',
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              '📊',
              'Monitor Sensor Data',
              'Watch real-time accelerometer readings above',
            ),
          ],
        ),
      ),
    );
  }

  /// Build info tile
  Widget _buildInfoTile(String emoji, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              description,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
