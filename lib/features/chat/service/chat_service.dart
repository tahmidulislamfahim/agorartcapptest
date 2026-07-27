import 'dart:convert';
import 'package:agorartcapptest/core/api_endpoint/api_endpoint.dart';
import 'package:agorartcapptest/core/services/network_service/network_service.dart';
import 'package:agorartcapptest/features/chat/models/chat_message_model.dart';

class ChatService {
  final NetworkService _networkService = NetworkService();

  Future<ChatMessageModel> sendMessage(int receiverId, String message) async {
    final response = await _networkService.post(
      ApiEndpoint.sendChatMessage,
      body: {
        'receiver_id': receiverId,
        'message': message,
      },
    );

    if (response.statusCode == 201) {
      return ChatMessageModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<List<ChatMessageModel>> getChatHistory(int otherUserId) async {
    final response = await _networkService.get(ApiEndpoint.chatHistory(otherUserId));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => ChatMessageModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to fetch chat history');
    }
  }
}
