import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/common/style/app_style.dart';
import 'package:agorartcapptest/core/common/widgets/custom_appbar.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';
import 'package:agorartcapptest/features/auth/controllers/auth_controller.dart';
import 'package:agorartcapptest/features/auth/models/user_model.dart';
import 'package:agorartcapptest/features/chat/controllers/chat_controller.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel? target = Get.arguments as UserModel?;
    if (target != null && controller.targetUser.value?.id != target.id) {
      controller.setTargetUser(target);
    }

    final authCtrl = Get.find<AuthController>();
    final currentUserId = authCtrl.currentUser.value?.id;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          final u = controller.targetUser.value;
          return CustomAppBar(
            title: u?.username ?? 'Chat',
            actions: [
              IconButton(
                icon: const Icon(Icons.phone_rounded, color: AppColor.accentCall),
                onPressed: () => controller.startAudioCall(),
                tooltip: 'Audio Call',
              ),
              IconButton(
                icon: const Icon(Icons.videocam_rounded, color: AppColor.secondary),
                onPressed: () => controller.startVideoCall(),
                tooltip: 'Video Call',
              ),
              const SizedBox(width: 8),
            ],
          );
        }),
      ),
      body: Container(
        decoration: AppStyle.bgGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // Chat Messages List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColor.primary));
                  }

                  if (controller.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet. Send a message to start conversation!',
                        style: TextStyle(color: AppColor.textMuted, fontSize: 13),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final msg = controller.messages[index];
                      final isMe = msg.senderId == currentUserId;
                      final isCallLog = msg.msgType == 'call_log';

                      if (isCallLog) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColor.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColor.secondary.withOpacity(0.3)),
                          ),
                          child: Text(
                            msg.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColor.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isMe ? AppColor.primary : AppColor.cardBg,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(2),
                              bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(16),
                            ),
                            border: Border.all(
                              color: isMe ? AppColor.primary : AppColor.cardBorder,
                            ),
                          ),
                          child: Text(
                            msg.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),

              // Bottom Message Input Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColor.cardBg,
                  border: Border(top: BorderSide(color: AppColor.cardBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.messageCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        onSubmitted: (_) => controller.sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: const TextStyle(color: AppColor.textMuted, fontSize: 14),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppColor.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppColor.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColor.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: () => controller.sendMessage(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
