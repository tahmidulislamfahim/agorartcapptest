import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  Timer? _pollingTimer;

  void setTargetUser(UserModel user) {
    targetUser.value = user;
    fetchMessages();
    _startPolling();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => fetchMessages(showLoading: false));
  }

  Future<void> fetchMessages({bool showLoading = true}) async {
    if (targetUser.value == null) return;
    try {
      if (showLoading) isLoading.value = true;
      final history = await _chatService.getChatHistory(targetUser.value!.id);
      messages.assignAll(history);
    } catch (e) {
      print('Fetch chat history error: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageCtrl.text.trim();
    if (text.isEmpty || targetUser.value == null) return;

    try {
      messageCtrl.clear();
      await _chatService.sendMessage(targetUser.value!.id, text);
      fetchMessages(showLoading: false);
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
