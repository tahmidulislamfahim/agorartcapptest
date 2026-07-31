import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/api_endpoint/api_endpoint.dart';
import 'package:agorartcapptest/core/services/network_service/network_service.dart';
import 'package:agorartcapptest/features/call/controllers/call_controller.dart';
import 'package:agorartcapptest/features/call/models/call_model.dart';
import 'package:agorartcapptest/features/call/screens/incoming_call_dialog.dart';
import 'package:agorartcapptest/features/chat/controllers/chat_controller.dart';
import 'package:agorartcapptest/features/notification/controllers/notification_controller.dart';

class RtmService extends GetxService {
  final NetworkService _networkService = NetworkService();
  RtmClient? _rtmClient;
  bool _isLoggedIn = false;
  String _currentUserId = '';

  bool get isLoggedIn => _isLoggedIn;

  String _parseMessageContent(dynamic msg) {
    if (msg == null) return '';
    if (msg is String) return msg;
    if (msg is List<int>) {
      try {
        return utf8.decode(msg);
      } catch (_) {
        return String.fromCharCodes(msg);
      }
    }
    if (msg is Uint8List) {
      try {
        return utf8.decode(msg);
      } catch (_) {
        return String.fromCharCodes(msg);
      }
    }
    return msg.toString();
  }

