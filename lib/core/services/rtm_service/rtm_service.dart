import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:get/get.dart';
import 'package:agorartcapptest/core/api_endpoint/api_endpoint.dart';
import 'package:agorartcapptest/features/call/controllers/call_controller.dart';
import 'package:agorartcapptest/features/call/models/call_model.dart';
import 'package:agorartcapptest/features/call/screens/incoming_call_dialog.dart';

class RtmService extends GetxService {
  RtmClient? _rtmClient;
  bool _isLoggedIn = false;
  String _currentUserId = '';

  bool get isLoggedIn => _isLoggedIn;

  Future<void> initAndLogin({
    required String appId,
    required String userId,
    required String token,
  }) async {
    if (_isLoggedIn) return;
    _currentUserId = userId;

    try {
      final (status, client) = await RTM(appId, userId);
      _rtmClient = client;

      // Register event listeners
      _rtmClient?.addListener(
        message: (MessageEvent event) {
          final String rawMsg = event.message?.toString() ?? '';
          final String peerId = event.publisher?.toString() ?? '';
          _handleIncomingRtmMessage(rawMsg, peerId);
        },
        linkState: (LinkStateEvent event) {
          debugPrint('RTM_SERVICE: Link state changed: ${event.currentState}');
        },
      );

      final (loginStatus, loginRes) = await _rtmClient!.login(token);
      if (loginStatus.error) {
        debugPrint('RTM_SERVICE: Login Error Code: ${loginStatus.errorCode}, Reason: ${loginStatus.reason}');
        return;
      }

      // Subscribe to self user channel to receive incoming call offers
      await _rtmClient?.subscribe('user_$userId');

      _isLoggedIn = true;
      debugPrint('RTM_SERVICE: ✅ Logged into Agora RTM successfully for User $userId!');
    } catch (e) {
      debugPrint('RTM_SERVICE: Init Error: $e');
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
    } catch (e) {
      debugPrint('RTM_SERVICE: Error parsing RTM message: $e');
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
    if (_rtmClient == null || !_isLoggedIn) return;
    try {
      final jsonString = jsonEncode(payload);
      final channelName = 'user_$peerUserId';
      await _rtmClient?.publish(
        channelName,
        jsonString,
        channelType: RtmChannelType.user,
      );
      debugPrint('RTM_SERVICE: Published RTM message to $channelName: $jsonString');
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
