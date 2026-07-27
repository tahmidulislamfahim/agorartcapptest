import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agorartcapptest/core/api_endpoint/api_endpoint.dart';
import 'package:agorartcapptest/routes/app_routes.dart';
import 'package:agorartcapptest/features/auth/controllers/auth_controller.dart';
import 'package:agorartcapptest/features/auth/models/user_model.dart';
import 'package:agorartcapptest/features/call/models/call_model.dart';
import 'package:agorartcapptest/features/call/service/call_service.dart';

class CallController extends GetxController {
  final CallService _callService = CallService();
  final AuthController _authController = Get.find<AuthController>();

  RtcEngine? rtcEngine;

  final Rxn<CallModel> activeCall = Rxn<CallModel>();
  final RxnInt remoteUid = RxnInt();

  Rxn<UserModel> get targetUser {
    if (activeCall.value == null) return Rxn<UserModel>();
    final myId = _authController.currentUser.value?.id;
    final partnerId = activeCall.value!.callerId == myId
        ? activeCall.value!.receiverId
        : activeCall.value!.callerId;
    final partnerName = activeCall.value!.callerId == myId
        ? activeCall.value!.receiverUsername
        : activeCall.value!.callerUsername;
    return Rxn<UserModel>(UserModel(
      id: partnerId,
      username: partnerName,
      email: '',
      isOnline: true,
      createdAt: '',
    ));
  }

  Future<void> startCall(dynamic target, String callType) async {
    final int receiverId = target is int ? target : (target as UserModel).id;
    await initiateCall(receiverId, callType);
  }

  final RxBool isMuted = false.obs;
  final RxBool isVideoDisabled = false.obs;
  final RxBool isFrontCamera = true.obs;
  final RxBool isSpeakerOn = true.obs;
  final RxInt callDurationSeconds = 0.obs;

  Timer? _statusPollTimer;
  Timer? _activeCallStatusTimer;
  Timer? _durationTimer;

  @override
  void onClose() {
    _leaveAgoraChannel();
    super.onClose();
  }

