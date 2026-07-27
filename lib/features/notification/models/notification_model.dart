import 'dart:convert';

class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String body;
  final String type;
  final String? data;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'system',
      data: json['data']?.toString(),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic>? get parsedData {
    if (data == null || data!.isEmpty) return null;
    try {
      return jsonDecode(data!) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
