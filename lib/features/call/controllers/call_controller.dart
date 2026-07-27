import 'dart:async';
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agorartcapptest/core/api_endpoint/api_endpoint.dart';
import 'package:agorartcapptest/features/auth/controllers/auth_controller.dart';
import 'package:agorartcapptest/features/auth/models/user_model.dart';
import 'package:agorartcapptest/features/call/models/call_model.dart';
import 'package:agorartcapptest/features/call/service/call_service.dart';
import 'package:agorartcapptest/routes/app_routes.dart';

class CallController extends GetxController {
  final CallService _callService = CallService();
  final AuthController _authController = Get.find<AuthController>();

  RtcEngine? rtcEngine;

  final Rxn<CallModel> activeCall = Rxn<CallModel>();
  final Rxn<UserModel> targetUser = Rxn<UserModel>();

  final RxBool isMuted = false.obs;
  final RxBool isVideoDisabled = false.obs;
  final RxBool isFrontCamera = true.obs;
  final RxBool isSpeakerOn = true.obs;
  final RxnInt remoteUid = RxnInt();
  final RxInt callDurationSeconds = 0.obs;

  Timer? _statusPollTimer;
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

    final micStatus = statuses[Permission.microphone] ?? PermissionStatus.denied;
    final camStatus = statuses[Permission.camera] ?? PermissionStatus.granted;

    if (!micStatus.isGranted || (callType == 'video' && !camStatus.isGranted)) {
      Get.snackbar('Permissions Required', 'Camera and Microphone permissions are required to place calls.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }

  // 1. Initiate Outgoing Call (Caller side)
  Future<void> startCall(UserModel target, String callType) async {
    final hasPerms = await _requestPermissions(callType);
    if (!hasPerms) return;

    try {
      targetUser.value = target;
      final callData = await _callService.initiateCall(target.id, callType);
      activeCall.value = callData;

      // Navigate to Outgoing Call Screen (Before receive)
      Get.toNamed(AppRoutes.outgoingCallScreen);

      // Start polling for receiver accept/reject
      _startStatusPolling();
    } catch (e) {
      Get.snackbar('Call Error', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // 2. Accept Incoming Call (Receiver side)
  Future<void> acceptCall(CallModel callData) async {
    final hasPerms = await _requestPermissions(callData.callType);
    if (!hasPerms) return;

    try {
      final updatedCall = await _callService.updateCallStatus(callData.id, 'accepted');
      activeCall.value = updatedCall;

      // Setup Agora RTC Engine and Join Channel
      await _joinAgoraChannel(
        agoraAppId: callData.agoraAppId ?? ApiEndpoint.agoraAppId,
        channelName: callData.channelName,
        token: callData.receiverRtcToken ?? callData.callerRtcToken ?? '',
        uid: _authController.currentUser.value?.id ?? 0,
        callType: callData.callType,
      );

      // Navigate to Active Call Screen
      if (callData.callType == 'video') {
        Get.offNamed(AppRoutes.activeVideoCallScreen);
      } else {
        Get.offNamed(AppRoutes.activeAudioCallScreen);
      }
    } catch (e) {
      Get.snackbar('Call Error', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // 3. Reject Call
  Future<void> rejectCall(int callId) async {
    try {
      await _callService.updateCallStatus(callId, 'rejected');
      _stopStatusPolling();
      activeCall.value = null;
      if (Get.currentRoute == AppRoutes.outgoingCallScreen || Get.currentRoute == AppRoutes.activeVideoCallScreen || Get.currentRoute == AppRoutes.activeAudioCallScreen) {
        Get.back();
      }
    } catch (e) {
      print('Reject call error: $e');
    }
  }

  // 4. End Active Call
  Future<void> endCall() async {
    if (activeCall.value != null) {
      try {
        await _callService.updateCallStatus(activeCall.value!.id, 'ended');
      } catch (e) {}
    }
    await _leaveAgoraChannel();
  }

  // Poll call status on caller side to detect when receiver accepts/rejects
  void _startStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (activeCall.value == null) return;
      try {
        final history = await _callService.getCallHistory();
        final current = history.firstWhere((c) => c.id == activeCall.value!.id);
        
        if (current.status == 'accepted' && activeCall.value!.status == 'initiated') {
          activeCall.value = current;
          _stopStatusPolling();

          // Connect Caller to Agora RTC channel
          await _joinAgoraChannel(
            agoraAppId: current.agoraAppId ?? ApiEndpoint.agoraAppId,
            channelName: current.channelName,
            token: current.callerRtcToken ?? '',
            uid: _authController.currentUser.value?.id ?? 0,
            callType: current.callType,
          );

          if (current.callType == 'video') {
            Get.offNamed(AppRoutes.activeVideoCallScreen);
          } else {
            Get.offNamed(AppRoutes.activeAudioCallScreen);
          }
        } else if (['rejected', 'missed', 'ended'].contains(current.status.toLowerCase())) {
          _stopStatusPolling();
          activeCall.value = null;
          Get.snackbar('Call Update', 'Call ${current.status}', snackPosition: SnackPosition.BOTTOM);
          Get.back();
        }
      } catch (e) {}
    });
  }

  void _stopStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = null;
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
      rtcEngine = createAgoraRtcEngine();
      await rtcEngine!.initialize(RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      rtcEngine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('Successfully joined Agora channel: ${connection.channelId}');
          _startDurationTimer();
        },
        onUserJoined: (RtcConnection connection, int remoteId, int elapsed) {
          print('Remote user joined call: $remoteId');
          remoteUid.value = remoteId;
        },
        onUserOffline: (RtcConnection connection, int remoteId, UserOfflineReasonType reason) {
          print('Remote user left call: $remoteId');
          remoteUid.value = null;
          endCall();
        },
      ));

      if (callType == 'video') {
        await rtcEngine!.enableVideo();
        await rtcEngine!.startPreview();
      } else {
        await rtcEngine!.enableAudio();
      }

      await rtcEngine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      print('Agora Engine Join Error: $e');
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
    try {
      if (rtcEngine != null) {
        await rtcEngine!.leaveChannel();
        await rtcEngine!.release();
        rtcEngine = null;
      }
    } catch (e) {}

    remoteUid.value = null;
    activeCall.value = null;
    callDurationSeconds.value = 0;

    if (Get.currentRoute == AppRoutes.activeVideoCallScreen || Get.currentRoute == AppRoutes.activeAudioCallScreen || Get.currentRoute == AppRoutes.outgoingCallScreen) {
      Get.back();
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

  void switchCamera() {
    isFrontCamera.value = !isFrontCamera.value;
    rtcEngine?.switchCamera();
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    rtcEngine?.setEnableSpeakerphone(isSpeakerOn.value);
  }
}
