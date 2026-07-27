import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoint {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://agotartctestserver.onrender.com/api/v1';
  static String get agoraAppId => dotenv.env['AGORA_APP_ID'] ?? '5d14aebdcf754f92a51247ee5f0bfed0';

  // Auth Endpoints
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get getMe => '$baseUrl/auth/me';

  // Users Endpoint
  static String get getUsers => '$baseUrl/users';

  // Chat Endpoints
  static String get sendChatMessage => '$baseUrl/chat/send';
  static String chatHistory(int otherUserId) => '$baseUrl/chat/history/$otherUserId';

  // Call Endpoints
  static String get initiateCall => '$baseUrl/calls/initiate';
  static String get updateCallStatus => '$baseUrl/calls/status';
  static String get getCallHistory => '$baseUrl/calls/history';

  // Notifications Endpoints
  static String get getNotifications => '$baseUrl/notifications';
  static String markNotificationRead(int id) => '$baseUrl/notifications/$id/read';

  // Agora Standalone Tokens
  static String get getRtcToken => '$baseUrl/agora/rtc-token';
  static String get getRtmToken => '$baseUrl/agora/rtm-token';
}