  Future<void> initAndLoginUser(String userId) async {
    if (userId.isEmpty || userId == '0') return;
    if (_isLoggedIn && _currentUserId == userId) return;

    _currentUserId = userId;

    try {
      debugPrint('RTM_SERVICE: Requesting RTM token for User $userId...');
      final response = await _networkService.post(
        ApiEndpoint.getRtmToken,
        body: {'user_account': userId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token']?.toString() ?? '';
        final String appId = data['app_id']?.toString() ?? ApiEndpoint.agoraAppId;

        if (token.isNotEmpty) {
          await initAndLogin(appId: appId, userId: userId, token: token);
        } else {
          debugPrint('RTM_SERVICE: RTM Token empty in backend response');
        }
      } else {
        debugPrint('RTM_SERVICE: Failed to fetch RTM token: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('RTM_SERVICE: Error fetching RTM token: $e');
    }
  }

  Future<void> initAndLogin({
    required String appId,
    required String userId,
    required String token,
  }) async {
    if (_isLoggedIn && _currentUserId == userId) return;
    _currentUserId = userId;

    try {
      if (_rtmClient != null) {
        try {
          await _rtmClient?.logout();
          await _rtmClient?.release();
        } catch (_) {}
        _rtmClient = null;
        _isLoggedIn = false;
      }

      final (status, client) = await RTM(appId, userId);
      _rtmClient = client;

      // Register event listeners
      _rtmClient?.addListener(
        message: (MessageEvent event) {
          final String rawMsg = _parseMessageContent(event.message);
          final String peerId = event.publisher?.toString() ?? '';
          _handleIncomingRtmMessage(rawMsg, peerId);
        },
        linkState: (LinkStateEvent event) {
          debugPrint('RTM_SERVICE: Link state changed: ${event.currentState}');
          if (event.currentState == RtmLinkState.failed ||
              event.currentState == RtmLinkState.disconnected) {
            _isLoggedIn = false;
          }
        },
      );

      final (loginStatus, loginRes) = await _rtmClient!.login(token);
      if (loginStatus.error) {
        debugPrint('RTM_SERVICE: Login Error Code: ${loginStatus.errorCode}, Reason: ${loginStatus.reason}');
        _isLoggedIn = false;
        return;
      }

      // Subscribe to self user channel to receive incoming call offers & notifications
      await _rtmClient?.subscribe('user_$userId');

      _isLoggedIn = true;
      debugPrint('RTM_SERVICE: ✅ Logged into Agora RTM successfully for User $userId!');
    } catch (e) {
      debugPrint('RTM_SERVICE: Init Error: $e');
      _isLoggedIn = false;
    }
  }

  void _handleIncomingRtmMessage(String rawMsg, String peerId) {
    if (rawMsg.isEmpty) return;

    try {
      debugPrint('RTM_SERVICE: Received RTM message from $peerId: $rawMsg');

      final Map<String, dynamic> data = jsonDecode(rawMsg);
      final String type = data['type']?.toString() ?? '';

      if (type == 'call_offer') {
        _handleCallOffer(data);
      } else if (type == 'call_accepted') {
        _handleCallAccepted(data);
      } else if (type == 'call_rejected' || type == 'call_ended') {
        _handleCallEnded();
      }

      // Automatically refresh notifications unread dot & notification list
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().fetchNotifications(showLoading: false);
      }

      // Automatically refresh active chat screen
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().fetchMessages(showLoading: false);
      }
    } catch (e) {
      debugPrint('RTM_SERVICE: Error parsing RTM message: $e (rawMsg: $rawMsg)');
    }
  }

  void _handleCallOffer(Map<String, dynamic> data) {
    final callModel = CallModel(
      id: data['call_id'] as int? ?? 0,
      callerId: data['caller_id'] as int? ?? 0,
      callerUsername: data['caller_username']?.toString() ?? 'Caller',
      receiverId: data['receiver_id'] as int? ?? 0,
      receiverUsername: '',
      channelName: data['channel_name']?.toString() ?? '',
      callType: data['call_type']?.toString() ?? 'audio',
      status: 'initiated',
      durationSeconds: 0,
      receiverRtcToken: data['rtc_token']?.toString(),
      agoraAppId: data['agora_app_id']?.toString() ?? ApiEndpoint.agoraAppId,
    );

    if (Get.isDialogOpen != true) {
      Get.dialog(
        IncomingCallDialog(callData: callModel),
        barrierDismissible: false,
      );
    }
  }

  void _handleCallAccepted(Map<String, dynamic> data) {
    if (Get.isRegistered<CallController>()) {
      final callCtrl = Get.find<CallController>();
      callCtrl.onRemoteAcceptedCall();
    }
  }

  void _handleCallEnded() {
    if (Get.isRegistered<CallController>()) {
      Get.find<CallController>().endCall();
    }
  }

  Future<void> sendPeerMessage({
    required String peerUserId,
    required Map<String, dynamic> payload,
  }) async {
    if (_rtmClient == null || !_isLoggedIn) {
      debugPrint('RTM_SERVICE: Cannot send peer message - not logged into RTM.');
      return;
    }
    try {
      final jsonString = jsonEncode(payload);

      // 1. Publish as Peer-to-Peer user message to target account (e.g. '1' or '2')
      try {
        await _rtmClient?.publish(
          peerUserId,
          jsonString,
          channelType: RtmChannelType.user,
        );
        debugPrint('RTM_SERVICE: Published RTM User message to $peerUserId: $jsonString');
      } catch (e) {
        debugPrint('RTM_SERVICE: RTM User publish error: $e');
      }

      // 2. Publish as Message Channel event to channel 'user_$peerUserId'
      try {
        await _rtmClient?.publish(
          'user_$peerUserId',
          jsonString,
          channelType: RtmChannelType.message,
        );
        debugPrint('RTM_SERVICE: Published RTM Message channel to user_$peerUserId: $jsonString');
      } catch (e) {
        debugPrint('RTM_SERVICE: RTM Message channel publish error: $e');
      }
    } catch (e) {
      debugPrint('RTM_SERVICE: Send Peer Message Error: $e');
    }
  }

  Future<void> logout() async {
    if (_rtmClient != null && _isLoggedIn) {
      try {
        if (_currentUserId.isNotEmpty) {
          await _rtmClient?.unsubscribe('user_$_currentUserId');
        }
        await _rtmClient?.logout();
        await _rtmClient?.release();
        _isLoggedIn = false;
        _rtmClient = null;
        debugPrint('RTM_SERVICE: Logged out and released Agora RTM Client');
      } catch (e) {
        debugPrint('RTM_SERVICE: Logout Error: $e');
      }
    }
  }
}

