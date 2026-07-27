class CallModel {
  final int id;
  final int callerId;
  final String callerUsername;
  final int receiverId;
  final String receiverUsername;
  final String channelName;
  final String callType; // "audio" or "video"
  final String status;   // "initiated", "accepted", "rejected", "missed", "ended"
  final int durationSeconds;
  final String? callerRtcToken;
  final String? receiverRtcToken;
  final String? agoraAppId;

  CallModel({
    required this.id,
    required this.callerId,
    required this.callerUsername,
    required this.receiverId,
    required this.receiverUsername,
    required this.channelName,
    required this.callType,
    required this.status,
    required this.durationSeconds,
    this.callerRtcToken,
    this.receiverRtcToken,
    this.agoraAppId,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] as int? ?? 0,
      callerId: json['caller_id'] as int? ?? 0,
      callerUsername: json['caller_username']?.toString() ?? '',
      receiverId: json['receiver_id'] as int? ?? 0,
      receiverUsername: json['receiver_username']?.toString() ?? '',
      channelName: json['channel_name']?.toString() ?? '',
      callType: json['call_type']?.toString() ?? 'audio',
      status: json['status']?.toString() ?? 'initiated',
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      callerRtcToken: json['caller_rtc_token']?.toString(),
      receiverRtcToken: json['receiver_rtc_token']?.toString(),
      agoraAppId: json['agora_app_id']?.toString(),
    );
  }
}
