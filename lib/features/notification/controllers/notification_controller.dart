import 'dart:async';
import 'package:get/get.dart';
import 'package:agorartcapptest/features/notification/models/notification_model.dart';
import 'package:agorartcapptest/features/notification/service/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  Timer? _timer;
  int _lastHandledCallId = 0;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    // Poll notifications every 4 seconds to listen for incoming calls and messages
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => fetchNotifications(showLoading: false));
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      final list = await _service.getNotifications();
      notifications.assignAll(list);
      _checkIncomingCalls(list);
    } catch (e) {
      print('Fetch notifications error: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  void _checkIncomingCalls(List<NotificationModel> list) {
    for (final notif in list) {
      if (!notif.isRead && notif.type == 'call' && notif.parsedData != null) {
        final data = notif.parsedData!;
        final int callId = data['call_id'] as int? ?? 0;
        if (callId > 0 && callId != _lastHandledCallId) {
          _lastHandledCallId = callId;
          // Trigger incoming call handler if available in CallController
          if (Get.isRegistered(tag: 'call_handler')) {
            // Handled dynamically
          }
        }
      }
    }
  }

  Future<void> markRead(int id) async {
    try {
      await _service.markRead(id);
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = notifications[index];
        notifications[index] = NotificationModel(
          id: old.id,
          userId: old.userId,
          title: old.title,
          body: old.body,
          type: old.type,
          data: old.data,
          isRead: true,
          createdAt: old.createdAt,
        );
      }
    } catch (e) {
      print('Mark read error: $e');
    }
  }
}
