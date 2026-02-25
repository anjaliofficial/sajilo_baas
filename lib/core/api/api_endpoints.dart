import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // ========================
  // LISTINGS ENDPOINT
  // ========================
  static const String listings = '/listings';
  ApiEndpoints._();

  // ========================
  // ENVIRONMENT CONFIG
  // ========================
  static const bool isPhysicalDevice = true; // true for phone
  static const String compIpAddress = "10.205.75.20"; // your PC IP
  static const int apiPort = 5050;

  // Base API URL
  static String get baseUrl {
    if (isPhysicalDevice) return 'http://$compIpAddress:$apiPort/api';
    if (kIsWeb) return 'http://127.0.0.1:$apiPort/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:$apiPort/api';
    if (Platform.isIOS) return 'http://127.0.0.1:$apiPort/api';
    return 'http://127.0.0.1:$apiPort/api';
  }

  static String get staticBaseUrl {
    if (isPhysicalDevice) return 'http://$compIpAddress:$apiPort';
    if (kIsWeb) return 'http://127.0.0.1:$apiPort';
    if (Platform.isAndroid) return 'http://10.0.2.2:$apiPort';
    if (Platform.isIOS) return 'http://127.0.0.1:$apiPort';
    return 'http://127.0.0.1:$apiPort';
  }

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // ========================
  // AUTH ENDPOINTS (for login/register/logout only)
  // ========================
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String updateProfile = '/auth/update';

  // ========================
  // USER ENDPOINTS (for profile fetching)
  // ========================
  static const String currentUser = '/users/me';

  // ========================
  // BOOKINGS
  // ========================
  static const String myBookings = '/bookings/my';
  static const String cancelBooking = '/bookings/cancel';

  // ========================
  // FILE UPLOAD
  // ========================
  static const String uploadFile = '/files/upload';

  // ========================
  // MESSAGES
  // ========================
  static const String getThreads = '/messages/threads';
  static const String getConversation =
      '/messages'; // /messages/{otherUserId}/{listingId}
  static const String sendMessage = '/messages';
  static const String markConversationRead = '/messages/read';
  static const String editMessage = '/messages'; // /messages/{messageId}
  static const String deleteMessage = '/messages'; // /messages/{messageId}
}
