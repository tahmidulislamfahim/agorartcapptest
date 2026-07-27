import 'dart:convert';
import 'package:agorartcapptest/core/api_endpoint/api_endpoint.dart';
import 'package:agorartcapptest/core/services/network_service/network_service.dart';
import 'package:agorartcapptest/features/notification/models/notification_model.dart';

class NotificationService {
  final NetworkService _networkService = NetworkService();

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _networkService.get(ApiEndpoint.getNotifications);
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<NotificationModel> markRead(int notificationId) async {
    final response = await _networkService.put(ApiEndpoint.markNotificationRead(notificationId));
    if (response.statusCode == 200) {
      return NotificationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to mark notification as read');
    }
  }
}
