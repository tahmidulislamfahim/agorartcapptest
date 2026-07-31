import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/common/style/app_style.dart';
import 'package:agorartcapptest/core/common/widgets/custom_appbar.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';
import 'package:agorartcapptest/features/notification/controllers/notification_controller.dart';
import 'package:agorartcapptest/features/user_list/controllers/user_list_controller.dart';
import 'package:agorartcapptest/routes/app_routes.dart';

class UserListScreen extends GetView<UserListController> {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifCtrl = Get.find<NotificationController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Available Users',
        showBackButton: false,
        actions: [
          Obx(() {
            final count = notifCtrl.unreadCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColor.textMain,
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.notificationScreen),
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColor.accentReject,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColor.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColor.textMain),
            onPressed: () => Get.toNamed(AppRoutes.profileScreen),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: AppStyle.bgGradientDecoration,
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value && controller.users.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.primary),
              );
            }

            if (controller.users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 64,
                      color: AppColor.textMuted,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No other users registered yet.',
                      style: TextStyle(color: AppColor.textMuted, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                      ),
                      onPressed: () => controller.fetchUsers(),
                      child: const Text(
                        'Refresh',
                        style: TextStyle(color: AppColor.textMain),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchUsers(showLoading: false),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: AppStyle.glassDecoration(),
                    child: Material(
                      color: AppColor.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColor.primary.withValues(
                                alpha: 0.3,
                              ),
                              child: Text(
                                user.username.isNotEmpty
                                    ? user.username[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.white,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: user.isOnline
                                      ? AppColor.onlineGreen
                                      : AppColor.offlineGrey,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColor.bgDark,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          user.username,
                          style: const TextStyle(
                            color: AppColor.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          user.email,
                          style: const TextStyle(
                            color: AppColor.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: user.isOnline
                                    ? AppColor.onlineGreen
                                    : AppColor.offlineGrey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColor.textMuted,
                            ),
                          ],
                        ),
                        onTap: () =>
                            Get.toNamed(AppRoutes.chatScreen, arguments: user),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
