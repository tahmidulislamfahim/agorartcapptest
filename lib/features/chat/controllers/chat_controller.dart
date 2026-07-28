import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/services/rtm_service/rtm_service.dart';
import 'package:agorartcapptest/features/auth/controllers/auth_controller.dart';
import 'package:agorartcapptest/features/auth/models/user_model.dart';
import 'package:agorartcapptest/features/chat/models/chat_message_model.dart';
import 'package:agorartcapptest/features/chat/service/chat_service.dart';
import 'package:agorartcapptest/features/call/controllers/call_controller.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final CallController callController = Get.find<CallController>();

  final Rxn<UserModel> targetUser = Rxn<UserModel>();
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final TextEditingController messageCtrl = TextEditingController();

  void setTargetUser(UserModel user) {
    targetUser.value = user;
    fetchMessages();
  }

  Future<void> fetchMessages({bool showLoading = true}) async {
    if (targetUser.value == null) return;
    try {
      if (showLoading) isLoading.value = true;
      final history = await _chatService.getChatHistory(targetUser.value!.id);
      messages.assignAll(history);
    } catch (e) {
      debugPrint('Fetch chat history error: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageCtrl.text.trim();
    if (text.isEmpty || targetUser.value == null) return;

    final receiverId = targetUser.value!.id;
    final myId = Get.find<AuthController>().currentUser.value?.id ?? 0;

    try {
      messageCtrl.clear();
      await _chatService.sendMessage(receiverId, text);
      fetchMessages(showLoading: false);

      if (Get.isRegistered<RtmService>()) {
        Get.find<RtmService>().sendPeerMessage(
          peerUserId: receiverId.toString(),
          payload: {
            'type': 'chat_message',
            'sender_id': myId,
            'message': text,
          },
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void startAudioCall() {
    if (targetUser.value != null) {
      callController.startCall(targetUser.value!, 'audio');
    }
  }

  void startVideoCall() {
    if (targetUser.value != null) {
      callController.startCall(targetUser.value!, 'video');
    }
  }
}
