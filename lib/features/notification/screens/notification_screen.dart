import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/common/style/app_style.dart';
import 'package:agorartcapptest/core/common/widgets/custom_appbar.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';
import 'package:agorartcapptest/features/notification/controllers/notification_controller.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchNotifications(),
          ),
        ],
      ),
      body: Container(
        decoration: AppStyle.bgGradientDecoration,
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.notifications.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.primary),
              );
            }
            if (controller.notifications.isEmpty) {
              return const Center(
                child: Text(
                  'No notifications yet.',
                  style: TextStyle(color: AppColor.textMuted, fontSize: 14),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final notif = controller.notifications[index];
                final isCallNotif = notif.type == 'call';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: AppStyle.glassDecoration(
                    borderColor: notif.isRead
                        ? AppColor.cardBorder
                        : AppColor.primary.withOpacity(0.5),
                    bgColor: notif.isRead
                        ? AppColor.cardBg
                        : AppColor.primary.withOpacity(0.1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isCallNotif
                            ? AppColor.accentCall.withOpacity(0.2)
                            : AppColor.secondary.withOpacity(0.2),
                        child: Icon(
                          isCallNotif ? Icons.call : Icons.message,
                          color: isCallNotif
                              ? AppColor.accentCall
                              : AppColor.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notif.title,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (!notif.isRead)
                                  TextButton(
                                    onPressed: () =>
                                        controller.markRead(notif.id),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Mark Read',
                                      style: TextStyle(
                                        color: AppColor.secondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.body,
                              style: const TextStyle(
                                color: AppColor.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notif.createdAt.length > 16
                                  ? notif.createdAt.substring(11, 16)
                                  : notif.createdAt,
                              style: const TextStyle(
                                color: AppColor.textDisabled,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
