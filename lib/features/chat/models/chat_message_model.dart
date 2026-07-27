class ChatMessageModel {
  final int id;
  final int senderId;
  final String senderUsername;
  final int receiverId;
  final String receiverUsername;
  final String message;
  final String msgType; // 'text' or 'call_log'
  final String timestamp;
  final bool isRead;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    required this.receiverId,
    required this.receiverUsername,
    required this.message,
    required this.msgType,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int? ?? 0,
      senderId: json['sender_id'] as int? ?? 0,
      senderUsername: json['sender_username']?.toString() ?? '',
      receiverId: json['receiver_id'] as int? ?? 0,
      receiverUsername: json['receiver_username']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      msgType: json['msg_type']?.toString() ?? 'text',
      timestamp: json['timestamp']?.toString() ?? '',
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}