  Future<bool> _requestPermissions(String callType) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      if (callType == 'video') Permission.camera,
    ].request();

    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
      }
    });

    if (!allGranted) {
      Get.snackbar(
        'Permission Denied',
        'Microphone and Camera permissions are required for calling.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    return allGranted;
  }

  // 1. Initiate Call (Caller side)
  Future<void> initiateCall(int receiverId, String callType) async {
    final hasPerms = await _requestPermissions(callType);
    if (!hasPerms) return;

    try {
      final callModel = await _callService.initiateCall(receiverId, callType);
      activeCall.value = callModel;

      // Navigate to Outgoing Call Screen
      Get.toNamed(AppRoutes.outgoingCallScreen);

      // Poll call status to check when receiver accepts or declines
      _startStatusPolling();
    } catch (e) {
      Get.snackbar(
        'Call Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  CallModel _mergeTokens(CallModel newCall, CallModel? previousCall) {
    if (previousCall == null) return newCall;
    return CallModel(
      id: newCall.id,
      callerId: newCall.callerId,
      callerUsername: newCall.callerUsername,
      receiverId: newCall.receiverId,
      receiverUsername: newCall.receiverUsername,
      channelName: newCall.channelName.isNotEmpty ? newCall.channelName : previousCall.channelName,
      callType: newCall.callType,
      status: newCall.status,
      durationSeconds: newCall.durationSeconds,
      callerRtcToken: (newCall.callerRtcToken != null && newCall.callerRtcToken!.isNotEmpty)
          ? newCall.callerRtcToken
          : previousCall.callerRtcToken,
      receiverRtcToken: (newCall.receiverRtcToken != null && newCall.receiverRtcToken!.isNotEmpty)
          ? newCall.receiverRtcToken
          : previousCall.receiverRtcToken,
      agoraAppId: (newCall.agoraAppId != null && newCall.agoraAppId!.isNotEmpty)
          ? newCall.agoraAppId
          : previousCall.agoraAppId,
    );
  }

  String _getRtcToken(CallModel call) {
    final myId = _authController.currentUser.value?.id;
    if (call.callerId == myId) {
      return (call.callerRtcToken != null && call.callerRtcToken!.isNotEmpty)
          ? call.callerRtcToken!
          : (call.receiverRtcToken ?? '');
    } else {
      return (call.receiverRtcToken != null && call.receiverRtcToken!.isNotEmpty)
          ? call.receiverRtcToken!
          : (call.callerRtcToken ?? '');
    }
  }

  // 2. Accept Incoming Call (Receiver side)
  Future<void> acceptCall(CallModel callData) async {
    activeCall.value = callData;
    final hasPerms = await _requestPermissions(callData.callType);
    if (!hasPerms) {
      activeCall.value = null;
      return;
    }

    try {
      final updatedCall = await _callService.updateCallStatus(callData.id, 'accepted');
      final mergedCall = _mergeTokens(updatedCall, callData);
      activeCall.value = mergedCall;

      final token = _getRtcToken(mergedCall);
      debugPrint('Receiver joining channel ${mergedCall.channelName} with token: $token for UID: ${_authController.currentUser.value?.id}');

      // Start active call polling immediately so call termination is caught live
      _startActiveCallStatusPolling();

      // Setup Agora RTC Engine and Join Channel
      await _joinAgoraChannel(
        agoraAppId: mergedCall.agoraAppId ?? ApiEndpoint.agoraAppId,
        channelName: mergedCall.channelName,
        token: token,
        uid: _authController.currentUser.value?.id ?? 0,
        callType: mergedCall.callType,
      );

      // Navigate to Active Call Screen
      if (mergedCall.callType == 'video') {
        Get.toNamed(AppRoutes.activeVideoCallScreen);
      } else {
        Get.toNamed(AppRoutes.activeAudioCallScreen);
      }

    } catch (e) {
      Get.snackbar(
        'Call Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 3. Reject Call
  Future<void> rejectCall(int callId) async {
    try {
      await _callService.updateCallStatus(callId, 'rejected');
      _stopStatusPolling();
      _stopActiveCallStatusPolling();
      activeCall.value = null;
      _leaveAgoraChannel();
    } catch (_) {}
  }

  // 4. End Active Call
  Future<void> endCall() async {
    final currentCall = activeCall.value;
    if (currentCall != null) {
      debugPrint('Ending call ID ${currentCall.id} on backend...');
      _callService.updateCallStatus(currentCall.id, 'ended').then((_) {
        debugPrint('Call ID ${currentCall.id} successfully updated to ended on backend.');
      }).catchError((e) {
        debugPrint('Error updating call status to ended: $e');
      });

    }
    await _leaveAgoraChannel();
  }



  // Poll call status on caller side to detect when receiver accepts/rejects
  void _startStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (activeCall.value == null) return;
      try {
        final history = await _callService.getCallHistory();
        final current = history.firstWhereOrNull((c) => c.id == activeCall.value!.id);
        if (current == null) return;

        if (current.status == 'accepted' && activeCall.value!.status == 'initiated') {
          final mergedCall = _mergeTokens(current, activeCall.value);
          activeCall.value = mergedCall;
          _stopStatusPolling();
          _startActiveCallStatusPolling();

          final token = _getRtcToken(mergedCall);
          debugPrint('Caller joining channel ${mergedCall.channelName} with token: $token for UID: ${_authController.currentUser.value?.id}');

          // Connect Caller to Agora RTC channel
          await _joinAgoraChannel(
            agoraAppId: mergedCall.agoraAppId ?? ApiEndpoint.agoraAppId,
            channelName: mergedCall.channelName,
            token: token,
            uid: _authController.currentUser.value?.id ?? 0,
            callType: mergedCall.callType,
          );

          if (mergedCall.callType == 'video') {
            Get.offNamed(AppRoutes.activeVideoCallScreen);
          } else {
            Get.offNamed(AppRoutes.activeAudioCallScreen);
          }
        } else if (['rejected', 'missed', 'ended'].contains(current.status.toLowerCase())) {
          _stopStatusPolling();
          activeCall.value = null;
          Get.snackbar('Call Update', 'Call ${current.status}', snackPosition: SnackPosition.BOTTOM);
          _leaveAgoraChannel();
        }
      } catch (e) {
        debugPrint('Status poll error: $e');
      }
    });
  }


  // Poll call status during active call to ensure device sync when either user ends call
  void _startActiveCallStatusPolling() {
    _activeCallStatusTimer?.cancel();
    _activeCallStatusTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (activeCall.value == null) return;
      try {
        final history = await _callService.getCallHistory();
        final current = history.firstWhereOrNull((c) => c.id == activeCall.value!.id);
        if (current != null && ['ended', 'rejected', 'missed'].contains(current.status.toLowerCase())) {
          _activeCallStatusTimer?.cancel();
          await _leaveAgoraChannel();
        }
      } catch (e) {
        debugPrint('Active call status poll error: $e');
      }
    });
  }

  void _stopStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = null;
  }

  void _stopActiveCallStatusPolling() {
    _activeCallStatusTimer?.cancel();
    _activeCallStatusTimer = null;
  }

  // Setup Agora Engine and Join Channel
  Future<void> _joinAgoraChannel({
    required String agoraAppId,
    required String channelName,
    required String token,
    required int uid,
    required String callType,
  }) async {
    try {
      debugPrint('Initializing Agora Engine. AppId: $agoraAppId, Channel: $channelName, UID: $uid');
      rtcEngine = createAgoraRtcEngine();
      await rtcEngine!.initialize(RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      rtcEngine!.registerEventHandler(RtcEngineEventHandler(
        onError: (ErrorCodeType err, String msg) {
          debugPrint('Agora Engine Error: $err - $msg');
        },
        onLocalVideoStateChanged: (VideoSourceType source, LocalVideoStreamState state, LocalVideoStreamReason reason) {
          debugPrint('Agora Local Video State: $state, Reason: $reason');
        },
        onRemoteVideoStateChanged: (RtcConnection connection, int remoteId, RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
          debugPrint('Agora Remote Video State for $remoteId: $state, Reason: $reason');
          if (state == RemoteVideoState.remoteVideoStateDecoding || state == RemoteVideoState.remoteVideoStateStarting) {
            remoteUid.value = remoteId;
          }
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Agora joined channel successfully: ${connection.channelId}');
          _startDurationTimer();
          try {
            rtcEngine?.setEnableSpeakerphone(true);
          } catch (_) {}
        },
        onUserJoined: (RtcConnection connection, int remoteId, int elapsed) {
          debugPrint('Agora remote user joined: $remoteId');
          remoteUid.value = remoteId;
        },
        onUserOffline: (RtcConnection connection, int remoteId, UserOfflineReasonType reason) {
          debugPrint('Agora remote user offline: $remoteId');
          remoteUid.value = null;
          endCall();
        },
      ));

      await rtcEngine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // Enable Media Modules & Adjust Signal Volume
      await rtcEngine!.enableAudio();
      await rtcEngine!.adjustPlaybackSignalVolume(100);
      await rtcEngine!.adjustRecordingSignalVolume(100);

      if (callType == 'video') {
        await rtcEngine!.enableVideo();
        await rtcEngine!.startPreview();
      }

      // Join Channel with Broadcaster Role
      await rtcEngine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          publishCameraTrack: callType == 'video',
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: callType == 'video',
        ),
      );
      debugPrint('joinChannel executed successfully.');
    } catch (e, stack) {
      debugPrint('Agora join channel error: $e\n$stack');
    }
  }


  void _startDurationTimer() {
    _durationTimer?.cancel();
    callDurationSeconds.value = 0;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      callDurationSeconds.value++;
    });
  }

  Future<void> _leaveAgoraChannel() async {
    _durationTimer?.cancel();
    _stopStatusPolling();
    _stopActiveCallStatusPolling();
    try {
      if (rtcEngine != null) {
        await rtcEngine!.leaveChannel();
        await rtcEngine!.release();
        rtcEngine = null;
      }
    } catch (e) {
      debugPrint('Error releasing Agora engine: $e');
    }

    remoteUid.value = null;
    activeCall.value = null;
    callDurationSeconds.value = 0;

    // Continuously pop until all call screens and dialogs are closed
    try {
      int maxPops = 5;
      while (maxPops > 0 &&
          (Get.currentRoute == AppRoutes.activeVideoCallScreen ||
           Get.currentRoute == AppRoutes.activeAudioCallScreen ||
           Get.currentRoute == AppRoutes.outgoingCallScreen ||
           Get.isDialogOpen == true)) {
        Get.back();
        maxPops--;
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      debugPrint('Navigation pop error: $e');
    }
  }



  void toggleMute() {
    isMuted.value = !isMuted.value;
    rtcEngine?.muteLocalAudioStream(isMuted.value);
  }

  void toggleCamera() {
    isVideoDisabled.value = !isVideoDisabled.value;
    rtcEngine?.muteLocalVideoStream(isVideoDisabled.value);
  }

  void toggleVideo() {
    toggleCamera();
  }

  void switchCamera() {
    isFrontCamera.value = !isFrontCamera.value;
    rtcEngine?.switchCamera();
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    rtcEngine?.setEnableSpeakerphone(isSpeakerOn.value);
  }
}
