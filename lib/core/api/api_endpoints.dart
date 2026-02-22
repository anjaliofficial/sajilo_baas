import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // ============================================
  // ENVIRONMENT CONFIGURATION
  // ============================================
  // Set to true to use a physical device on a local network
  // Set to false to use emulator/simulator defaults
  static const bool isPhysicalDevice =
      true; // ← CHANGE TO TRUE for physical device

  // Your development machine IP address (for physical device testing)
  static const String compIpAddress = "10.205.75.20";
  static const int apiPort = 5050; // ← Change this to your backend port

  /// Dynamic base URL depending on platform and configuration
  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:$apiPort/api';
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:$apiPort/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:$apiPort/api';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:$apiPort/api';
    } else {
      return 'http://127.0.0.1:$apiPort/api';
    }
  }

  static String get staticBaseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:$apiPort';
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:$apiPort';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:$apiPort';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:$apiPort';
    } else {
      return 'http://127.0.0.1:$apiPort';
    }
  }

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String currentUser = '/auth/me';
  static const String logout = '/auth/logout';
  static const String updateProfile = '/auth/update';
  static const String myBookings = '/bookings/my';
  static const String cancelBooking = '/bookings/cancel';
  // File upload
  static const String uploadFile = '/files/upload';
}
