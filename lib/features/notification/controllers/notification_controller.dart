import 'dart:async';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/services/local_service/shared_preferences_helper.dart';
import 'package:agorartcapptest/routes/app_routes.dart';
import 'package:agorartcapptest/features/call/controllers/call_controller.dart';
import 'package:agorartcapptest/features/call/models/call_model.dart';
import 'package:agorartcapptest/features/call/screens/incoming_call_dialog.dart';
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
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications({bool showLoading = true}) async {
    // Do not fetch notifications if user is not logged in yet
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null || token.isEmpty) return;

    try {
      if (showLoading) isLoading.value = true;
      final list = await _service.getNotifications();
      notifications.assignAll(list);
      _checkIncomingCalls(list);
    } catch (_) {
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  void _checkIncomingCalls(List<NotificationModel> list) {
    // Do not trigger incoming call dialog if user is already in a call or on a call screen
    if (Get.isRegistered<CallController>()) {
      final callCtrl = Get.find<CallController>();
      if (callCtrl.activeCall.value != null &&
          ['accepted', 'initiated'].contains(callCtrl.activeCall.value!.status.toLowerCase())) {
        return;
      }
    }

    final currentRoute = Get.currentRoute;
    if (currentRoute == AppRoutes.activeAudioCallScreen ||
        currentRoute == AppRoutes.activeVideoCallScreen ||
        currentRoute == AppRoutes.outgoingCallScreen) {
      return;
    }

    for (final notif in list) {
      if (!notif.isRead && notif.type == 'call' && notif.parsedData != null) {
        final data = notif.parsedData!;
        final int callId = data['call_id'] as int? ?? 0;
        if (callId > 0 && callId != _lastHandledCallId) {
          _lastHandledCallId = callId;
          markRead(notif.id); // Mark notification read immediately

          final callModel = CallModel(
            id: callId,
            callerId: data['caller_id'] as int? ?? 0,
            callerUsername: data['caller_username']?.toString() ?? 'Caller',
            receiverId: notif.userId,
            receiverUsername: '',
            channelName: data['channel_name']?.toString() ?? '',
            callType: data['call_type']?.toString() ?? 'audio',
            status: 'initiated',
            durationSeconds: 0,
            receiverRtcToken: data['rtc_token']?.toString(),
            agoraAppId: data['agora_app_id']?.toString(),
          );

          // Pop up Incoming Call Screen / Dialog for receiver
          if (Get.isDialogOpen != true) {
            Get.dialog(
              IncomingCallDialog(callData: callModel),
              barrierDismissible: false,
            );
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
    } catch (_) {}
  }
}
